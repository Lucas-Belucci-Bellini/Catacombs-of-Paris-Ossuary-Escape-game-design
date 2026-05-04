@echo off
chcp 65001 >nul
title Ossuary Escape — Setup

echo.
echo  ╔═══════════════════════════════════════╗
echo  ║     OSSUARY ESCAPE — Instalador       ║
echo  ║       Catacombs of Paris v1.0         ║
echo  ╚═══════════════════════════════════════╝
echo.

:: Verificar Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ERRO] Node.js nao encontrado!
    echo.
    echo  Instale o Node.js em: https://nodejs.org
    echo  Versao recomendada: 18 LTS ou superior
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%v in ('node --version') do set NODEVER=%%v
echo  Node.js detectado: %NODEVER%
echo.

:: Verificar se node_modules existe
if exist "node_modules\electron\dist\electron.exe" (
    echo  Dependencias ja instaladas. Iniciando jogo...
    goto :launch
)

echo  Instalando dependencias (primeira vez, pode demorar ~2 min)...
echo  Aguarde...
echo.

call npm install --save-dev electron@29 electron-builder@24 2>nul
if %errorlevel% neq 0 (
    echo  [ERRO] Falha ao instalar dependencias.
    echo  Verifique sua conexao com a internet e tente novamente.
    pause
    exit /b 1
)

echo.
echo  ✓ Dependencias instaladas com sucesso!
echo.

:launch
echo  Iniciando Ossuary Escape...
echo.
start "" cmd /c "npm start && pause"
echo  Jogo iniciado! Esta janela pode ser fechada.
timeout /t 3 >nul
exit /b 0
