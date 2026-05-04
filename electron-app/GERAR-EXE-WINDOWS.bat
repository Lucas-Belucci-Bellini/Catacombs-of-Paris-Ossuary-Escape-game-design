@echo off
chcp 65001 >nul
title Ossuary Escape — Build Distribuivel

echo.
echo  ╔═══════════════════════════════════════════╗
echo  ║   OSSUARY ESCAPE — Gerar Executavel       ║
echo  ║   Cria um .exe sem precisar de Node.js    ║
echo  ╚═══════════════════════════════════════════╝
echo.
echo  Este processo vai criar um arquivo .exe standalone
echo  em dist\win-unpacked\ que qualquer PC pode executar.
echo.
echo  REQUISITOS: Node.js instalado neste computador
echo  TEMPO: ~5-10 minutos (download Electron ~80MB)
echo.

node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ERRO] Node.js nao encontrado. Instale em nodejs.org
    pause
    exit /b 1
)

echo  Instalando dependencias...
call npm install --save-dev electron@29 electron-builder@24
if %errorlevel% neq 0 goto :erro

echo.
echo  Gerando executavel Windows (.exe portable)...
call npx electron-builder --win portable
if %errorlevel% neq 0 goto :erro

echo.
echo  ═══════════════════════════════════════════
echo  ✓ PRONTO! Executavel gerado em:
echo    dist\
echo.
echo  Distribua a pasta ou o arquivo .exe para
echo  qualquer PC Windows — sem instalar Node.js!
echo  ═══════════════════════════════════════════
echo.
pause
exit /b 0

:erro
echo.
echo  [ERRO] Falha no build. Verifique internet e tente novamente.
pause
exit /b 1
