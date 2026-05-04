// AnkouChase.cs
// Attach to: GameObject "Ankou" (com modelo 3D do esqueleto como filho)
// Gerencia a perseguição, visual, áudio e captura do jogador.
// A distância é um valor abstrato 0-100; não há física real.
//
// SETUP NA UNITY:
//   GameObject "Ankou"   ← este script + AudioSource
//   └── GameObject "Modelo3D"   ← SkinnedMeshRenderer + Animator
//       └── Animator: triggers "Flutuar", "Capturar"

using UnityEngine;
using System.Collections;

public class AnkouChase : MonoBehaviour
{
    // ─────────────────────────────────────────────
    //  PARÂMETROS DO INSPECTOR
    // ─────────────────────────────────────────────
    [Header("Distância")]
    [Tooltip("Distância inicial (100=longe, 0=capturou)")]
    [SerializeField] private float distanciaInicial = 100f;
    [Tooltip("Quanto a distância diminui por segundo (velocidade base)")]
    [SerializeField] private float velocidadeAproximacao = 0.9f;
    [Tooltip("Aceleração da perseguição por segundo de jogo")]
    [SerializeField] private float aceleracaoPerseguicao = 0.012f;
    [Tooltip("Penalidade ao jogador falhar (distância que o Ankou avança)")]
    [SerializeField] private float penalidade = 14f;
    [Tooltip("Distância ganha ao ativar power-up")]
    [SerializeField] private float bonusPowerUp = 22f;

    [Header("Visual")]
    [Tooltip("A que distância o Ankou começa a aparecer (transparente→opaco)")]
    [SerializeField] private float distanciaAparecimento = 75f;
    [SerializeField] private Transform modelo3D;
    [SerializeField] private Renderer rendererAnkou;
    [SerializeField] private ParticleSystem particulasNeblina;

    [Header("Câmera de Morte")]
    [Tooltip("Câmera ativada quando o Ankou captura o jogador")]
    [SerializeField] private Camera cameraMorte;

    [Header("Áudio")]
    [SerializeField] private AudioSource audioAnkou;
    [SerializeField] private float volumeLonge = 0.0f;
    [SerializeField] private float volumePerto = 0.9f;

    // ─────────────────────────────────────────────
    //  ESTADO INTERNO
    // ─────────────────────────────────────────────
    private float distanciaAtual;
    private bool estaPerseguindo = false;
    private bool capturou = false;
    private float tempoJogo = 0f;
    private Animator animAnkou;
    private MaterialPropertyBlock propBlock;

    // ─────────────────────────────────────────────
    //  EVENTOS
    // ─────────────────────────────────────────────
    public event System.Action OnAnkouCapturou;
    public event System.Action<float> OnDistanciaAtualizada;

    // ═════════════════════════════════════════════
    //  INICIALIZAÇÃO
    // ═════════════════════════════════════════════
    private void Start()
    {
        distanciaAtual = distanciaInicial;
        propBlock = new MaterialPropertyBlock();

        if (modelo3D != null)
        {
            modelo3D.gameObject.SetActive(false);
            animAnkou = modelo3D.GetComponentInChildren<Animator>();
            animAnkou?.SetTrigger("Flutuar");
        }

        if (cameraMorte != null)
            cameraMorte.enabled = false;

        // Inscreve nos eventos do GameManager
        GameManager.Instance.OnDanoSofrido += AoSofrerDano;
        GameManager.Instance.OnPowerUpAtivado += AoUsarPowerUp;
    }

    private void OnDestroy()
    {
        if (GameManager.Instance != null)
        {
            GameManager.Instance.OnDanoSofrido -= AoSofrerDano;
            GameManager.Instance.OnPowerUpAtivado -= AoUsarPowerUp;
        }
    }

    // ═════════════════════════════════════════════
    //  LOOP PRINCIPAL
    // ═════════════════════════════════════════════
    private void Update()
    {
        if (!estaPerseguindo || capturou) return;

        tempoJogo += Time.deltaTime;

        // Velocidade de aproximação aumenta gradualmente com o tempo
        float multiplicador = 1f + tempoJogo * aceleracaoPerseguicao;
        distanciaAtual -= velocidadeAproximacao * multiplicador * Time.deltaTime;
        distanciaAtual = Mathf.Max(0f, distanciaAtual);

        OnDistanciaAtualizada?.Invoke(distanciaAtual);
        AtualizarVisual();
        AtualizarAudio();

        if (distanciaAtual <= 0f)
            CapturarJogador();
    }

