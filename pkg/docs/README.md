# Ossuary Escape — Documentação de Código

## Estrutura dos Scripts

```
ossuary-escape/
├── godot/                     ← Godot 4 (GDScript)
│   ├── PlayerController.gd    → Movimento, pulo, deslize, swipe
│   ├── LevelGenerator.gd      → Geração infinita + Object Pooling
│   ├── AnkouChase.gd          → Perseguição, visual, áudio, captura
│   └── GameManager.gd         → Singleton: estado, pontuação, vidas
│
└── unity/                     ← Unity 2022+ (C#)
    ├── PlayerController.cs    → Movimento, pulo, deslize, swipe
    ├── LevelGenerator.cs      → Geração infinita + Object Pooling
    ├── AnkouChase.cs          → Perseguição, visual, áudio, captura
    └── GameManager.cs         → Singleton: estado, pontuação, vidas
```

---

## Godot 4 — Setup Rápido

### 1. Cena Principal
```
Main (Node3D)
├── GameManager          ← Autoload (ver abaixo)
├── WorldEnvironment     ← Iluminação escura das catacumbas
├── DirectionalLight3D   ← Luz fraca geral
├── Jogador (CharacterBody3D)
│   ├── PlayerController.gd
│   ├── MeshInstance3D
│   ├── AnimationPlayer
│   ├── ColisaoNormal (CollisionShape3D) — cápsula H=1.8
│   ├── ColisaoDeslize (CollisionShape3D) — cápsula H=0.9
│   └── SpotLight3D "Lanterna"
├── LevelGenerator (Node3D)
│   └── LevelGenerator.gd
└── AnkouChase (Node3D)
    ├── AnkouChase.gd
    ├── Modelo (Node3D)
    │   └── AnimationPlayer
    └── AudioStreamPlayer3D
```

### 2. Autoload do GameManager
```
Project → Project Settings → Autoload
+ → res://GameManager.gd → Nome: "GameManager"
```

### 3. Input Map
```
Project → Project Settings → Input Map
Adicione:
  mover_esquerda : A, Left Arrow
  mover_direita  : D, Right Arrow
  pular          : W, Up Arrow, Space
  deslizar       : S, Down Arrow
```

### 4. Tags de Grupos
O jogador deve estar no grupo `"jogador"`:
```gdscript
# Em PlayerController.gd _ready():
add_to_group("jogador")
```

---

## Unity — Setup Rápido

### 1. Hierarquia da Cena
```
Main Camera
Directional Light (escuro)
GameManager (GameObject)
  └── GameManager.cs

Jogador (GameObject)
  ├── CharacterController  (Height 1.8, Center Y=0.9)
  ├── PlayerController.cs
  ├── Animator
  └── AudioSource

LevelGenerator (GameObject)
  └── LevelGenerator.cs

Ankou (GameObject)
  ├── AnkouChase.cs
  ├── AudioSource
  └── Modelo3D
      └── Animator
```

### 2. Tags
- Adicione a tag `"Jogador"` ao GameObject do personagem
- `Edit → Project Settings → Tags and Layers → Tags → +`

### 3. Configurar Prefabs de Obstáculo
Cada prefab de obstáculo precisa:
- `Collider` com `Is Trigger = true`
- Script `Obstaculo.cs` (código incluído como comentário em LevelGenerator.cs)

### 4. Camadas de Física
Recomendado:
- Layer 8: `Chão`
- Layer 9: `Obstáculos`
- Layer 10: `Coletáveis`

---

## Arquitetura de Comunicação

```
PlayerController ──(OnMorreu)──────────────→ AnkouChase / UI
LevelGenerator ────(obstáculo colidiu)──────→ GameManager.RegistrarDano()
GameManager ───────(OnDanoSofrido)──────────→ AnkouChase (penalidade)
GameManager ───────(OnPowerUpAtivado)───────→ AnkouChase (bonus distância)
AnkouChase ────────(OnAnkouCapturou)────────→ GameManager.TerminarJogo()
GameManager ───────(OnJogoEncerrado)────────→ UI (tela de game over)
```

---

## Tabela de Obstáculos

| Nome              | Ação do Jogador | Falha    | Raridade |
|-------------------|-----------------|----------|----------|
| Pilha de Ossos    | Pular           | Dano     | Comum    |
| Viga de Madeira   | Deslizar        | Dano     | Comum    |
| Poço de Escuridão | Pular           | Morte    | Incomum  |
| Muralha de Crânios| Pular ou Deslizar| Dano    | Incomum  |
| Armadilha Medieval| Pular           | Morte    | Raro     |

---

## Power-Ups

| Nome          | Efeito                            | Duração |
|---------------|-----------------------------------|---------|
| Sprint        | Afasta Ankou + boost velocidade   | 3s      |
| Escudo Ossos  | Imunidade total a danos           | 5s      |
| Lanterna      | Revela obstáculos mais cedo       | 8s      |
| Ossada Sagrada| +1 vida (máx 3)                   | Instantâneo |
