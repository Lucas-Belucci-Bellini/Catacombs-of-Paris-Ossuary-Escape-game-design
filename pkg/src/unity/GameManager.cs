// GameManager.cs
// Attach to: GameObject "GameManager" (não destruir entre cenas)
// Singleton que centraliza o estado do jogo, pontuação, vidas,
// power-ups e persistência de dados.
//
// SETUP NA UNITY:
//   1. Crie um GameObject vazio "GameManager" na cena inicial
//   2. Adicione este script
//   3. O singleton persiste entre cenas via DontDestroyOnLoad

using UnityEngine;
using System;
using System.Collections;

public class GameManager : MonoBehaviour
{
    // ─────────────────────────────────────────────
    //  SINGLETON
    // ─────────────────────────────────────────────
    public static GameManager Instance { get; private set; }

    private void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        DontDestroyOnLoad(gameObject);
        CarregarDadosSalvos();
    }

    // ─────────────────────────────────────────────
    //  ESTADO DO JOGO
    // ─────────────────────────────────────────────
    public enum Estado { Menu, Jogando, Pausado, GameOver }
    public Estado EstadoAtual { get; private set; } = Estado.Menu;

    // ─────────────────────────────────────────────
    //  DADOS DA PARTIDA
    // ─────────────────────────────────────────────
    public int Pontuacao { get; private set; }
    public int Recorde { get; private set; }
    public int Vidas { get; private set; }
    public int Moedas { get; private set; }
    public float TempoPartida { get; private set; }
    public bool Invencivel { get; private set; }

    private float _tempoInvencivel = 0f;
    private const float DuracaoInvencibilidade = 2f;
    private const string ChaveRecorde = "ossuary_recorde";
    private const string ChaveMoedas = "ossuary_moedas";

    // ─────────────────────────────────────────────
    //  EVENTOS (inscreva-se nos outros scripts)
    // ─────────────────────────────────────────────
    public event Action OnJogoIniciado;
    public event Action<int, bool> OnJogoEncerrado;   // (pontuação, éNovoRecorde)
    public event Action<int> OnPontuacaoAlterada;
    public event Action<int> OnVidasAlteradas;
    public event Action OnDanoSofrido;
    public event Action OnPowerUpAtivado;

    // ═════════════════════════════════════════════
    //  LOOP PRINCIPAL
    // ═════════════════════════════════════════════
    private void Update()
    {
        if (EstadoAtual != Estado.Jogando) return;

        TempoPartida += Time.deltaTime;

        // Pontuação cresce com o tempo e acelera levemente
        int ptsPorSegundo = Mathf.RoundToInt(10f + TempoPartida * 0.5f);
        int deltaPts = Mathf.RoundToInt(ptsPorSegundo * Time.deltaTime);
        if (deltaPts > 0)
        {
            Pontuacao += deltaPts;
            OnPontuacaoAlterada?.Invoke(Pontuacao);
        }

        // Conta regressiva de invencibilidade
        if (Invencivel)
        {
            _tempoInvencivel -= Time.deltaTime;
            if (_tempoInvencivel <= 0f)
                Invencivel = false;
        }
    }

    // ═════════════════════════════════════════════
    //  CONTROLE DE FLUXO
    // ═════════════════════════════════════════════
    public void IniciarJogo()
    {
        Pontuacao = 0;
        Vidas = 3;
        TempoPartida = 0f;
        Invencivel = false;
        _tempoInvencivel = 0f;
        EstadoAtual = Estado.Jogando;
        Time.timeScale = 1f;

        OnJogoIniciado?.Invoke();
        OnPontuacaoAlterada?.Invoke(0);
        OnVidasAlteradas?.Invoke(3);
    }

    public void Pausar()
    {
        if (EstadoAtual != Estado.Jogando) return;
        EstadoAtual = Estado.Pausado;
        Time.timeScale = 0f;
    }

    public void Retomar()
    {
        if (EstadoAtual != Estado.Pausado) return;
        EstadoAtual = Estado.Jogando;
        Time.timeScale = 1f;
    }

    public void TerminarJogo()
    {
        if (EstadoAtual == Estado.GameOver) return;
        EstadoAtual = Estado.GameOver;
        Time.timeScale = 1f;  // garante que as animações de morte rodem

        bool eNovoRecorde = Pontuacao > Recorde;
        if (eNovoRecorde) Recorde = Pontuacao;
        SalvarDados();

        OnJogoEncerrado?.Invoke(Pontuacao, eNovoRecorde);
    }

    // ═════════════════════════════════════════════
    //  SISTEMA DE DANO
    // ═════════════════════════════════════════════
    /// <summary>
    /// Chamado por obstáculos. Dispara eventos para AnkouChase e UI.
    /// </summary>
    public void RegistrarDano(int quantidade = 1)
    {
        if (Invencivel || EstadoAtual != Estado.Jogando) return;

        Vidas = Mathf.Max(0, Vidas - quantidade);
        Invencivel = true;
        _tempoInvencivel = DuracaoInvencibilidade;

        OnDanoSofrido?.Invoke();
        OnVidasAlteradas?.Invoke(Vidas);

        if (Vidas <= 0)
            TerminarJogo();
    }

    // ═════════════════════════════════════════════
    //  SISTEMA DE POWER-UPS
    // ═════════════════════════════════════════════
    public enum TipoPowerUp
    {
        Sprint,        // Afasta o Ankou + boost de velocidade
        EscudoOssos,   // Imunidade temporária (5s)
        Lanterna,      // Revela obstáculos com antecedência
        OssadaSagrada  // Recupera 1 vida
    }

    public void AtivarPowerUp(TipoPowerUp tipo)
    {
        if (EstadoAtual != Estado.Jogando) return;

        OnPowerUpAtivado?.Invoke();   // AnkouChase escuta e afasta o Ankou

        switch (tipo)
        {
            case TipoPowerUp.Sprint:
                // Lógica de velocidade no PlayerController
                StartCoroutine(BoostVelocidade(3f));
                break;

            case TipoPowerUp.EscudoOssos:
                Invencivel = true;
                _tempoInvencivel = 5f;
                break;

            case TipoPowerUp.Lanterna:
                // Comunique à câmera/luz principal para aumentar range
                Debug.Log("Power-up Lanterna ativado.");
                break;

            case TipoPowerUp.OssadaSagrada:
                Vidas = Mathf.Min(3, Vidas + 1);
                OnVidasAlteradas?.Invoke(Vidas);
                break;
        }
    }

    private IEnumerator BoostVelocidade(float duracao)
    {
        PlayerController jogador = FindObjectOfType<PlayerController>();
        // PlayerController pode expor um método AplicarBoost() se necessário
        yield return new WaitForSeconds(duracao);
    }

    // ═════════════════════════════════════════════
    //  COLEÇÃO DE RELÍQUIAS
    // ═════════════════════════════════════════════
    public void ColetarReliquia(int valor = 1)
    {
        Moedas += valor;
    }

    // ═════════════════════════════════════════════
    //  PERSISTÊNCIA
    // ═════════════════════════════════════════════
    private void SalvarDados()
    {
        PlayerPrefs.SetInt(ChaveRecorde, Recorde);
        PlayerPrefs.SetInt(ChaveMoedas, Moedas);
        PlayerPrefs.Save();
    }

    private void CarregarDadosSalvos()
    {
        Recorde = PlayerPrefs.GetInt(ChaveRecorde, 0);
        Moedas  = PlayerPrefs.GetInt(ChaveMoedas, 0);
    }

    // ─────────────────────────────────────────────
    //  UTILITÁRIOS
    // ─────────────────────────────────────────────
    public bool EstaJogando() => EstadoAtual == Estado.Jogando;
    public string GetPontuacaoFormatada() => Pontuacao.ToString("N0") + "m";
    public string GetRecordeFormatado() => Recorde.ToString("N0") + "m";
}
