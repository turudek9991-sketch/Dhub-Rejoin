#!/bin/bash

# DHub Rejoin - Setup Script for Termux
# Works with lua5.4, lua54, lua, etc.

echo -e "\033[36m\033[1m"
echo "╔════════════════════════════════════════╗"
echo "║      DHub Rejoin - Setup Wizard        ║"
echo "║   Auto Rejoin & Cookie Injector        ║"
echo "╚════════════════════════════════════════╝"
echo -e "\033[0m"

# Configuration
REPO_URL="https://github.com/turudek9991-sketch/Dhub-Rejoin"
RAW_URL="https://raw.githubusercontent.com/turudek9991-sketch/Dhub-Rejoin/main"
INSTALL_DIR="$HOME/Dhub-Rejoin"

# Step 1: Update packages
echo -e "\033[36m[STEP 1] Updating Termux packages...\033[0m"
pkg update -y
pkg upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

# Step 2: Install dependencies
echo -e "\033[36m[STEP 2] Installing dependencies (lua54, curl, sqlite, git)...\033[0m"
pkg install lua54 curl sqlite git -y

# Step 3: Detect Lua binary
echo -e "\033[36m[STEP 3] Detecting Lua installation...\033[0m"
LUA_BIN=""
for lua_cmd in lua54 lua5.4 lua lua-54; do
    if command -v $lua_cmd &> /dev/null; then
        LUA_BIN=$lua_cmd
        echo -e "\033[32m✓ Found Lua: $lua_cmd\033[0m"
        break
    fi
done

if [ -z "$LUA_BIN" ]; then
    echo -e "\033[31m✗ Lua not found. Trying package path...\033[0m"
    # Try dari package path
    if [ -f "$PREFIX/bin/lua54" ]; then
        LUA_BIN="$PREFIX/bin/lua54"
    elif [ -f "$PREFIX/bin/lua5.4" ]; then
        LUA_BIN="$PREFIX/bin/lua5.4"
    elif [ -f "$PREFIX/bin/lua" ]; then
        LUA_BIN="$PREFIX/bin/lua"
    else
        echo -e "\033[31m✗ Lua installation failed. Please try:\033[0m"
        echo "pkg install lua54 -y && pkg list-installed | grep lua"
        exit 1
    fi
    echo -e "\033[32m✓ Found Lua at: $LUA_BIN\033[0m"
fi

# Step 4: Create directories
echo -e "\033[36m[STEP 4] Creating DHub directories...\033[0m"
mkdir -p ~/.dhub
mkdir -p "$INSTALL_DIR"

# Step 5: Clone or download repo
echo -e "\033[36m[STEP 5] Downloading DHub Rejoin from GitHub...\033[0m"

# Try git clone first
if command -v git &> /dev/null; then
    echo "Using git clone..."
    cd "$HOME"
    if [ -d "$INSTALL_DIR/.git" ]; then
        echo "Repository already exists, pulling latest..."
        cd "$INSTALL_DIR"
        git pull origin main
    else
        git clone "$REPO_URL" "$INSTALL_DIR"
        cd "$INSTALL_DIR"
    fi
else
    echo "Git not available, using curl..."
    cd "$INSTALL_DIR"
    
    echo "Downloading dhub.lua..."
    curl -sSL "$RAW_URL/dhub.lua" -o dhub.lua
    
    echo "Downloading README.md..."
    curl -sSL "$RAW_URL/README.md" -o README.md
    
    echo "Downloading .gitignore..."
    curl -sSL "$RAW_URL/.gitignore" -o .gitignore 2>/dev/null || echo ""
fi

# Check if download successful
if [ ! -f "$INSTALL_DIR/dhub.lua" ]; then
    echo -e "\033[31m❌ Failed to download dhub.lua\033[0m"
    echo "Please check your internet connection and try again"
    exit 1
fi

# Step 6: Make scripts executable
echo -e "\033[36m[STEP 6] Setting permissions...\033[0m"
chmod +x "$INSTALL_DIR/dhub.lua"

# Step 7: Create launcher script with correct Lua path
echo -e "\033[36m[STEP 7] Creating launcher scripts...\033[0m"
cat > "$INSTALL_DIR/run.sh" << EOF
#!/bin/bash
cd "\$HOME/Dhub-Rejoin"
$LUA_BIN dhub.lua "\$@"
EOF
chmod +x "$INSTALL_DIR/run.sh"

# Step 8: Create alias
echo -e "\033[36m[STEP 8] Creating shortcuts...\033[0m"

# Add to bashrc if not exists
if ! grep -q "alias dhub=" ~/.bashrc; then
    echo "alias dhub='$LUA_BIN $INSTALL_DIR/dhub.lua'" >> ~/.bashrc
    echo "alias dhub-update='cd $INSTALL_DIR && git pull origin main 2>/dev/null || echo \"Please install git for auto-updates\"'" >> ~/.bashrc
fi

# Source bashrc
source ~/.bashrc 2>/dev/null || true

# Step 9: Quick setup option
echo -e "\033[36m[STEP 9] Quick setup (optional)...\033[0m"
read -p "Do you want to grant root access to Termux now? (y/n): " grant_root

if [ "$grant_root" = "y" ] || [ "$grant_root" = "Y" ]; then
    echo "Granting root access..."
    su -c "id" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "\033[32m✓ Root access confirmed\033[0m"
    else
        echo -e "\033[31m✗ Root access not available\033[0m"
        echo "Please ensure your device has root enabled"
    fi
fi

# Finish
echo -e "\033[32m\033[1m"
echo "╔════════════════════════════════════════╗"
echo "║   ✓ Setup Complete! Ready to use DHub  ║"
echo "╠════════════════════════════════════════╣"
echo "║  Lua binary: $LUA_BIN"
echo "║"
echo "║  Run DHub with:"
echo "║  $ dhub"
echo "║"
echo "║  Or directly:"
echo "║  $ $LUA_BIN ~/Dhub-Rejoin/dhub.lua"
echo "║"
echo "║  Update (if git installed):"
echo "║  $ dhub-update"
echo "║"
echo "║  Help & documentation:"
echo "║  $ cat ~/Dhub-Rejoin/README.md"
echo "╚════════════════════════════════════════╝"
echo -e "\033[0m"

# Show first run instructions
echo -e "\033[33m📝 FIRST TIME SETUP:\033[0m"
echo "1. Run: dhub"
echo "2. Press 1 to detect packages"
echo "3. Press 2 to inject cookies"
echo "4. Press 4 to enable auto-rejoin"
echo "5. Press 7 to start monitor"
echo ""
echo -e "\033[36m🔗 Repository: $REPO_URL\033[0m"
