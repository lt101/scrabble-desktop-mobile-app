const { app, BrowserWindow, ipcMain, Menu } = require('electron');
const path = require('path');
const url = require('url');

//const S3 = require('aws-sdk/clients/s3');
let win;

function createWindow() {
    win = new BrowserWindow({
        width: 780,
        height: 900,
        webPreferences: {
            contextIsolation: false,
            nodeIntegration: true,
            nodeIntegrationInWorker: true,
            webSecurity: false,
            allowRunningInsecureContent: true,
        },
    });
    win.loadURL(
        url.format({
            pathname: path.join(__dirname, `./dist/client/index.html`),
            protocol: 'file:',
            slashes: true,
        }),
    );
}

ipcMain.on('reload', () => {
    win.loadURL(
        url.format({
            pathname: path.join(__dirname, `./dist/client/index.html`),
            protocol: 'file:',
            slashes: true,
        }),
    );
});
app.whenReady().then(createWindow);
app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});
app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
        createWindow();
    }
});
