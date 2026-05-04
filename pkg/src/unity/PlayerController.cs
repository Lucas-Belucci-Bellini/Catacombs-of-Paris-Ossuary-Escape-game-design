// PlayerController.cs
// Attach to: GameObject com CharacterController
// Controla o explorador urbano: movimento automático, troca de pistas,
// pulo, deslize e entrada por teclado + swipe mobile.
//
// SETUP NA UNITY:
//   GameObject "Jogador"
//   ├── CharacterController   (Height 1.8, Center Y=0.9)
//   ├── Animator              (parâmetros: bool Deslizando, triggers Pular/Morrer/Correr)
//   ├── AudioSource           (sons de passos, pulo, colisão)
//   └── Este script
//
// INPUT SYSTEM: usa o Input legado (Edit → Project Settings → Input Manager)
//   Adicione eixos:
//     "MoverEsquerda" : a, left arrow  (negative button)
//     "MoverDireita"  : d, right arrow (positive button)
//     "Pular"         : w, up arrow, space
//     "Deslizar"      : s, down arrow

using UnityEngine;
using System.Collections;
using System;

[RequireComponent(typeof(CharacterController))]
public class PlayerController : MonoBehaviour
{
    // ─────────────────────────────────────────────
    //  PARÂMETROS EXPORTADOS (Inspector)
    // ─────────────────────────────────────────────
    [Header("Velocidade")]
    [SerializeField] private float velocidadeBase = 8f;
    [SerializeField] private float aceleracaoPorSegundo = 0.003f;

    [Header("Pistas")]
    [SerializeField] private float[] posicoesX = { -2f, 0f, 2f };
    [SerializeField] private float suavidadeTrocaPista = 10f;

    [Header("Pulo")]
    [SerializeField] private float forcaPulo = 12.5f;
    [SerializeField] private float gravidade = -30f;

    [Header("Deslize")]
    [SerializeField] private float duracaoDeslize = 0.75f;
    [SerializeField] private Vector3 centroColisaoDeslize = new Vector3(0f, 0.45f, 0f);
    [SerializeField] private float alturaColisaoDeslize = 0.9f;

    [Header("Referências")]
    [SerializeField] private Animator animador;
    [SerializeField] private AudioClip somPulo;
    [SerializeField] private AudioClip somColisao;
    [SerializeField] private AudioClip somDeslize;

    // ─────────────────────────────────────────────
    //  ESTADO INTERNO
    // ─────────────────────────────────────────────
    private CharacterController cc;
    private AudioSource audio;

    private int pistaAtual = 1;         // 0=esq · 1=centro · 2=dir
    private float velocidadeAtual;
    private float velocidadeY = 0f;
    private bool estaPulando = false;
    private bool estaDeslizando = false;
    private float tempoDeslizeRestante = 0f;
    private bool estaVivo = true;

    // Armazena valores originais da colisão para restaurar após deslize
    private Vector3 centroColisaoOriginal;
    private float alturaColisaoOriginal;

    // Swipe Mobile
    private Vector2 toqueInicio;
    private const float LimiarSwipe = 45f;
    private bool tocouEsteFrame = false;

    // ─────────────────────────────────────────────
    //  EVENTOS
    // ─────────────────────────────────────────────
    public event Action OnMorreu;
    public event Action<int> OnPistaAlterada;

    // ═════════════════════════════════════════════
    //  INICIALIZAÇÃO
    // ═════════════════════════════════════════════
    private void Awake()
    {
        cc = GetComponent<CharacterController>();
        audio = GetComponent<AudioSource>();

        velocidadeAtual = velocidadeBase;
        centroColisaoOriginal = cc.center;
        alturaColisaoOriginal = cc.height;
    }

    // ═════════════════════════════════════════════
    //  LOOP PRINCIPAL
    // ═════════════════════════════════════════════
    private void Update()
    {
        if (!estaVivo) return;

        ProcessarEntradaTeclado();
        ProcessarSwipeMobile();
        AtualizarDeslize();
        AumentarVelocidade();
    }

    private void FixedUpdate()
    {
        if (!estaVivo) return;

        // Gravidade
        if (cc.isGrounded)
        {
            velocidadeY = -1f;   // leve força negativa para manter no chão
            if (estaPulando) estaPulando = false;
        }
        else
        {
            velocidadeY += gravidade * Time.fixedDeltaTime;
        }

        // Interpolação suave para a pista alvo
        float alvoX = posicoesX[pistaAtual];
        float novoX = Mathf.Lerp(transform.position.x, alvoX, suavidadeTrocaPista * Time.fixedDeltaTime);

        // Monta vetor de movimento final
        Vector3 movimento = new Vector3(
            novoX - transform.position.x,
            velocidadeY * Time.fixedDeltaTime,
            -velocidadeAtual * Time.fixedDeltaTime
        );

        cc.Move(movimento);
    }

