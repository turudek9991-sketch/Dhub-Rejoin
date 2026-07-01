#!/bin/bash
# Direct runner - tries multiple Lua binaries

cd ~/Dhub-Rejoin

# Try different Lua commands
if command -v lua54 &> /dev/null; then
    lua54 dhub.lua "$@"
elif command -v lua5.4 &> /dev/null; then
    lua5.4 dhub.lua "$@"
elif command -v lua &> /dev/null; then
    lua dhub.lua "$@"
elif [ -f "$PREFIX/bin/lua54" ]; then
    "$PREFIX/bin/lua54" dhub.lua "$@"
elif [ -f "$PREFIX/bin/lua5.4" ]; then
    "$PREFIX/bin/lua5.4" dhub.lua "$@"
elif [ -f "$PREFIX/bin/lua" ]; then
    "$PREFIX/bin/lua" dhub.lua "$@"
else
    echo "❌ Lua not found!"
    echo "Try: pkg install lua54 -y"
    exit 1
fi
