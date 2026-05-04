#!/bin/bash
# Ossuary Escape — Launcher (macOS / Linux)
set -e

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║     OSSUARY ESCAPE — Launcher         ║"
echo "║       Catacombs of Paris v1.0         ║"
echo "╚═══════════════════════════════════════╝"
echo ""

# Verificar Node.js
if ! command -v node &> /dev/null; then
    echo "❌  Node.js não encontrado!"
    echo ""
    echo "Instale em: https://nodejs.org (versão 18 LTS ou superior)"
    echo "  macOS:  brew install node"
    echo "  Ubuntu: sudo apt install nodejs npm"
    exit 1
fi

NODEVER=$(node --version)
echo "✓  Node.js detectado: $NODEVER"
echo ""

# Navegar para o diretório do script
cd "$(dirname "$0")"

# Instalar dependências se necessário
if [ ! -f "node_modules/electron/dist/electron" ] && [ ! -f "node_modules/electron/dist/Electron.app/Contents/MacOS/Electron" ]; then
    echo "Instalando dependências (primeira vez, ~2 min)..."
    echo ""
    npm install --save-dev electron@29 electron-builder@24
    echo ""
    echo "✓  Dependências instaladas!"
    echo ""
fi

# Criar executável distribuível (opcional — descomente para buildar .app/.AppImage)
# echo "Gerando executável nativo..."
# npm run dist

echo "Iniciando Ossuary Escape..."
echo ""
npm start
