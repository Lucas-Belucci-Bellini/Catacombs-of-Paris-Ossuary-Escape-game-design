## GameManager.gd
## Autoload / Singleton  (adicionar em Project → Project Settings → Autoload)
## Nome do Autoload: "GameManager"
##
## Central de estado do jogo. Todos os outros scripts se comunicam
## através dos sinais e métodos deste arquivo.
##
## ADICIONAR AO AUTOLOAD:
##   Project Settings → Autoload → + → res://GameManager.gd → Nome: GameManager

extends Node

# ─────────────────────────────────────────────
#  ESTADOS DO JOGO
# ─────────────────────────────────────────────
enum Estado {
	MENU,       # Tela inicial
	JOGANDO,    # Partida em andamento
	PAUSADO,    # Jogo pausado
	GAME_OVER   # Jogador capturado pelo Ankou
}

var estado: Estado = Estado.MENU

# ─────────────────────────────────────────────
#  DADOS DA PARTIDA
# ─────────────────────────────────────────────
var pontuacao: int = 0
var recorde: int = 0
var vidas: int = 3           # Jogador aguenta 3 falhas antes de ser capturado
var moedas: int = 0          # Relíquias coletadas (para loja de skins)
var tempo_partida: float = 0.0
var invencivel: bool = false
var _tempo_invencivel: float = 0.0

const DURACAO_INVENCIBILIDADE: float = 2.0   # segundos de imunidade após falha
const CHAVE_RECORDE: String = "ossuary_recorde"
const CHAVE_MOEDAS: String = "ossuary_moedas"

# ─────────────────────────────────────────────
#  SINAIS GLOBAIS
# ─────────────────────────────────────────────
## Emitido quando o jogador sofre dano (para AnkouChase aumentar velocidade)
signal dano_sofrido
## Emitido ao ativar qualquer power-up
signal powerup_ativado
## Emitido ao iniciar uma partida
signal jogo_iniciado
## Emitido quando o jogo termina, com a pontuação final
signal jogo_encerrado(pontuacao_final: int, e_novo_recorde: bool)
## Emitido a cada ponto somado (para atualizar a UI)
signal pontuacao_alterada(nova_pontuacao: int)
## Emitido quando vidas mudam (para UI de corações)
signal vidas_alteradas(novas_vidas: int)

# ═════════════════════════════════════════════
#  CICLO DE VIDA
# ═════════════════════════════════════════════
func _ready() -> void:
	_carregar_dados_salvos()
	process_mode = Node.PROCESS_MODE_ALWAYS  # continua rodando mesmo com pause

func _process(delta: float) -> void:
	if estado != Estado.JOGANDO:
		return

	tempo_partida += delta

	# Pontuação baseada em distância percorrida (tempo × velocidade aproximada)
	var pts_por_segundo: int = int(10.0 + tempo_partida * 0.5)
	pontuacao += int(pts_por_segundo * delta)
	emit_signal("pontuacao_alterada", pontuacao)

	# Conta regressiva da invencibilidade
	if invencivel:
		_tempo_invencivel -= delta
		if _tempo_invencivel <= 0.0:
			invencivel = false

# ═════════════════════════════════════════════
#  CONTROLE DE FLUXO DO JOGO
# ═════════════════════════════════════════════
func iniciar_jogo() -> void:
	pontuacao = 0
	vidas = 3
	tempo_partida = 0.0
	invencivel = false
	_tempo_invencivel = 0.0
	estado = Estado.JOGANDO
	get_tree().paused = false
	emit_signal("jogo_iniciado")
	emit_signal("pontuacao_alterada", 0)
	emit_signal("vidas_alteradas", 3)

func pausar() -> void:
	if estado != Estado.JOGANDO:
		return
	estado = Estado.PAUSADO
	get_tree().paused = true

func retomar() -> void:
	if estado != Estado.PAUSADO:
		return
	estado = Estado.JOGANDO
	get_tree().paused = false

