## PlayerController.gd
## Attach to: CharacterBody3D
## Controla movimento, pulo, deslize e troca de pistas do explorador.
## Suporta entrada por teclado (WASD / Setas) e swipe touchscreen.
##
## SETUP NO GODOT:
##   CharacterBody3D (este script)
##   ├── MeshInstance3D          <- modelo do personagem
##   ├── AnimationPlayer         <- animações: "correr", "pulo", "deslize", "morte"
##   ├── ColisaoNormal           <- CollisionShape3D (cápsula padrão, h=1.8)
##   ├── ColisaoDeslize          <- CollisionShape3D (cápsula baixa, h=0.9)
##   └── LanternaPeito          <- SpotLight3D apontando para frente
##
## PROJECT SETTINGS → Input Map — adicione as ações:
##   mover_esquerda : A, ArrowLeft
##   mover_direita  : D, ArrowRight
##   pular          : W, ArrowUp, Space
##   deslizar       : S, ArrowDown

extends CharacterBody3D

# ─────────────────────────────────────────────
#  PARÂMETROS EXPORTADOS (editáveis no editor)
# ─────────────────────────────────────────────
@export_group("Velocidade")
@export var velocidade_base: float = 8.0
## Quanto a velocidade aumenta por segundo de jogo
@export var aceleracao_por_segundo: float = 0.003

@export_group("Pistas")
## Posições X das 3 pistas (esquerda, centro, direita)
@export var posicoes_pista: Array[float] = [-2.0, 0.0, 2.0]
## Quão rápido o personagem desliza lateralmente entre pistas
@export var suavidade_troca_pista: float = 9.0

@export_group("Pulo")
@export var forca_pulo: float = 12.5
@export var gravidade: float = -30.0

@export_group("Deslize")
@export var duracao_deslize: float = 0.75

# ─────────────────────────────────────────────
#  REFERÊNCIAS (autoconfiguradas via @onready)
# ─────────────────────────────────────────────
@onready var animacao: AnimationPlayer = $AnimationPlayer
@onready var colisao_normal: CollisionShape3D = $ColisaoNormal
@onready var colisao_deslize: CollisionShape3D = $ColisaoDeslize

# ─────────────────────────────────────────────
#  ESTADO INTERNO
# ─────────────────────────────────────────────
var pista_atual: int = 1          # 0=esq · 1=centro · 2=dir
var esta_pulando: bool = false
var esta_deslizando: bool = false
var velocidade_atual: float
var velocidade_y: float = 0.0
var tempo_deslize_restante: float = 0.0
var esta_vivo: bool = true

## Posição de início do toque (para calcular swipe)
var _toque_inicio: Vector2 = Vector2.ZERO
const _LIMIAR_SWIPE: float = 45.0   # pixels mínimos para reconhecer gesto

# ─────────────────────────────────────────────
#  SINAIS
# ─────────────────────────────────────────────
## Emitido quando o personagem morre (Ankou capturou)
signal morreu
## Emitido a cada troca de pista (útil para UI / câmera)
signal pista_alterada(indice_pista: int)

# ═════════════════════════════════════════════
#  CICLO DE VIDA
# ═════════════════════════════════════════════
func _ready() -> void:
	velocidade_atual = velocidade_base
	colisao_deslize.disabled = true
	add_to_group("jogador")
	if animacao:
		animacao.play("correr")

func _process(delta: float) -> void:
	if not esta_vivo:
		return
	_processar_teclado()
	_atualizar_deslize(delta)
	_aumentar_velocidade(delta)

func _physics_process(delta: float) -> void:
	if not esta_vivo:
		return

	# --- Gravidade ---
	if is_on_floor():
		velocidade_y = -1.0        # pequeno valor negativo para manter no chão
		if esta_pulando:
			esta_pulando = false
	else:
		velocidade_y += gravidade * delta

	# --- Movimento para frente (eixo -Z no Godot) ---
	velocity.z = -velocidade_atual

	# --- Troca suave de pista (interpolação linear no eixo X) ---
	var alvo_x: float = posicoes_pista[pista_atual]
	velocity.x = (alvo_x - global_position.x) * suavidade_troca_pista

	# --- Componente vertical ---
	velocity.y = velocidade_y

	move_and_slide()

