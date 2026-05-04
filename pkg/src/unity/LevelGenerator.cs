// LevelGenerator.cs
// Attach to: GameObject vazio "LevelGenerator" na raiz da cena.
// Gera infinitamente tiles de túnel das catacumbas usando Object Pooling.
// Os tiles ficam em fila circular: quando passam pelo jogador, voltam
// para o pool e são reaproveitados à frente.
//
// SETUP NA UNITY:
//   1. Crie Prefabs de túnel (ex: TunelReto.prefab) com comprimento = comprimentoTile
//   2. Crie Prefabs de obstáculos (ex: PilhaCranios.prefab) com collider Trigger
//   3. Arraste os prefabs nos arrays no Inspector
//   4. Certifique que o jogador tem tag "Jogador"

using UnityEngine;
using System.Collections.Generic;

public class LevelGenerator : MonoBehaviour
{
    // ─────────────────────────────────────────────
    //  PARÂMETROS DO INSPECTOR
    // ─────────────────────────────────────────────
    [Header("Prefabs")]
    [Tooltip("Prefabs dos segmentos de túnel")]
    [SerializeField] private GameObject[] tilesPrefabs;
    [Tooltip("Prefabs dos obstáculos (pilha, viga, poço, crânios)")]
    [SerializeField] private GameObject[] obstaculosPrefabs;

    [Header("Configuração de Geração")]
    [Tooltip("Comprimento de cada tile em metros (deve ser igual ao modelo 3D)")]
    [SerializeField] private float comprimentoTile = 24f;
    [Tooltip("Quantos tiles ficam ativos simultaneamente à frente")]
    [SerializeField] private int tilesAFrente = 7;
    [Tooltip("Posições X das 3 pistas")]
    [SerializeField] private float[] posicoesX = { -2f, 0f, 2f };
    [Tooltip("Chance (0-1) de obstáculo aparecer por tile")]
    [Range(0f, 1f)]
    [SerializeField] private float chanceObstaculo = 0.60f;
    [Tooltip("Quantos tiles iniciais ficam livres de obstáculos")]
    [SerializeField] private int tilesLivresIniciais = 4;

    // ─────────────────────────────────────────────
    //  POOLS E LISTAS ATIVAS
    // ─────────────────────────────────────────────
    private Queue<GameObject> poolTiles = new Queue<GameObject>();
    private Queue<GameObject> poolObstaculos = new Queue<GameObject>();
    private List<GameObject> tilesAtivos = new List<GameObject>();
    private List<GameObject> obstaculosAtivos = new List<GameObject>();

    // ─────────────────────────────────────────────
    //  ESTADO INTERNO
    // ─────────────────────────────────────────────
    private float zProximoSpawn = 0f;      // Posição Z do próximo tile
    private int totalTilesSpawnados = 0;
    private Transform jogadorTransform;

    // ═════════════════════════════════════════════
    //  INICIALIZAÇÃO
    // ═════════════════════════════════════════════
    private void Start()
    {
        // Localiza o jogador pela tag
        GameObject jogadorObj = GameObject.FindGameObjectWithTag("Jogador");
        if (jogadorObj != null)
            jogadorTransform = jogadorObj.transform;
        else
            Debug.LogError("LevelGenerator: Nenhum objeto com tag 'Jogador' encontrado!");

        PreAquecerPools();
        SpawnarTilesIniciais();
    }

    private void PreAquecerPools()
    {
        // Pré-instancia tiles para evitar GC spikes durante o jogo
        int totalPool = tilesAFrente + 4;
        for (int i = 0; i < totalPool; i++)
        {
            GameObject tile = Instantiate(SortearTilePrefab(), transform);
            tile.SetActive(false);
            poolTiles.Enqueue(tile);
        }

        // Pré-instancia obstáculos
        for (int i = 0; i < 16; i++)
        {
            if (obstaculosPrefabs == null || obstaculosPrefabs.Length == 0) break;
            GameObject obs = Instantiate(SortearObstaculoPrefab(), transform);
            obs.SetActive(false);
            poolObstaculos.Enqueue(obs);
        }
    }

    private void SpawnarTilesIniciais()
    {
        for (int i = 0; i < tilesAFrente; i++)
            SpawnarTile();
    }

    // ═════════════════════════════════════════════
    //  LOOP PRINCIPAL
    // ═════════════════════════════════════════════
    private void Update()
    {
        if (jogadorTransform == null) return;

        VerificarESpawnar();
        ReciclarTilesDistantes();
        ReciclarObstaculosDistantes();
    }

    private void VerificarESpawnar()
    {
        // Spawna quando o final dos tiles visíveis está chegando
        float limiteSpawn = jogadorTransform.position.z - comprimentoTile * (tilesAFrente - 2);
        if (zProximoSpawn > limiteSpawn)
            SpawnarTile();
    }