func terminar_jogo() -> void:
	if estado == Estado.GAME_OVER:
		return
	estado = Estado.GAME_OVER

	var e_novo_recorde: bool = pontuacao > recorde
	if e_novo_recorde:
		recorde = pontuacao
	_salvar_dados()

	emit_signal("jogo_encerrado", pontuacao, e_novo_recorde)

# ═════════════════════════════════════════════
#  SISTEMA DE DANO E INVENCIBILIDADE
# ═════════════════════════════════════════════
## Chamado por obstáculos ou pelo AnkouChase
func registrar_dano(quantidade: int = 1) -> void:
	if invencivel or estado != Estado.JOGANDO:
		return

	vidas = max(0, vidas - quantidade)
	invencivel = true
	_tempo_invencivel = DURACAO_INVENCIBILIDADE

	emit_signal("dano_sofrido")
	emit_signal("vidas_alteradas", vidas)

	if vidas <= 0:
		terminar_jogo()

# ═════════════════════════════════════════════
#  SISTEMA DE POWER-UPS
# ═════════════════════════════════════════════
## Tipos de power-up disponíveis
enum PowerUp {
	SPRINT,        # Impulsão — afasta Ankou e aumenta velocidade
	ESCUDO_OSSOS,  # Imunidade temporária a danos
	LANTERNA,      # Revela obstáculos com antecedência maior
	OSSADA_SAGRADA # Vida extra (máx 3)
}

func ativar_powerup(tipo: PowerUp) -> void:
	emit_signal("powerup_ativado")
	match tipo:
		PowerUp.SPRINT:
			_ativar_sprint()
		PowerUp.ESCUDO_OSSOS:
			_ativar_escudo()
		PowerUp.LANTERNA:
			_ativar_lanterna()
		PowerUp.OSSADA_SAGRADA:
			_ativar_vida_extra()

func _ativar_sprint() -> void:
	## AnkouChase captura o sinal "powerup_ativado" e afasta o Ankou
	pass  # Lógica já está no AnkouChase._ao_usar_powerup()

func _ativar_escudo() -> void:
	invencivel = true
	_tempo_invencivel = 5.0  # 5 segundos de imunidade

func _ativar_lanterna() -> void:
	## Aumenta o alcance de visão (comunicar via sinal a câmera/luz)
	pass  # Implemente conforme o setup de luz da cena

func _ativar_vida_extra() -> void:
	vidas = min(3, vidas + 1)
	emit_signal("vidas_alteradas", vidas)

# ═════════════════════════════════════════════
#  COLEÇÃO DE RELÍQUIAS (MOEDAS)
# ═════════════════════════════════════════════
func coletar_reliquia(valor: int = 1) -> void:
	moedas += valor

# ═════════════════════════════════════════════
#  PERSISTÊNCIA (SAVE / LOAD)
# ═════════════════════════════════════════════
func _salvar_dados() -> void:
	var config := ConfigFile.new()
	config.set_value("progresso", CHAVE_RECORDE, recorde)
	config.set_value("progresso", CHAVE_MOEDAS, moedas)
	config.save("user://ossuary_save.cfg")

func _carregar_dados_salvos() -> void:
	var config := ConfigFile.new()
	if config.load("user://ossuary_save.cfg") == OK:
		recorde = config.get_value("progresso", CHAVE_RECORDE, 0)
		moedas  = config.get_value("progresso", CHAVE_MOEDAS, 0)

# ═════════════════════════════════════════════
#  GETTERS PÚBLICOS
# ═════════════════════════════════════════════
func get_pontuacao() -> int:
	return pontuacao

func get_recorde() -> int:
	return recorde

func get_vidas() -> int:
	return vidas

func get_tempo() -> float:
	return tempo_partida

func esta_jogando() -> bool:
	return estado == Estado.JOGANDO
