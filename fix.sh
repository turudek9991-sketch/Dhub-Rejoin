#!/bin/bash
# DHub Rejoin - Emergency Recovery Script
# Use this if setup fails or dhub doesn't run

echo "=== DHub Rejoin Recovery ==="
echo ""

# Option 1: Clean reinstall
echo "Option 1: Clean reinstall (removes old version)"
echo "rm -rf ~/Dhub-Rejoin && curl -sSL https://raw.githubusercontent.com/turudek9991-sketch/Dhub-Rejoin/main/SETUP.sh | bash"
echo ""

# Option 2: Just reset git
echo "Option 2: Fix git conflicts"
echo "cd ~/Dhub-Rejoin && git reset --hard HEAD && git clean -fd && git pull origin main"
echo ""

# Option 3: Run directly
echo "Option 3: Run directly without git"
echo "cd ~/Dhub-Rejoin && lua5.4 dhub.lua"
echo ""

# Option 4: Auto-fix (interactive)
read -p "Run auto-fix? (y/n): " auto_fix

if [ "$auto_fix" = "y" ] || [ "$auto_fix" = "Y" ]; then
    echo "Attempting auto-fix..."
    
    # Kill any running processes
    pkill -f dhub.lua 2>/dev/null || true
    
    # Remove git lock
    rm -f ~/Dhub-Rejoin/.git/index.lock 2>/dev/null || true
    
    # Hard reset
    cd ~/Dhub-Rejoin
    git reset --hard HEAD 2>/dev/null || true
    git clean -fd 2>/dev/null || true
    
    # Try pull
    git pull origin main 2>/dev/null || true
    
    echo "Auto-fix complete. Try running: dhub"
fi
