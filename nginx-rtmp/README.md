# NGINX-RTMP Live Streaming Server

🚀 **Easy-to-use RTMP streaming server for Windows with HLS support**

## ✨ Features

- ✅ **RTMP Server** on port 1935
- ✅ **HTTP Server** on port 8080  
- ✅ **HLS (HTTP Live Streaming)** support
- ✅ **DASH** streaming support
- ✅ **Auto-recording** to FLV files
- ✅ **Web-based viewer** with HLS.js
- ✅ **Real-time statistics** at `/stat`
- ✅ **Easy OBS integration**
- ✅ **Internet sharing** via ngrok/serveo/cloudflare
- ✅ **One-click installer**

## 🚀 Quick Start

### For New Users:
1. Run `install.bat` (as Administrator)
2. Double-click `start-streaming.bat`
3. Configure OBS: `rtmp://localhost:1935/live`
4. Start streaming!

### For Existing Users:
1. Double-click `start-streaming.bat`
2. View stream at: `http://localhost:8080`

## 🎥 OBS Studio Settings

```
Service: Custom
Server: rtmp://localhost:1935/live
Stream Key: live
```

## 🌐 URLs

- **Web Viewer**: http://localhost:8080
- **HLS Stream**: http://localhost:8080/hls/live.m3u8  
- **Statistics**: http://localhost:8080/stat
- **Health Check**: http://localhost:8080/health

## 📤 Share to Internet

Choose one method:

### Serveo (Recommended)
```bash
ssh -R 80:localhost:8080 serveo.net
```

### Ngrok
```bash
ngrok http 8080
```

### Cloudflare Tunnel
```bash
cloudflared tunnel --url http://localhost:8080
```

## 📁 File Structure

```
nginx-rtmp/
├── start-streaming.bat    # 🚀 Main launcher
├── stop.bat              # 🛑 Stop server
├── install.bat           # 💾 First-time setup
├── force-cleanup.bat     # 🧹 Fix stuck processes
├── QUICK-START.txt       # 📋 Quick guide
├── README.md             # 📖 This documentation
├── nginx.exe             # ⚙️ Main server
├── nssm.exe              # 🔧 Service manager
├── conf/nginx.conf       # ⚙️ Configuration
├── html/
│   ├── index.html        # 🌐 Web viewer
│   └── stat.xsl          # 📊 Statistics template
└── logs/                 # 📝 Log files
```

## 🛠️ Troubleshooting

| Problem | Solution |
|---------|----------|
| Port 8080 in use | Run `stop.bat` first |
| OBS can't connect | Check server: `rtmp://localhost:1935/live` |
| Black screen | Wait 5-10 seconds after starting stream |
| Can't delete folder | Run `force-cleanup.bat` or restart Windows |

## 🔧 Technical Details

- **Nginx**: 1.13.12+ with RTMP module
- **HLS Fragment**: 2 seconds  
- **Playlist Length**: 10 seconds
- **Recording Format**: FLV
- **Streaming Protocol**: RTMP → HLS conversion

## 📋 System Requirements

- ✅ Windows 7/8/10/11
- ✅ 2GB RAM minimum
- ✅ 100MB free disk space
- ✅ Internet connection (for sharing)

## 🎯 Version

**Version**: 1.0  
**Date**: 2025-09-22  
**Support**: GitHub Issues

---

Made with ❤️ for easy live streaming
