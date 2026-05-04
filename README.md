# Catacombs-of-Paris-Ossuary-Escape-game-design

<div align="center">

```
╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║     ░█████╗░░██████╗░██████╗██╗░░░██╗░█████╗░██████╗░██╗░░░██╗     ║
║     ██╔══██╗██╔════╝██╔════╝██║░░░██║██╔══██╗██╔══██╗╚██╗░██╔╝     ║
║     ██║░░██║╚█████╗░╚█████╗░██║░░░██║███████║██████╔╝░╚████╔╝░     ║
║     ██║░░██║░╚═══██╗░╚═══██╗██║░░░██║██╔══██║██╔══██╗░░╚██╔╝░░     ║
║     ╚█████╔╝██████╔╝██████╔╝╚██████╔╝██║░░██║██║░░██║░░░██║░░░     ║
║     ░╚════╝░╚═════╝░╚═════╝░░╚═════╝░╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░     ║
║                                                                      ║
║              E  S  C  A  P  E                                        ║
║                       — Catacombs of Paris —                        ║
╚══════════════════════════════════════════════════════════════════════╝
```

<br/>

[![License](https://img.shields.io/badge/license-MIT-8a2018?style=flat-square&logo=opensourceinitiative&logoColor=white)](LICENSE)
[![HTML5](https://img.shields.io/badge/HTML5-Canvas_2D-b8943a?style=flat-square&logo=html5&logoColor=white)](game/index.html)
[![Godot](https://img.shields.io/badge/Godot-4.x_GDScript-4a7a8a?style=flat-square&logo=godotengine&logoColor=white)](src/godot/)
[![Unity](https://img.shields.io/badge/Unity-C%23_URP-3a3a3a?style=flat-square&logo=unity&logoColor=white)](src/unity/)
[![Status](https://img.shields.io/badge/status-prototype_v1.0-2a5a2a?style=flat-square)]()
[![Play Now](https://img.shields.io/badge/▶_Play_Now-open_in_browser-7c1a10?style=flat-square)](game/index.html)

<br/>

> *The Ankou does not chase you. It simply arrives.*

</div>

---

## ▌ WHAT IS THIS?

**Ossuary Escape** is a gothic endless runner set deep beneath Paris. You are **Léa Morel**, an urban explorer who has wandered too far into the forbidden galleries of the Catacombs. Behind you — unhurried, inevitable — walks **The Ankou**: a Celtic death specter in a decayed top hat, 7 feet of ancient bone wrapped in centuries of black silk, carrying a rusted scythe.

The lantern on your chest is the only light source. The tunnel narrows. The walls are made of skulls.

Run.

---

## ▌ GAME PREVIEW

```
╔═══════════════════════════════════════════════════════════════════╗
║ DISTANCE         │                        │              ANKOU    ║
║ ██ 2,847m  ×1.5  │    ✦ SPRINT ACTIVE ✦   │  ████████░░░ ▓▓▓     ║
║                  │                        │  💀 💀 💀            ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║       ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·  ·                  ║
║     💀💀💀         💀💀💀         💀💀💀                           ║
║    ┌─────┐    ╔═════════════════╗    ┌─────┐                     ║
║    │  💀 │    ║  💀  💀  💀  💀 ║    │  ▓  │    ← SKULL WALL     ║
║    │  💀 │    ║  💀  💀  💀  💀 ║    │  ▓  │                     ║
║    │ ███ │    ║  💀  💀  💀  💀 ║    │  ▓  │                     ║
║════│═════│════╚═════════════════╝════│═════│════ FLOOR ══════════║
║    │     │                           │     │                     ║
║    └─────┘                           └─────┘                     ║
║         ·  ·  ·  ·  [LÉA] ·  ·  ·  ·  ·  ·                      ║
║                       🏃                                          ║
║   LANE 1 (BLOCKED)   LANE 2 ✓      LANE 3 (BLOCKED)             ║
║                                                                   ║
║ ·············· TUNNEL PERSPECTIVE (800×600) ···················· ║
║                                                                   ║
║                        ·  ·  ·  ·  ·                             ║
║                    ·           👁️  👁️  ·  ← THE ANKOU            ║
║                 ·           APPROACHES  ·                        ║
╚═══════════════════════════════════════════════════════════════════╝
```

```
╔═══════════════════════════════════════════════════════════════════╗
║                     OBSTACLE GLOSSARY                            ║
╠════════════════╦══════════════╦═════════════════════════════════╣
║  NAME          ║  ACTION      ║  HITBOX SHAPE                   ║
╠════════════════╬══════════════╬═════════════════════════════════╣
║  Bone Pile  🦴  ║  JUMP  ↑    ║  ▓▓▓▓▓  (knee height)          ║
║  Rotted Beam   ║  SLIDE ↓    ║  ━━━━━━  (neck height)          ║
║  Dark Pit   🕳️  ║  JUMP  ↑    ║  ░░░░░░  (ground opening)      ║
║  Skull Wall 💀  ║  JUMP or ↓  ║  ▓▓▓▓▓▓ (archway passage)      ║
║  Iron Lances ⚔️ ║  JUMP  ↑    ║  ╿╿╿  (floor spikes)           ║
║  Chains     ⛓️  ║  SLIDE ↓    ║  ╌╌╌  (hanging, mid-air)       ║
║  Mine Cart  🚃  ║  JUMP or ↓  ║  ▓▓▓  (wide, requires timing)  ║
╚════════════════╩══════════════╩═════════════════════════════════╝
```

---

## ▌ PLAY IT NOW

The prototype runs entirely in the browser — no install, no engine, no dependencies.

```bash
# Option 1 — Just open the file
double-click  game/index.html

# Option 2 — Local server (avoids browser file restrictions)
cd game && python3 -m http.server 8080
# then open → http://localhost:8080
```

| Key | Action |
|-----|--------|
| `←` `→`  or  `A` `D` | Switch lanes |
| `↑`  or  `W`  or  `Space` | Jump |
| `↓`  or  `S` | Slide |
| `P`  or  `Esc` | Pause |

---

## ▌ THE ANKOU THREAT SYSTEM

The Ankou doesn't have a physical position on the map. It exists as a **threat value** from 0 to 100 — an abstract presence that grows heavier the longer you survive.

```
THREAT BAR  [████████████████████░░░░░░░░░░░░░░░]  58%
                                  ↑
                         Ankou starts appearing
                         as a faint silhouette
                         at the vanishing point

  0%  ──────────────────────────────────────── 100%
  SAFE   SHADOW   OUTLINE   DETAIL   RUSH   CAPTURE
         (78%)    (85%)     (92%)   (98%)  (100%)
```

**Factors that push the threat up:**
- Time elapsed (primary driver, accelerates with distance)
- Taking damage (−18 pts per hit, then resumes climbing)
- Dying (triggers the rush sequence regardless of value)

**Factors that push it back:**
- Collecting the **Veil of Shadow** power-up
- Surviving without damage (threat climbs slower at low speed)

---

## ▌ POWER-UPS

```
┌──────────────────────────────────────────────────────────────────┐
│  ✦ SACRED LANTERN   (480 frames)  →  doubles visibility radius   │
│  ✦ BONE DUST        (300 frames)  →  immunity to all obstacles   │
│  ✦ SPECTRAL SPRINT  (180 frames)  →  +40% speed, ghost trail     │
│  ✦ SACRED BONE      (instant)     →  +1 life (max 3)             │
│  ✦ VEIL OF SHADOW   (240 frames)  →  Ankou threat freezes        │
└──────────────────────────────────────────────────────────────────┘
```

---

## ▌ SPEED & DIFFICULTY CURVE

```
  Speed
  (u/s)
   10 ┤                                              ╭──────────
    9 ┤                                         ╭───╯
    8 ┤                                    ╭────╯
    7 ┤                               ╭───╯
    6 ┤                          ╭────╯
    5 ┤                    ╭─────╯
    4 ┤          ╭──────────╯
  3.8 ┼──────────╯
      └──────────┬─────────┬──────────┬──────────┬──────────
                500m     1500m      3000m       6000m     8000m+
                          │                │
                     dual obstacles    speed cap
                     start spawning    reached
```

---

## ▌ SCORE SYSTEM

```
  ┌─────────────────────────────────────────────────────────┐
  │  BASE SCORE:   +1 point per meter                       │
  │  MULTIPLIER:   ×1.0 → ×4.0  (builds without damage)    │
  │                                                         │
  │  MULTIPLIER RULES:                                      │
  │    Light damage  → no multiplier loss                   │
  │    Medium damage → −0.5×                                │
  │    Death (fatal) → reset to ×1.0                        │
  │                                                         │
  │  BONUS EVENTS:                                          │
  │    Lane combo (3 switches in 1 sec) → +200m             │
  │    Coin collected                   → +30m              │
  │    Charon's Coin (revive)           → Ankou → 50%       │
  └─────────────────────────────────────────────────────────┘
```

---

## ▌ REPOSITORY STRUCTURE

```
ossuary-escape/
│
├── game/
│   └── index.html            ← Self-contained HTML5 game (no deps)
│
├── src/
│   ├── godot/                ← Godot 4 GDScript implementation
│   │   ├── PlayerController.gd
│   │   ├── LevelGenerator.gd
│   │   ├── AnkouChase.gd
│   │   └── GameManager.gd
│   │
│   └── unity/                ← Unity C# (URP) implementation
│       ├── PlayerController.cs
│       ├── LevelGenerator.cs
│       ├── AnkouChase.cs
│       └── GameManager.cs
│
├── docs/
│   ├── OssuaryEscape_GDD_v02.docx   ← Full Game Design Document (14 chapters)
│   └── README.md                    ← Engine setup & architecture guide
│
├── art_prompts/
│   └── prompt_library.jsx    ← 13 prompt sets for MJ / DALL·E 3 / SD
│
└── README.md                 ← You are here
```

---

## ▌ ENGINE SETUP

<details>
<summary><strong>⚙️ Godot 4 Setup</strong></summary>

```
1. Create a Godot 4 project (Rendering: Forward+)
2. Copy scripts from src/godot/ → res://scripts/
3. Create scenes:
     Player.tscn     → CharacterBody3D + script PlayerController.gd
     Level.tscn      → Node3D + script LevelGenerator.gd
     Ankou.tscn      → Node3D + script AnkouChase.gd
     GameManager.tscn → Node + script GameManager.gd (AutoLoad)
4. Configure Input Map:
     lane_left   → A, Arrow Left
     lane_right  → D, Arrow Right
     jump        → W, Arrow Up, Space
     slide       → S, Arrow Down
5. Add GameManager as AutoLoad (Project → AutoLoad)
6. Export → HTML5 for web deployment
```

</details>

<details>
<summary><strong>⚙️ Unity Setup</strong></summary>

```
1. Create a Unity 6 LTS project (URP template)
2. Copy scripts from src/unity/ → Assets/Scripts/
3. Tag your player GameObject: "Jogador"
4. Add GameManager to the main scene (DontDestroyOnLoad is automatic)
5. Configure New Input System:
     MoveLeft    → Keyboard A / Left Arrow
     MoveRight   → Keyboard D / Right Arrow
     Jump        → Keyboard W / Space / Up Arrow
     Slide       → Keyboard S / Down Arrow
6. Set up URP pipeline asset and apply to Graphics Settings
```

</details>

<details>
<summary><strong>⚙️ Web Deployment (HTML5)</strong></summary>

```bash
# Deploy anywhere that serves static files

# Netlify
netlify deploy --dir=game/

# GitHub Pages
# Enable Pages on the repo → set source to /game folder

# Itch.io
# Upload game/index.html as a zip → enable "This file will be played in the browser"

# Vercel
vercel --name ossuary-escape game/
```

</details>

---

## ▌ ARCHITECTURE

```
                    ┌─────────────────────┐
                    │    GameManager      │  ← Singleton / AutoLoad
                    │  ─────────────────  │
                    │  state machine      │
                    │  score & lives      │
                    │  save / load        │
                    └──────────┬──────────┘
                               │ broadcasts events
                ┌──────────────┼──────────────┐
                ▼              ▼              ▼
     ┌──────────────┐  ┌─────────────┐  ┌──────────────┐
     │  Player      │  │  Level      │  │  Ankou       │
     │  Controller  │  │  Generator  │  │  Chase       │
     │ ──────────── │  │ ─────────── │  │ ──────────── │
     │  3 lanes     │  │  tile pool  │  │  threat 0-100│
     │  jump/slide  │  │  obstacles  │  │  5 states    │
     │  input map   │  │  coins/pups │  │  capture seq │
     └──────┬───────┘  └─────────────┘  └──────────────┘
            │
            ▼ collision events → GameManager
```

---

## ▌ GAME DESIGN DOCUMENT

The full GDD (`docs/OssuaryEscape_GDD_v02.docx`) covers 14 chapters:

| Chapter | Content |
|---------|---------|
| 0 | Critical Analysis & Design Consistency Review |
| 1 | Vision & Elevator Pitch |
| 2 | Narrative & World |
| 3 | Core Loop |
| 4 | Obstacle System (7 types + dual-spawn rules) |
| 5 | Power-Up System (5 types + timing tables) |
| 6 | Difficulty Balancing & Speed Curve |
| 7 | Cosmetics & Progression |
| 8 | **Game Feel** (camera params, juice table, cinematic death) |
| 9 | Audio / Visual Direction |
| 10 | **Tutorial** (tile-by-tile, first 10 tiles hard-coded) |
| 11 | **Player Personas** (Isabela, Rafael, Yuki, André) |
| 12 | **Retention** (D1/D7/D30 targets, daily challenges, seasonal events) |
| 13 | **Accessibility** (colorblind modes, reduced motion, horror-lite) |

---

## ▌ ART DIRECTION

All prompts in `art_prompts/prompt_library.jsx` follow this **visual bible**:

```
PALETTE ────────────────────────────────────────────────────────
  Primary light  →  #B8943A  (amber lantern, warm)
  Death accent   →  #7C1A10  (deep crimson, danger)
  Ankou glow     →  #00FF44  (putrid green, supernatural)
  Stone          →  #948252  (aged limestone)
  Bone           →  #C0A07A  (human bone, aged ivory)
  Void           →  #080504  (absolute tunnel darkness)

CAMERA ─────────────────────────────────────────────────────────
  FOV            60° default → 68° at high speed
  Lean           ±3.5° on lane switch (lerp 0.08)
  Shake          trauma² decay, 22-frame duration
  Vignette       dynamic radius tied to Ankou threat

LIGHTING ───────────────────────────────────────────────────────
  RULE: exactly ONE light source — the lantern on Léa's chest
  Radius         80–90px (flickers ±6px procedurally)
  Falloff        radial gradient, darkness at 260px
  Ankou approach adds chromatic aberration at threat > 70%
```

---

## ▌ KEY DESIGN DECISIONS

| Decision | Value | Rationale |
|----------|-------|-----------|
| Ankou position | Abstract 0–100 | Prevents teleport jank; creates dread not frustration |
| Speed cap | 10 u/s (~8,000m) | Preserves readability; skill ceiling not pixel-perfect |
| Tutorial | Tiles 1–10 fixed | Guarantees jump, slide, lane switch before chaos |
| Charon's Coin | Revives at 50% threat (not 100%) | Prevents pay-to-record abuse |
| Multiplier | Light dmg = no loss | Rewards survival over perfection |
| Portal of the Ankou | Tile-exclusive obstacle | Avoids overlap with instant-kill combos |
| Monetization | Cosmetic only | Competitive integrity maintained |

---

## ▌ ROADMAP

```
v1.0  ✅  HTML5 prototype — all core mechanics, 7 obstacles, 5 power-ups
v1.1  ◻   Audio pass — ambient cave drips, Ankou breath, bone crack SFX
v1.2  ◻   Art pass — replace canvas shapes with sprite assets
v1.3  ◻   Levels 2 & 3 — King's Crypts, Flooded Sewers biomes
v1.4  ◻   Cosmetics — skin system, Relic currency, daily shop
v2.0  ◻   Godot 4 / Unity 3D build — full engine implementation
v2.1  ◻   Mobile build — iOS + Android touch controls
v2.2  ◻   Online leaderboard — weekly ranked seasons
```

---

## ▌ CONTRIBUTING

```bash
git clone https://github.com/your-username/ossuary-escape.git
cd ossuary-escape

# The game has zero dependencies — edit and refresh
code game/index.html
# open in browser → changes visible on refresh
```

Pull requests welcome. Open an issue first for large changes.

---

## ▌ LICENSE

MIT — see [LICENSE](LICENSE) for details.

---

<div align="center">

```
  ╔═══════════════════════════════════════╗
  ║                                       ║
  ║   Run.  The Ankou does not tire.      ║
  ║                                       ║
  ║         👁️              👁️            ║
  ║                                       ║
  ╚═══════════════════════════════════════╝
```

*Made with dread, desperation, and Canvas 2D.*

</div>