    // ═════════════════════════════════════════════
    //  SPAWN DE TILES
    // ═════════════════════════════════════════════
    private void SpawnarTile()
    {
        GameObject tile = ObterTileDoPool();
        if (tile == null) return;

        tile.transform.position = new Vector3(0f, 0f, zProximoSpawn);
        tile.SetActive(true);
        tilesAtivos.Add(tile);

        totalTilesSpawnados++;
        zProximoSpawn -= comprimentoTile;

        // Tenta spawnar obstáculo (não nos tiles iniciais)
        if (totalTilesSpawnados > tilesLivresIniciais && Random.value < chanceObstaculo)
            SpawnarObstaculoNoTile(tile);
    }

    private void SpawnarObstaculoNoTile(GameObject tile)
    {
        if (obstaculosPrefabs == null || obstaculosPrefabs.Length == 0) return;

        GameObject obs = ObterObstaculoDoPool();
        if (obs == null) return;

        int pista = Random.Range(0, posicoesX.Length);
        float offsetZ = Random.Range(comprimentoTile * 0.25f, comprimentoTile * 0.75f);

        obs.transform.position = tile.transform.position +
            new Vector3(posicoesX[pista], 0f, -offsetZ);
        obs.SetActive(true);
        obstaculosAtivos.Add(obs);
    }

    // ═════════════════════════════════════════════
    //  RECICLAGEM (Object Pooling)
    // ═════════════════════════════════════════════
    private void ReciclarTilesDistantes()
    {
        // Z aumenta para frente (Unity: -Z é frente por convenção, mas depende do seu setup)
        float zLimiteRemocao = jogadorTransform.position.z + comprimentoTile * 2f;

        for (int i = tilesAtivos.Count - 1; i >= 0; i--)
        {
            if (tilesAtivos[i].transform.position.z > zLimiteRemocao)
            {
                DevolverTileAoPool(tilesAtivos[i]);
                tilesAtivos.RemoveAt(i);
            }
        }
    }

    private void ReciclarObstaculosDistantes()
    {
        float zLimiteRemocao = jogadorTransform.position.z + comprimentoTile * 2f;

        for (int i = obstaculosAtivos.Count - 1; i >= 0; i--)
        {
            if (obstaculosAtivos[i].transform.position.z > zLimiteRemocao)
            {
                DevolverObstaculoAoPool(obstaculosAtivos[i]);
                obstaculosAtivos.RemoveAt(i);
            }
        }
    }

    // ═════════════════════════════════════════════
    //  GERENCIAMENTO DO POOL
    // ═════════════════════════════════════════════
    private GameObject ObterTileDoPool()
    {
        if (poolTiles.Count > 0)
            return poolTiles.Dequeue();

        // Pool vazio: instancia em runtime (não deve ocorrer normalmente)
        Debug.LogWarning("LevelGenerator: Pool de tiles expandido em runtime.");
        GameObject novoTile = Instantiate(SortearTilePrefab(), transform);
        return novoTile;
    }

    private void DevolverTileAoPool(GameObject tile)
    {
        tile.SetActive(false);
        poolTiles.Enqueue(tile);
    }

    private GameObject ObterObstaculoDoPool()
    {
        if (poolObstaculos.Count > 0)
            return poolObstaculos.Dequeue();

        if (obstaculosPrefabs == null || obstaculosPrefabs.Length == 0)
            return null;

        Debug.LogWarning("LevelGenerator: Pool de obstáculos expandido em runtime.");
        return Instantiate(SortearObstaculoPrefab(), transform);
    }

    private void DevolverObstaculoAoPool(GameObject obs)
    {
        obs.SetActive(false);
        poolObstaculos.Enqueue(obs);
    }

    private GameObject SortearTilePrefab()
    {
        return tilesPrefabs[Random.Range(0, tilesPrefabs.Length)];
    }

    private GameObject SortearObstaculoPrefab()
    {
        return obstaculosPrefabs[Random.Range(0, obstaculosPrefabs.Length)];
    }

    // ═════════════════════════════════════════════
    //  API PÚBLICA
    // ═════════════════════════════════════════════
    public void Reiniciar()
    {
        foreach (var t in tilesAtivos) DevolverTileAoPool(t);
        tilesAtivos.Clear();
        foreach (var o in obstaculosAtivos) DevolverObstaculoAoPool(o);
        obstaculosAtivos.Clear();

        zProximoSpawn = 0f;
        totalTilesSpawnados = 0;
        SpawnarTilesIniciais();
    }

    public int GetTilesAtivos() => tilesAtivos.Count;
}

// ─────────────────────────────────────────────────────────
//  Obstaculo.cs  — cole em cada prefab de obstáculo
// ─────────────────────────────────────────────────────────
// using UnityEngine;
//
// public class Obstaculo : MonoBehaviour
// {
//     [Tooltip("Se true, o jogador morre ao tocar. Se false, apenas sofre dano.")]
//     public bool causaMorteInstantanea = false;
//     [Tooltip("Quantidade de dano causado (ignora se causaMorteInstantanea=true)")]
//     public int dano = 1;
//     [Tooltip("Tipo visual do obstáculo para feedback na UI")]
//     public string tipo = "bones"; // bones | beam | pit | skulls
// }