    // ═════════════════════════════════════════════
    //  ENTRADA — TECLADO / PC
    // ═════════════════════════════════════════════
    private void ProcessarEntradaTeclado()
    {
        if (Input.GetKeyDown(KeyCode.LeftArrow) || Input.GetKeyDown(KeyCode.A))
            TrocarPista(-1);

        if (Input.GetKeyDown(KeyCode.RightArrow) || Input.GetKeyDown(KeyCode.D))
            TrocarPista(1);

        if ((Input.GetKeyDown(KeyCode.UpArrow) || Input.GetKeyDown(KeyCode.W) || Input.GetKeyDown(KeyCode.Space))
            && cc.isGrounded && !estaDeslizando)
            Pular();

        if ((Input.GetKeyDown(KeyCode.DownArrow) || Input.GetKeyDown(KeyCode.S))
            && !estaPulando)
            IniciarDeslize();
    }

    // ═════════════════════════════════════════════
    //  ENTRADA — SWIPE MOBILE
    // ═════════════════════════════════════════════
    private void ProcessarSwipeMobile()
    {
        if (Input.touchCount == 0) return;

        Touch toque = Input.GetTouch(0);

        if (toque.phase == TouchPhase.Began)
            toqueInicio = toque.position;

        if (toque.phase == TouchPhase.Ended)
        {
            Vector2 delta = toque.position - toqueInicio;
            if (delta.magnitude < LimiarSwipe) return;

            if (Mathf.Abs(delta.x) >= Mathf.Abs(delta.y))
            {
                // Swipe HORIZONTAL → troca de pista
                TrocarPista(delta.x > 0 ? 1 : -1);
            }
            else
            {
                if (delta.y > 0 && cc.isGrounded && !estaDeslizando)
                    Pular();
                else if (delta.y < 0 && !estaPulando)
                    IniciarDeslize();
            }
        }
    }

    // ═════════════════════════════════════════════
    //  AÇÕES DE MOVIMENTO
    // ═════════════════════════════════════════════
    public void TrocarPista(int direcao)
    {
        int novaPista = Mathf.Clamp(pistaAtual + direcao, 0, posicoesX.Length - 1);
        if (novaPista == pistaAtual) return;
        pistaAtual = novaPista;
        OnPistaAlterada?.Invoke(pistaAtual);
    }

    public void Pular()
    {
        velocidadeY = forcaPulo;
        estaPulando = true;
        animador?.SetTrigger("Pular");
        PlaySom(somPulo);
    }

    public void IniciarDeslize()
    {
        if (estaDeslizando) return;
        estaDeslizando = true;
        tempoDeslizeRestante = duracaoDeslize;

        // Reduz a cápsula de colisão para passar sob vigas
        cc.center = centroColisaoDeslize;
        cc.height = alturaColisaoDeslize;

        animador?.SetBool("Deslizando", true);
        PlaySom(somDeslize);
    }

    private void TerminarDeslize()
    {
        estaDeslizando = false;
        cc.center = centroColisaoOriginal;
        cc.height = alturaColisaoOriginal;
        animador?.SetBool("Deslizando", false);
    }

    // ═════════════════════════════════════════════
    //  ATUALIZAÇÕES CONTÍNUAS
    // ═════════════════════════════════════════════
    private void AtualizarDeslize()
    {
        if (!estaDeslizando) return;
        tempoDeslizeRestante -= Time.deltaTime;
        if (tempoDeslizeRestante <= 0f)
            TerminarDeslize();
    }

    private void AumentarVelocidade()
    {
        // Velocidade cresce suavemente para aumentar o desafio ao longo do tempo
        velocidadeAtual += aceleracaoPorSegundo * Time.deltaTime * 60f;
    }

    // ═════════════════════════════════════════════
    //  MORTE
    // ═════════════════════════════════════════════
    public void Morrer()
    {
        if (!estaVivo) return;
        estaVivo = false;
        enabled = false;  // para Update/FixedUpdate
        animador?.SetTrigger("Morrer");
        OnMorreu?.Invoke();
    }

    // ═════════════════════════════════════════════
    //  COLISÃO COM OBSTÁCULOS
    // ═════════════════════════════════════════════
    private void OnTriggerEnter(Collider outro)
    {
        if (!estaVivo) return;

        Obstaculo obs = outro.GetComponent<Obstaculo>();
        if (obs == null) return;

        if (obs.causaMorteInstantanea)
        {
            Morrer();
        }
        else
        {
            PlaySom(somColisao);
            GameManager.Instance.RegistrarDano(obs.dano);
        }
    }

    // ─────────────────────────────────────────────
    //  UTILITÁRIOS
    // ─────────────────────────────────────────────
    private void PlaySom(AudioClip clip)
    {
        if (audio != null && clip != null)
            audio.PlayOneShot(clip);
    }

    public float GetVelocidade() => velocidadeAtual;
    public int GetPista() => pistaAtual;
    public bool EstaVivo() => estaVivo;
}
