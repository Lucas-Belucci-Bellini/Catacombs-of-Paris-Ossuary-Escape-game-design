## AnkouChase.gd
## Attach to: Node3D  (filho da cena principal, com modelo 3D do Ankou como filho)
## Gerencia a perseguição do Ankou: distância, velocidade crescente,
## aparição visual gradual, áudio espacial e evento de captura.
##
## SETUP NO GODOT:
##   Node3D "AnkouChase" (este script)
##   ├── Node3D "Modelo"          <- mesh do Ankou (esqueleto animado)
##   │    └── AnimationPlayer     <- animações: "flutuar", "capturar"
##   ├── AudioStreamPlayer3D "Som" <- som ambiente do Ankou (loop)
##   └── GPUParticles3D "Neblina" <- efeito de neblina/fumaça (opcional)
##
## O Ankou não se move fisicamente pelo nível.
## A "distância" é um valor abstrato de 0-100 que representa
## o quanto ele está perto de capturar o jogador.

extends Node3D

# ─────────────────────────────────────────────
#  PARÂMETROS EXPORTADOS
# ─────────────────────────────────────────────
@export_group("Distância")
## Distância inicial (100 = muito longe, 0 = capturou)
@export var distancia_inicial: float = 100.0
## Quanto a distância diminui por segundo (velocidade base de aproximação)
@export var velocidade_aproximacao: float = 0.9
## Multiplicador de velocidade por segundo de jogo (dificuldade crescente)
@export var aceleracao_perseguicao: float = 0.012
## Quanto a distância diminui quando o jogador falha em um obstáculo
@export var penalidade_falha: float = 14.0
## Quanto a distância aumenta ao usar um power-up de impulsão
@export var bonus_powerup: float = 22.0

@export_group("Visual")
## A que distância o Ankou começa a aparecer (valor de distancia_atual)
@export var distancia_aparecimento: float = 75.0
@export var modelo: Node3D
@export var particulas_neblina: GPUParticles3D

@export_group("Áudio")
@export var audio_ankou: AudioStreamPlayer3D
## Volume em dB quando o Ankou está muito longe (-60 = inaudível)
@export var volume_longe_db: float = -60.0
## Volume máximo em dB quando está prestes a capturar
@export var volume_perto_db: float = -4.0

# ─────────────────────────────────────────────
#  ESTADO INTERNO
# ─────────────────────────────────────────────
var distancia_atual: float
var esta_perseguindo: bool = false
var _tempo_jogo: float = 0.0
var _capturou: bool = false
var _anim_ankou: AnimationPlayer = null

# ─────────────────────────────────────────────
#  SINAIS
# ─────────────────────────────────────────────
## Disparado quando o Ankou alcança o jogador (distância = 0)
signal ankou_capturou
## Disparado a cada frame com o valor atual de distância (para UI)
signal distancia_atualizada(valor: float)

# ═════════════════════════════════════════════
#  INICIALIZAÇÃO
# ═════════════════════════════════════════════
func _ready() -> void:
	distancia_atual = distancia_inicial

	# Conecta a sinais do GameManager (autoload)
	GameManager.dano_sofrido.connect(_ao_sofrer_dano)
	GameManager.powerup_ativado.connect(_ao_usar_powerup)

	if modelo:
		modelo.visible = false
		_anim_ankou = modelo.get_node_or_null("AnimationPlayer")
		if _anim_ankou:
			_anim_ankou.play("flutuar")

	if audio_ankou:
		audio_ankou.volume_db = volume_longe_db

# ═════════════════════════════════════════════
#  LOOP PRINCIPAL
# ═════════════════════════════════════════════
func _process(delta: float) -> void:
	if not esta_perseguindo or _capturou:
		return

	_tempo_jogo += delta

	# Velocidade de aproximação aumenta com o tempo
	var multi: float = 1.0 + _tempo_jogo * aceleracao_perseguicao
	distancia_atual -= velocidade_aproximacao * multi * delta
	distancia_atual = maxf(0.0, distancia_atual)

	emit_signal("distancia_atualizada", distancia_atual)
	_atualizar_visual()
	_atualizar_audio()

	if distancia_atual <= 0.0:
		_capturar_jogador()

