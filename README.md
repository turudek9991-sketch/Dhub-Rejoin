# DHub Rejoin - Termux Auto Rejoin & Cookie Injector

![Version](https://img.shields.io/badge/version-1.0-cyan)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Termux%20%2F%20Redfinger-brightgreen)

**DHub Rejoin** adalah script Lua untuk Termux yang mengotomatisasi:
- ✅ Auto-rejoin semua Roblox clone
- ✅ Inject cookie langsung ke database
- ✅ Set custom PlaceID/Private Server per device
- ✅ Auto Grid arrangement windows
- ✅ Clear cache aplikasi
- ✅ Monitor foreground service

## Requirements

- **Termux** (installed on Redfinger or Android device)
- **Redfinger** with **Android 10+** dan **root access**
- **Lua 5.4** (diinstall otomatis)
- **sqlite3** (diinstall otomatis)

## Quick Start

### 1️⃣ Termux Setup (Run Once)

Buka Termux di device Redfinger kamu, copy-paste command ini:

```bash
curl -sL https://raw.githubusercontent.com/turudek9991-sketch/Dhub-Rejoin/main/SETUP.sh | bash
```

Atau manual:

```bash
pkg update && pkg upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" && \
pkg install lua54 curl sqlite -y && \
mkdir -p ~/DHub-Rejoin && \
cd ~/DHub-Rejoin && \
curl -o dhub.lua https://raw.githubusercontent.com/turudek9991-sketch/Dhub-Rejoin/main/dhub.lua && \
chmod +x dhub.lua && \
lua54 dhub.lua
```

### 2️⃣ Run DHub Rejoin

```bash
# Cara 1: Langsung (recommended)
cd ~/DHub-Rejoin && lua54 dhub.lua

# Cara 2: Pakai alias (setelah setup)
dhub

# Cara 3: Launcher script
~/DHub-Rejoin/run.sh
```

## Menu Options

Setelah jalankan, pilih dari menu:

```
╔════════════════════════════════════════╗
║           DHub Rejoin Menu             ║
╠════════════════════════════════════════╣
║ 1. Detect Packages         (scan Roblox)║
║ 2. Inject Cookie           (auto-login) ║
║ 3. Set PlaceID             (game link)  ║
║ 4. Enable Auto Rejoin      (monitor)    ║
║ 5. Auto Grid Arrange       (windows)    ║
║ 6. Clear Cache             (optimize)   ║
║ 7. Start Auto Monitor      (run)        ║
║ 8. Settings                (customize)  ║
║ 9. Exit                    (quit)       ║
╚════════════════════════════════════════╝
```

## Usage Examples

### ✅ Example 1: Detect & Inject Cookie

```
Select option: 1
[Detecting Roblox packages...]
1. com.roblox.seiyv
2. com.roblox.seiyy
3. com.roblox.seiyy2

Select option: 2
1. com.roblox.seiyv
2. com.roblox.seiyy
3. com.roblox.seiyy2
Number: 1
Cookie (username:password:token): bakurisoji:mypass:_|WARNING:-DO-NOT-SHARE...

[Injecting cookie to com.roblox.seiyv...]
✓ Cookie injected
```

### ✅ Example 2: Set PlaceID & Auto Rejoin

```
Select option: 3
1. com.roblox.seiyv
Number: 1
PlaceID: 12345678
✓ PlaceID set: 12345678

Select option: 4
1. com.roblox.seiyv (auto_rejoin: false)
Number: 1
✓ Auto rejoin set to: true
```

### ✅ Example 3: Start Auto Monitor

```
Select option: 7
[19:34:05] Starting Auto Rejoin Monitor...
[19:34:10] com.roblox.seiyv status: running
[19:34:10] com.roblox.seiyy status: running
[19:34:13] com.roblox.seiyv status: offline (rejoin!)
[19:34:13] Detected com.roblox.seiyv not running, rejoining...
[19:34:18] Launched com.roblox.seiyv
```

### ✅ Example 4: Auto Grid Arrange

```
Select option: 5
Enable auto grid? (y/n): y
Rows [2]: 2
Columns [2]: 2
[Arranging windows in grid (2x2)...]
✓ Grid arrangement complete
```

## Cookie Format

Format input cookie:

```
username:password:token
```

Contoh:
```
bakurisoji:mypassword:_|WARNING:-DO-NOT-SHARE-THIS.--Sharing-this-will-allow-someone-to-log-in-as-you-and-to-steal-your-ROBUX-and-items.|_CAEaBBAEGAEi...
```

**Dari mana dapat token?**

1. Buka Dev Tools di browser (F12)
2. Console → `document.cookie`
3. Copy value `.ROBLOSECURITY`

Atau lebih simple, copy dari device Redfinger:
```bash
# Di Termux:
su -c "sqlite3 /data/data/com.roblox.seiyv/app_webview/Default/Cookies 'SELECT value FROM cookies WHERE name=\".ROBLOSECURITY\";'"
```

## Config File

Setiap kali jalankan, config disimpan di:

```
~/.dhub/config.json
```

Berisi:
- delay_rejoin (detik)
- delay_between_launch (detik)
- auto_grid settings
- package list & status

## Troubleshooting

### ❌ Error: "sqlite3 not found"
```bash
# Install sqlite
pkg install sqlite -y

# Verify
sqlite3 --version
```

### ❌ Error: "su command not found" atau "Permission denied"
```bash
# Cek root access
su -c "whoami"

# Jika muncul popup, allow access
# Jika tetap error, cek apakah device punya root
```

### ❌ Package tidak terdeteksi
```bash
# Manual check
su -c "pm list packages | grep roblox"

# Jika ada, tapi DHub tidak deteksi, lihat di ~/.dhub/config.json
```

### ❌ Cookie injection gagal
```bash
# Cek apakah database ada
su -c "ls -la /data/data/com.roblox.seiyv/app_webview/Default/"

# Cek sqlite3
su -c "which sqlite3"

# Manual test inject
su -c "sqlite3 /data/data/com.roblox.seiyv/app_webview/Default/Cookies '.tables'"
```

## Advanced Features

### 🔧 Custom Settings

Edit `~/.dhub/config.json` manual:

```bash
nano ~/.dhub/config.json
```

### 🔧 Run di Background (Termux Session)

```bash
# Install tmux atau screen
pkg install tmux -y

# Jalankan di background
tmux new-session -d -s dhub "cd ~/DHub-Rejoin && lua54 dhub.lua"

# Check status
tmux list-sessions

# Re-attach
tmux attach -t dhub
```

### 🔧 Scheduled Auto Monitor (Cron)

```bash
# Install cronie
pkg install cronie -y

# Edit crontab
crontab -e

# Add (every 5 minutes):
*/5 * * * * cd ~/DHub-Rejoin && echo "7" | lua54 dhub.lua > /tmp/dhub.log 2>&1
```

## Fitur Terencana (Future)

- [ ] Web UI dashboard
- [ ] Discord webhook notifications
- [ ] Backup/restore config
- [ ] Multi-device support (multiple Redfinger)
- [ ] Advanced scheduling
- [ ] Performance metrics

## Support

**Issues?**
- GitHub: https://github.com/turudek9991-sketch/Dhub-Rejoin/issues
- Termux Forum: https://github.com/termux/termux-app

## License

MIT License - feel free to modify & share!

---

**Made with ❤️ for Redfinger automation**
