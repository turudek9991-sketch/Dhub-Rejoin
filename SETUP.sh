#!/bin/bash

# DHub Rejoin - Setup Script for Termux
# Run this ONCE in Termux (no files needed to upload)
# Just copy-paste the command below and run

echo -e "\033[36m\033[1m"
echo "╔════════════════════════════════════════╗"
echo "║      DHub Rejoin - Setup Wizard        ║"
echo "║   Auto Rejoin & Cookie Injector        ║"
echo "╚════════════════════════════════════════╝"
echo -e "\033[0m"

# Configuration
REPO_URL="https://github.com/turudek9991-sketch/DHub-Rejoin"
RAW_URL="https://raw.githubusercontent.com/turudek9991-sketch/DHub-Rejoin/main"
INSTALL_DIR="$HOME/DHub-Rejoin"

# Step 1: Update packages
echo -e "\033[36m[STEP 1] Updating Termux packages...\033[0m"
pkg update -y
pkg upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

# Step 2: Install dependencies
echo -e "\033[36m[STEP 2] Installing dependencies (lua54, curl, sqlite, git)...\033[0m"
pkg install lua54 curl sqlite git -y

# Step 3: Create directories
echo -e "\033[36m[STEP 3] Creating DHub directories...\033[0m"
mkdir -p ~/.dhub
mkdir -p "$INSTALL_DIR"

# Step 4: Clone or download repo
echo -e "\033[36m[STEP 4] Downloading DHub Rejoin from GitHub...\033[0m"

# Try git clone first (better for updates)
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
    
    # Download individual files
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

# Step 5: Make scripts executable
echo -e "\033[36m[STEP 5] Setting permissions...\033[0m"
chmod +x "$INSTALL_DIR/dhub.lua"

# Step 6: Create launcher script
echo -e "\033[36m[STEP 6] Creating launcher scripts...\033[0m"
cat > "$INSTALL_DIR/run.sh" << 'EOF'
#!/bin/bash
cd "$HOME/DHub-Rejoin"
lua54 dhub.lua "$@"
EOF
chmod +x "$INSTALL_DIR/run.sh"

# Step 7: Create alias
echo -e "\033[36m[STEP 7] Creating shortcuts...\033[0m"

# Add to bashrc if not exists
if ! grep -q "alias dhub=" ~/.bashrc; then
    echo "alias dhub='lua54 $HOME/DHub-Rejoin/dhub.lua'" >> ~/.bashrc
    echo "alias dhub-update='cd $HOME/DHub-Rejoin && git pull origin main 2>/dev/null || echo \"Please install git for auto-updates\"'" >> ~/.bashrc
fi

# Source bashrc
source ~/.bashrc 2>/dev/null || true

# Step 8: Quick setup option
echo -e "\033[36m[STEP 8] Quick setup (optional)...\033[0m"
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
echo "║  Run DHub with:"
echo "║  $ dhub"
echo "║"
echo "║  Or directly:"
echo "║  $ lua54 ~/DHub-Rejoin/dhub.lua"
echo "║"
echo "║  Update (if git installed):"
echo "║  $ dhub-update"
echo "║"
echo "║  Help & documentation:"
echo "║  $ cat ~/DHub-Rejoin/README.md"
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
