# 🚀 DHub Rejoin - Quick Start

**1️⃣ Open Termux in Redfinger**

**2️⃣ Copy-Paste this ONE command:**

```bash
curl -sSL https://raw.githubusercontent.com/turudek9991-sketch/Dhub-Rejoin/main/SETUP.sh | bash
```

**3️⃣ After setup, run:**

```bash
dhub
```

**Done!** 🎉

---

## ⚡ Jika Ada Error saat Setup atau jalankan dhub

**Quick Fix (Clean Install):**
```bash
rm -rf ~/Dhub-Rejoin
curl -sSL https://raw.githubusercontent.com/turudek9991-sketch/Dhub-Rejoin/main/SETUP.sh | bash
```

**Atau run langsung tanpa git:**
```bash
cd ~/Dhub-Rejoin && lua5.4 dhub.lua
```

**Atau gunakan fallback:**
```bash
cd ~/Dhub-Rejoin && ./run-direct.sh
```

---

## ⚡ Jika Ada Error "lua54 not found"

**Cepat:**
```bash
pkg install lua54 -y && cd ~/Dhub-Rejoin && ./run-direct.sh
```

**Atau manual:**
```bash
pkg install lua54 -y
cd ~/Dhub-Rejoin
lua5.4 dhub.lua
```

---

## Menu Guide

```
1 - Detect Packages    (scan Roblox clones)
2 - Inject Cookie      (auto-login)
3 - Set PlaceID        (custom game link)
4 - Enable Auto Rejoin (auto-monitor)
5 - Auto Grid Arrange  (arrange windows)
6 - Clear Cache        (optimize)
7 - Start Auto Monitor (run 24/7)
8 - Settings           (customize)
9 - Exit               (quit)
```

---

## Cookie Format

```
username:password:_|WARNING:-DO-NOT-SHARE...token
```

Example:
```
bakurisoji:mypass:_|WARNING:-DO-NOT-SHARE-THIS.--Sharing-this-will-allow-someone-to-log-in-as-you-and-to-steal-your-ROBUX-and-items.|_CAEaBBAEGAEi...
```

---

**For full documentation:** [README.md](README.md)

**GitHub:** https://github.com/turudek9991-sketch/Dhub-Rejoin