    // ═════════════════════════════════════════════
    //  REAÇÃO A EVENTOS DO JOGO
    // ═════════════════════════════════════════════
    private void AoSofrerDano()
    {
        distanciaAtual = Mathf.Max(0f, distanciaAtual - penalidade);
        if (distanciaAtual <= 0f) CapturarJogador();
    }

    private void AoUsarPowerUp()
    {
        distanciaAtual = Mathf.Min(distanciaInicial, distanciaAtual + bonusPowerUp);
    }

    // ═════════════════════════════════════════════
    //  VISUAL DO ANKOU
    // ═════════════════════════════════════════════
    private void AtualizarVisual()
    {
        if (modelo3D == null) return;

        float progresso = 1f - (distanciaAtual / distanciaInicial);

        // Aparece gradualmente a partir de distanciaAparecimento
        float limiar = 1f - (distanciaAparecimento / distanciaInicial);
        float opacidade = Mathf.Clamp01((progresso - limiar) / (1f - limiar));

        modelo3D.gameObject.SetActive(opacidade > 0.01f);

        // Oscilação lateral espectral
        Vector3 posLocal = modelo3D.localPosition;
        posLocal.x = Mathf.Sin(tempoJogo * 1.1f) * 0.35f * opacidade;
        modelo3D.localPosition = posLocal;

        // Escala cresce conforme aproxima
        float escalaBase = 0.5f + progresso * 1.0f;
        modelo3D.localScale = Vector3.one * escalaBase;

        // Atualiza opacidade via MaterialPropertyBlock (não cria novas instâncias de material)
        if (rendererAnkou != null)
        {
            rendererAnkou.GetPropertyBlock(propBlock);
            Color cor = propBlock.GetColor("_BaseColor");
            cor.a = opacidade;
            propBlock.SetColor("_BaseColor", cor);
            rendererAnkou.SetPropertyBlock(propBlock);
        }

        // Partículas de neblina
        if (particulasNeblina != null)
        {
            var emissao = particulasNeblina.emission;
            emissao.rateOverTime = opacidade * 30f;
        }
    }

    // ═════════════════════════════════════════════
    //  ÁUDIO DO ANKOU
    // ═════════════════════════════════════════════
    private void AtualizarAudio()
    {
        if (audioAnkou == null) return;
        float progresso = 1f - (distanciaAtual / distanciaInicial);
        // Quadrático para subir rápido só quando perto
        audioAnkou.volume = Mathf.Lerp(volumeLonge, volumePerto, progresso * progresso);
    }

    // ═════════════════════════════════════════════
    //  CAPTURA DO JOGADOR
    // ═════════════════════════════════════════════
    private void CapturarJogador()
    {
        if (capturou) return;
        capturou = true;
        estaPerseguindo = false;

        animAnkou?.SetTrigger("Capturar");
        OnAnkouCapturou?.Invoke();

        // Ativa câmera de morte
        if (cameraMorte != null)
        {
            cameraMorte.enabled = true;
            Camera.main.enabled = false;
        }

        StartCoroutine(SequenciaCaptura());
    }

    private IEnumerator SequenciaCaptura()
    {
        yield return new WaitForSeconds(0.3f);

        // Mata o jogador
        PlayerController jogador = FindObjectOfType<PlayerController>();
        if (jogador != null) jogador.Morrer();

        yield return new WaitForSeconds(1.2f);

        GameManager.Instance.TerminarJogo();
    }

    // ═════════════════════════════════════════════
    //  API PÚBLICA
    // ═════════════════════════════════════════════
    public void IniciarPerseguicao()
    {
        estaPerseguindo = true;
        if (audioAnkou != null && !audioAnkou.isPlaying)
            audioAnkou.Play();
    }

    public void Reiniciar()
    {
        distanciaAtual = distanciaInicial;
        tempoJogo = 0f;
        capturou = false;
        estaPerseguindo = false;
        if (modelo3D != null) modelo3D.gameObject.SetActive(false);
        if (cameraMorte != null) cameraMorte.enabled = false;
    }

    public float GetDistancia() => distanciaAtual;
    public float GetProgresso() => 1f - (distanciaAtual / distanciaInicial);
}