# ═════════════════════════════════════════════
#  ENTRADA — TECLADO / PC
# ═════════════════════════════════════════════
func _processar_teclado() -> void:
	if Input.is_action_just_pressed("mover_esquerda"):
		_trocar_pista(-1)
	elif Input.is_action_just_pressed("mover_direita"):
		_trocar_pista(1)

	if Input.is_action_just_pressed("pular") and is_on_floor() and not esta_deslizando:
		_pular()

	if Input.is_action_just_pressed("deslizar") and not esta_pulando:
		_iniciar_deslize()

# ═════════════════════════════════════════════
#  ENTRADA — SWIPE MOBILE
# ═════════════════════════════════════════════
func _input(event: InputEvent) -> void:
	if not esta_vivo:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			_toque_inicio = event.position
		else:
			_processar_swipe(event.position)

func _processar_swipe(posicao_fim: Vector2) -> void:
	var delta: Vector2 = posicao_fim - _toque_inicio
	if delta.length() < _LIMIAR_SWIPE:
		return   # gesto muito curto, ignora

	if abs(delta.x) >= abs(delta.y):
		# Swipe HORIZONTAL → troca de pista
		_trocar_pista(1 if delta.x > 0 else -1)
	else:
		# Swipe VERTICAL
		if delta.y < 0.0 and is_on_floor() and not esta_deslizando:
			_pular()       # swipe para cima → pula
		elif delta.y > 0.0 and not esta_pulando:
			_iniciar_deslize()  # swipe para baixo → desliza

# ═════════════════════════════════════════════
#  AÇÕES DE MOVIMENTO
# ═════════════════════════════════════════════
func _trocar_pista(direcao: int) -> void:
	var nova_pista: int = clamp(pista_atual + direcao, 0, 2)
	if nova_pista == pista_atual:
		return
	pista_atual = nova_pista
	emit_signal("pista_alterada", pista_atual)

func _pular() -> void:
	velocidade_y = forca_pulo
	esta_pulando = true
	if animacao:
		animacao.play("pulo")

func _iniciar_deslize() -> void:
	if esta_deslizando:
		return
	esta_deslizando = true
	tempo_deslize_restante = duracao_deslize
	# Troca a colisão para cápsula baixa (permite passar sob obstáculos)
	colisao_normal.disabled = true
	colisao_deslize.disabled = false
	if animacao:
		animacao.play("deslize")

func _terminar_deslize() -> void:
	esta_deslizando = false
	colisao_normal.disabled = false
	colisao_deslize.disabled = true
	if animacao:
		animacao.play("correr")

# ═════════════════════════════════════════════
#  ATUALIZAÇÕES CONTÍNUAS
# ═════════════════════════════════════════════
func _atualizar_deslize(delta: float) -> void:
	if not esta_deslizando:
		return
	tempo_deslize_restante -= delta
	if tempo_deslize_restante <= 0.0:
		_terminar_deslize()

func _aumentar_velocidade(delta: float) -> void:
	## Velocidade cresce linearmente com o tempo para aumentar o desafio
	velocidade_atual += aceleracao_por_segundo * delta * 60.0

# ═════════════════════════════════════════════
#  MORTE
# ═════════════════════════════════════════════
## Chamado pelo AnkouChase quando a distância chega a zero.
## Também pode ser chamado por colisão com obstáculo fatal.
func morrer() -> void:
	if not esta_vivo:
		return
	esta_vivo = false
	set_physics_process(false)
	set_process(false)
	if animacao:
		animacao.play("morte")
	emit_signal("morreu")

# ─────────────────────────────────────────────
#  GETTERS PÚBLICOS
# ─────────────────────────────────────────────
func get_velocidade() -> float:
	return velocidade_atual

func get_pista() -> int:
	return pista_atual
