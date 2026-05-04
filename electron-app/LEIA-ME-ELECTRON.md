# 🎮 Ossuary Escape — App para PC (Electron)

## Como usar este pacote

### ▶ OPÇÃO 1 — Jogar agora (mais fácil)
Requer: **Node.js** instalado ([nodejs.org](https://nodejs.org) — versão 18+)

**Windows:**
```
Dê duplo clique em: JOGAR-WINDOWS.bat
```
**macOS / Linux:**
```bash
chmod +x jogar-mac-linux.sh
./jogar-mac-linux.sh
```
Na primeira vez baixa as dependências (~80MB). Nas próximas abre instantaneamente.

---

### 📦 OPÇÃO 2 — Gerar .exe distribuível (para distribuir sem Node.js)
**Windows:**
```
Dê duplo clique em: GERAR-EXE-WINDOWS.bat
```
Gera um arquivo em `dist/` que qualquer PC Windows pode abrir, sem precisar instalar nada.

**macOS:**
```bash
./jogar-mac-linux.sh   # instala deps primeiro
npx electron-builder --mac dmg
```

**Linux:**
```bash
./jogar-mac-linux.sh   # instala deps primeiro
npx electron-builder --linux AppImage
```

---

## ⌨️ Controles in-game
| Tecla | Ação |
|-------|------|
| `← →` ou `A D` | Trocar de pista |
| `↑` ou `W` ou `Espaço` | Pular |
| `↓` ou `S` | Deslizar |
| `P` ou `Esc` | Pausar |
| `F11` | Tela cheia |

---

## 📁 Estrutura do projeto
```
ossuary-escape-electron/
├── main.js              ← processo principal Electron
├── preload.js           ← bridge segura renderer↔main
├── package.json         ← configuração do projeto
├── game/
│   └── index.html       ← o jogo completo (HTML5 Canvas)
├── build/
│   ├── icon.png         ← ícone (Linux / macOS)
│   └── icon.ico         ← ícone (Windows)
├── JOGAR-WINDOWS.bat         ← lançar no Windows
├── GERAR-EXE-WINDOWS.bat     ← gerar .exe standalone
└── jogar-mac-linux.sh        ← lançar no macOS/Linux
```

---

## 🔧 Comandos manuais (avançado)
```bash
# Instalar dependências
npm install --save-dev electron@29 electron-builder@24

# Rodar em modo dev
npm start

# Gerar executável Windows (.exe portable)
npx electron-builder --win portable

# Gerar AppImage Linux
npx electron-builder --linux AppImage

# Gerar DMG macOS
npx electron-builder --mac dmg
```

---

## ℹ️ Por que precisa de Node.js?
O Electron é um framework que empacota apps web como apps desktop.  
Para **jogar**, o Node.js é necessário apenas na primeira vez (para instalar o Electron).  
Para **distribuir** o jogo sem dependências, use `GERAR-EXE-WINDOWS.bat` — o .exe gerado funciona em qualquer PC.
