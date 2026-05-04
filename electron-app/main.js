const { app, BrowserWindow, Menu, shell, ipcMain } = require('electron');
const path = require('path');

// Manter referência global para evitar garbage collection
let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 860,
    height: 680,
    minWidth: 820,
    minHeight: 640,
    title: 'Ossuary Escape — Catacombs of Paris',
    backgroundColor: '#000000',
    icon: path.join(__dirname, 'build', process.platform === 'win32' ? 'icon.ico' : 'icon.png'),
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
      webSecurity: true,
    },
    autoHideMenuBar: true,   // oculta menu bar por padrão
    show: false,             // não mostrar até estar pronto
  });

  mainWindow.loadFile(path.join(__dirname, 'game', 'index.html'));

  // Mostrar apenas quando pronto (evita flash branco)
  mainWindow.once('ready-to-show', () => {
    mainWindow.show();
    // Focar o canvas para capturar input de teclado imediatamente
    mainWindow.webContents.focus();
  });

  // Menu mínimo
  const menu = Menu.buildFromTemplate([
    {
      label: 'Jogo',
      submenu: [
        {
          label: '⛶  Tela Cheia',
          accelerator: 'F11',
          click: () => mainWindow.setFullScreen(!mainWindow.isFullScreen()),
        },
        {
          label: '↺  Reiniciar',
          accelerator: 'CmdOrCtrl+R',
          click: () => mainWindow.reload(),
        },
        { type: 'separator' },
        {
          label: '✕  Sair',
          accelerator: process.platform === 'darwin' ? 'Cmd+Q' : 'Alt+F4',
          click: () => app.quit(),
        },
      ],
    },
    {
      label: 'Ver',
      submenu: [
        {
          label: 'Zoom +',
          accelerator: 'CmdOrCtrl+Equal',
          click: () => {
            const z = mainWindow.webContents.getZoomFactor();
            mainWindow.webContents.setZoomFactor(Math.min(z + 0.1, 2.0));
          },
        },
        {
          label: 'Zoom −',
          accelerator: 'CmdOrCtrl+Minus',
          click: () => {
            const z = mainWindow.webContents.getZoomFactor();
            mainWindow.webContents.setZoomFactor(Math.max(z - 0.1, 0.5));
          },
        },
        {
          label: 'Zoom Padrão',
          accelerator: 'CmdOrCtrl+0',
          click: () => mainWindow.webContents.setZoomFactor(1.0),
        },
      ],
    },
  ]);
  Menu.setApplicationMenu(menu);

  // F11 ativa tela cheia mesmo sem menu visível
  mainWindow.webContents.on('before-input-event', (event, input) => {
    if (input.key === 'F11' && input.type === 'keyDown') {
      mainWindow.setFullScreen(!mainWindow.isFullScreen());
    }
  });

  mainWindow.on('closed', () => { mainWindow = null; });
}

app.whenReady().then(() => {
  createWindow();
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});
