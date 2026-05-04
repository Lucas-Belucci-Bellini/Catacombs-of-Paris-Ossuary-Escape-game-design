## LevelGenerator.gd
## Attach to: Node3D  (filho direto da cena principal)
## Gera infinitamente tiles de túnel e obstáculos das catacumbas.
## Usa Object Pooling para não instanciar/destruir objetos em runtime,
## mantendo a performance estável em dispositivos mobile.
##
## SETUP NO GODOT:
##   Node3D "LevelGenerator" (este script)
##
##   No Inspector, preencha os arrays:
##     tiles_prefabs      → PackedScenes de túneis (ex: tunel_reto.tscn)
##     obstaculos_prefabs → PackedScenes de obstáculos (ex: pilha_cranios.tscn)
##
##   Cada tile prefab deve ter comprimento de exatamente COMPRIMENTO_TILE
##   unidades ao longo do eixo -Z, com origem em (0,0,0).
##
##   Cada obstáculo prefab deve ter um Area3D com script que emite
##   sinal ao detectar o jogador (veja Obstaculo.gd de exemplo no final).

extends Node3D

# ─────────────────────────────────────────────
#  PARÂMETROS EXPORTADOS
# ─────────────────────────────────────────────
@export_group("Prefabs")
## Prefabs dos segmentos de túnel. O gerador sorteia aleatoriamente.
@export var tiles_prefabs: Array[PackedScene] = []
## Prefabs dos obstáculos (pilha de ossos, viga, poço, muralha de crânios).
@export var obstaculos_prefabs: Array[PackedScene] = []

@export_group("Configuração")
## Comprimento de cada tile em unidades do Godot (deve coincidir com o modelo)
@export var comprimento_tile: float = 24.0
## Quantos tiles ficam visíveis/ativos simultâneamente à frente do jogador
@export var tiles_a_frente: int = 7
## Posições X das três pistas
@export var posicoes_pista: Array[float] = [-2.0, 0.0, 2.0]
## Chance (0-1) de um obstáculo aparecer em cada tile (exceto os iniciais)
@export var chance_obstaculo: float = 0.60
## Tiles iniciais sem obstáculos (para o jogador ter tempo de se adaptar)
@export var tiles_livres_iniciais: int = 4

# ─────────────────────────────────────────────
#  POOLS DE OBJETOS
# ─────────────────────────────────────────────
var _pool_tiles: Array[Node3D] = []
var _pool_obstaculos: Array[Node3D] = []
var _tiles_ativos: Array[Node3D] = []
var _obstaculos_ativos: Array[Node3D] = []

# ─────────────────────────────────────────────
#  ESTADO INTERNO
# ─────────────────────────────────────────────
## Posição Z do próximo tile a spawnar (avança negativamente)
var _z_proximo_spawn: float = 0.0
## Conta quantos tiles foram spawnados (para controle dos tiles iniciais)
var _total_tiles_spawnados: int = 0

var _jogador: CharacterBody3D = null
var _z_jogador_anterior: float = 0.0

# Sinais
signal obstaculo_encontrado(tipo: String)

# ═════════════════════════════════════════════
#  INICIALIZAÇÃO
# ═════════════════════════════════════════════
func _ready() -> void:
	_jogador = get_tree().get_first_node_in_group("jogador") as CharacterBody3D

	if tiles_prefabs.is_empty():
		push_error("LevelGenerator: Nenhum tile_prefab configurado!")
		return

	_pre_aquecer_pools()
	_spawnar_tiles_iniciais()

func _pre_aquecer_pools() -> void:
	## Instancia objetos antecipadamente para evitar stutters durante o jogo
	var total_tiles_pool: int = tiles_a_frente + 4
	for i in range(total_tiles_pool):
		var prefab: PackedScene = _sortear_tile_prefab()
		var tile: Node3D = prefab.instantiate()
		tile.visible = false
		add_child(tile)
		_pool_tiles.append(tile)

	var total_obs_pool: int = 16
	for i in range(total_obs_pool):
		if obstaculos_prefabs.is_empty():
			break
		var prefab: PackedScene = _sortear_obstaculo_prefab()
		var obs: Node3D = prefab.instantiate()
		obs.visible = false
		add_child(obs)
		_pool_obstaculos.append(obs)

func _spawnar_tiles_iniciais() -> void:
	for i in range(tiles_a_frente):
		_spawnar_tile()

# ═════════════════════════════════════════════
#  LOOP PRINCIPAL
# ═════════════════════════════════════════════
func _process(_delta: float) -> void:
	if _jogador == null:
		_jogador = get_tree().get_first_node_in_group("jogador") as CharacterBody3D
		return

	var z_jogador: float = _jogador.global_position.z

	# Spawna novo tile quando o jogador avança suficientemente
	_verificar_e_spawnar(z_jogador)

	# Remove tiles que ficaram muito atrás do jogador
	_reciclar_tiles_distantes(z_jogador)
	_reciclar_obstaculos_distantes(z_jogador)

func _verificar_e_spawnar(z_jogador: float) -> void:
	## O spawn acontece quando a borda frontal dos tiles visíveis
	## está a menos de (tiles_a_frente - 2) tiles de distância.
	var limite_spawn_z: float = z_jogador - comprimento_tile * float(tiles_a_frente - 2)
	if _z_proximo_spawn > limite_spawn_z:
		_spawnar_tile()