# ═════════════════════════════════════════════
#  REAÇÃO A EVENTOS DO JOGO
# ═════════════════════════════════════════════
func _ao_sofrer_dano() -> void:
	## Ankou avança mais rápido quando jogador tropeça
	distancia_atual = maxf(0.0, distancia_atual - penalidade_falha)
	if distancia_atual <= 0.0:
		_capturar_jogador()

func _ao_usar_powerup() -> void:
	## Power-up de sprint afasta o Ankou
	distancia_atual = minf(distancia_inicial, distancia_atual + bonus_powerup)

# ═════════════════════════════════════════════
#  VISUAL DO ANKOU
# ═════════════════════════════════════════════
func _atualizar_visual() -> void:
	if not modelo:
		return

	# Progressão de 0 (longe) a 1 (capturando)
	var progresso: float = 1.0 - (distancia_atual / distancia_inicial)

	# Aparece gradualmente a partir de distancia_aparecimento
	var limiar: float = 1.0 - (distancia_aparecimento / distancia_inicial)
	var opacidade: float = clamp((progresso - limiar) / (1.0 - limiar), 0.0, 1.0)

	modelo.visible = opacidade > 0.01

	# Oscilação lateral espectral
	modelo.position.x = sin(_tempo_jogo * 1.1) * 0.35 * opacidade

	# Escala cresce ao aproximar (efeito de ameaça crescente)
	var escala_base: float = 0.5 + progresso * 1.0
	modelo.scale = Vector3(escala_base, escala_base, escala_base)

	# Atualiza opacidade do material (requer material com transparência ativa)
	var mesh: MeshInstance3D = modelo.get_node_or_null("Mesh")
	if mesh and mesh.get_surface_override_material_count() > 0:
		var mat: StandardMaterial3D = mesh.get_surface_override_material(0) as StandardMaterial3D
		if mat:
			mat.albedo_color.a = opacidade

	# Partículas de neblina ficam mais intensas
	if particulas_neblina:
		particulas_neblina.amount = int(opacidade * 40)

# ═════════════════════════════════════════════
#  ÁUDIO DO ANKOU
# ═════════════════════════════════════════════
func _atualizar_audio() -> void:
	if not audio_ankou:
		return
	var progresso: float = 1.0 - (distancia_atual / distancia_inicial)
	# Interpolação logarítmica para volume (mais natural para o ouvido)
	audio_ankou.volume_db = lerpf(volume_longe_db, volume_perto_db, progresso * progresso)

# ═════════════════════════════════════════════
#  CAPTURA DO JOGADOR
# ═════════════════════════════════════════════
func _capturar_jogador() -> void:
	if _capturou:
		return
	_capturou = true
	esta_perseguindo = false

	emit_signal("ankou_capturou")

	# Anima o Ankou avançando sobre a tela
	if _anim_ankou:
		_anim_ankou.play("capturar")

	# Notifica o jogador
	var jogador: Node = get_tree().get_first_node_in_group("jogador")
	if jogador and jogador.has_method("morrer"):
		jogador.morrer()

	GameManager.terminar_jogo()

# ═════════════════════════════════════════════
#  API PÚBLICA
# ═════════════════════════════════════════════
func iniciar_perseguicao() -> void:
	esta_perseguindo = true
	if audio_ankou and not audio_ankou.playing:
		audio_ankou.play()

func reiniciar() -> void:
	distancia_atual = distancia_inicial
	_tempo_jogo = 0.0
	_capturou = false
	esta_perseguindo = false
	if modelo:
		modelo.visible = false
		modelo.scale = Vector3.ONE

func get_distancia() -> float:
	return distancia_atual

func get_progresso_perigo() -> float:
	## Retorna 0.0 (seguro) a 1.0 (capturado) — útil para UI de barra de ameaça
	return 1.0 - (distancia_atual / distancia_inicial)
