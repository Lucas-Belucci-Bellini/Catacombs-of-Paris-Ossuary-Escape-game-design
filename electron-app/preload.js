const { contextBridge, ipcRenderer } = require('electron');

// Expõe API mínima e segura para o renderer (o jogo HTML)
contextBridge.exposeInMainWorld('electronAPI', {
  platform: process.platform,
  version: process.versions.electron,
});
