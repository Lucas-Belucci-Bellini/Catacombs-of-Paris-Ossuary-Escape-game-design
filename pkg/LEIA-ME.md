# OSSUARY ESCAPE — Catacumbas de Paris
## Pacote de Lançamento v1.0

---

## 🎮 COMO JOGAR (PC)

### Opção rápida — sem instalação
1. Abra a pasta `game/`
2. Dê duplo clique em **`index.html`**
3. O jogo abre direto no seu navegador (Chrome, Firefox, Edge, Safari)

### Controles
| Tecla | Ação |
|-------|------|
| `← → ` ou `A D` | Trocar de pista |
| `↑` ou `W` ou `Espaço` | Pular |
| `↓` ou `S` | Deslizar |
| `P` ou `Esc` | Pausar |

---

## 📁 ESTRUTURA DO PACOTE

```
OssuaryEscape_PC_Package/
│
├── game/
│   └── index.html          ← JOGUE AQUI (abrir no navegador)
│
├── docs/
│   ├── OssuaryEscape_GDD_v02.docx   ← GDD completo (14 caps, versão final)
│   ├── OssuaryEscape_GDD.docx        ← GDD v0.1 (referência histórica)
│   └── README.md                      ← Arquitetura técnica e setup
│
├── src/
│   ├── godot/
│   │   ├── PlayerController.gd    ← Godot 4 GDScript
│   │   ├── LevelGenerator.gd
│   │   ├── AnkouChase.gd
│   │   └── GameManager.gd
│   └── unity/
│       ├── PlayerController.cs    ← Unity C# (URP)
│       ├── LevelGenerator.cs
│       ├── AnkouChase.cs
│       └── GameManager.cs
│
├── art_prompts/
│   └── prompt_library.jsx         ← 13 prompts (MJ / DALL·E 3 / SD)
│
└── LEIA-ME.md                     ← Este arquivo
```

---

## 🕹️ O JOGO (HTML5)

**Mechânicas implementadas:**
- 3 pistas com perspectiva de túnel em canvas 2D
- 7 tipos de obstáculos: Pilha de Ossos, Viga Podre, Abismo, Muro de Crânios, Lanças, Correntes, Carrinho de Mina
- 5 power-ups: Lanterna Sagrada, Pó de Ossos, Sprint Espectral, Ossada Sagrada, Véu de Sombra
- Sistema Ankou: aparece gradualmente, toca animação de captura ao chegar
- Câmera com lean, screen shake e efeito de lanterna com flickering
- Progressão de velocidade: 3.8 u/s → 10 u/s (cap em ~8.000m)
- Multiplicador dinâmico, sistema de combo de pistas, HUD completo
- Som procedural via Web Audio API (sem assets externos)
- Salvamento local: recorde e relíquias persistem entre sessões

---

## 🔧 PRÓXIMOS PASSOS PARA PRODUÇÃO

### Motor 3D (escolha um)
**Godot 4:**
```
1. Crie projeto Godot 4 com Rendering: Forward+
2. Copie scripts de src/godot/ para res://scripts/
3. Crie cenas: Player.tscn, Level.tscn, Ankou.tscn, GameManager.tscn
4. Configure Input Map: lane_left, lane_right, jump, slide
5. Adicione GameManager como AutoLoad
```

**Unity (URP):**
```
1. Crie projeto Unity 6 LTS com URP template
2. Copie scripts de src/unity/ para Assets/Scripts/
3. Tag do player: "Jogador"
4. Adicione GameManager à cena principal (persiste entre cenas)
5. Configure Input System para: MoveLeft, MoveRight, Jump, Slide
```

### Arte (use os prompts)
```
1. Abra art_prompts/prompt_library.jsx no navegador ou React DevTools
2. Filtre por categoria (Personagem, Cenário, Obstáculos, etc.)
3. Copie o prompt para Midjourney, DALL·E 3 ou Stable Diffusion
4. Substitua os placeholders Canvas 2D pelos assets gerados
```

---

## 📊 DESIGN — RESUMO DAS DECISÕES CHAVE

| Parâmetro | Valor |
|-----------|-------|
| Velocidade inicial | 3.8 u/s |
| Velocidade máxima | 10 u/s (cap) |
| Pistas | 3 (esq / centro / dir) |
| Vidas | 3 (ícones de crânio) |
| Moeda de Caronte | Ressuscita com Ankou em 50 pts, máx. 2/run |
| Multiplicador | Não reseta em dano leve; −0.5× em médio; reset em morte |
| Portal do Ankou | Exclusivo de tile (sem outros obstáculos) |
| Tutorial | Tiles 1–10 fixos, aleatório a partir do tile 11 |

---

## ✦ CRÉDITOS
Conceito e design: projeto original desenvolvido com Claude (Anthropic)
Engine do protótipo: HTML5 Canvas 2D + Web Audio API
Versão: 1.0 — Maio/2026