# ═════════════════════════════════════════════
#  SPAWN DE TILES
# ═════════════════════════════════════════════
func _spawnar_tile() -> void:
	var tile: Node3D = _obter_tile_do_pool()
	if tile == null:
		push_warning("LevelGenerator: Pool de tiles vazio!")
		return

	tile.global_position = Vector3(0.0, 0.0, _z_proximo_spawn)
	tile.visible = true
	_tiles_ativos.append(tile)

	_total_tiles_spawnados += 1
	_z_proximo_spawn -= comprimento_tile  # avança para o próximo slot

	# Tenta spawnar obstáculo neste tile (ignora os primeiros)
	if _total_tiles_spawnados > tiles_livres_iniciais and randf() < chance_obstaculo:
		_spawnar_obstaculo_no_tile(tile)

func _spawnar_obstaculo_no_tile(tile: Node3D) -> void:
	if obstaculos_prefabs.is_empty():
		return

	var obs: Node3D = _obter_obstaculo_do_pool()
	if obs == null:
		return

	# Sorteia pista e posição Z dentro do tile
	var pista: int = randi() % posicoes_pista.size()
	var offset_z: float = randf_range(comprimento_tile * 0.25, comprimento_tile * 0.75)

	obs.global_position = tile.global_position + Vector3(posicoes_pista[pista], 0.0, -offset_z)
	obs.visible = true
	_obstaculos_ativos.append(obs)

# ═════════════════════════════════════════════
#  RECICLAGEM (Object Pooling)
# ═════════════════════════════════════════════
func _reciclar_tiles_distantes(z_jogador: float) -> void:
	## Um tile é reciclado quando fica mais de 2 tiles atrás do jogador
	var z_limite_remocao: float = z_jogador + comprimento_tile * 2.0

	var i: int = _tiles_ativos.size() - 1
	while i >= 0:
		var tile: Node3D = _tiles_ativos[i]
		if tile.global_position.z > z_limite_remocao:
			_devolver_tile_ao_pool(tile)
			_tiles_ativos.remove_at(i)
		i -= 1

func _reciclar_obstaculos_distantes(z_jogador: float) -> void:
	var z_limite_remocao: float = z_jogador + comprimento_tile * 2.0

	var i: int = _obstaculos_ativos.size() - 1
	while i >= 0:
		var obs: Node3D = _obstaculos_ativos[i]
		if obs.global_position.z > z_limite_remocao:
			_devolver_obstaculo_ao_pool(obs)
			_obstaculos_ativos.remove_at(i)
		i -= 1

# ═════════════════════════════════════════════
#  GERENCIAMENTO DO POOL
# ═════════════════════════════════════════════
func _obter_tile_do_pool() -> Node3D:
	if not _pool_tiles.is_empty():
		return _pool_tiles.pop_back()
	# Pool vazio: instancia emergencialmente (não deve acontecer normalmente)
	push_warning("LevelGenerator: Pool de tiles expandido em runtime.")
	var tile: Node3D = _sortear_tile_prefab().instantiate()
	add_child(tile)
	return tile

func _devolver_tile_ao_pool(tile: Node3D) -> void:
	tile.visible = false
	_pool_tiles.append(tile)

func _obter_obstaculo_do_pool() -> Node3D:
	if not _pool_obstaculos.is_empty():
		return _pool_obstaculos.pop_back()
	if obstaculos_prefabs.is_empty():
		return null
	push_warning("LevelGenerator: Pool de obstáculos expandido em runtime.")
	var obs: Node3D = _sortear_obstaculo_prefab().instantiate()
	add_child(obs)
	return obs

func _devolver_obstaculo_ao_pool(obs: Node3D) -> void:
	obs.visible = false
	_pool_obstaculos.append(obs)

# ─────────────────────────────────────────────
#  SORTEIO DE PREFABS
# ─────────────────────────────────────────────
func _sortear_tile_prefab() -> PackedScene:
	return tiles_prefabs[randi() % tiles_prefabs.size()]

func _sortear_obstaculo_prefab() -> PackedScene:
	return obstaculos_prefabs[randi() % obstaculos_prefabs.size()]

# ═════════════════════════════════════════════
#  API PÚBLICA
# ═════════════════════════════════════════════
## Retorna o número de tiles ativos (útil para debug)
func get_tiles_ativos() -> int:
	return _tiles_ativos.size()

## Reinicia o gerador (chamado pelo GameManager no restart)
func reiniciar() -> void:
	for tile in _tiles_ativos:
		_devolver_tile_ao_pool(tile)
	_tiles_ativos.clear()
	for obs in _obstaculos_ativos:
		_devolver_obstaculo_ao_pool(obs)
	_obstaculos_ativos.clear()
	_z_proximo_spawn = 0.0
	_total_tiles_spawnados = 0
	_spawnar_tiles_iniciais()

# ═════════════════════════════════════════════
#  EXEMPLO: Obstaculo.gd  (cole em cada prefab de obstáculo)
# ═════════════════════════════════════════════
# extends Area3D
#
# @export var tipo: String = "bones"  # "bones" | "beam" | "pit" | "skulls"
# @export var causa_morte_instantanea: bool = false
# @export var dano: int = 1
#
# func _ready() -> void:
#     body_entered.connect(_ao_colidir)
#
# func _ao_colidir(corpo: Node3D) -> void:
#     if not corpo.is_in_group("jogador"):
#         return
#     if causa_morte_instantanea:
#         corpo.morrer()
#     else:
#         GameManager.registrar_dano(dano)
