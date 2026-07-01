#!/usr/bin/env lua54
-- DHub Rejoin - Auto Rejoin & Cookie Inject Script for Redfinger
-- Usage: lua dhub.lua

local json = require("json") or {}
local os = os
local io = io
local table = table

-- Color codes
local colors = {
    reset = "\27[0m",
    bright = "\27[1m",
    cyan = "\27[36m",
    green = "\27[32m",
    red = "\27[31m",
    yellow = "\27[33m",
    magenta = "\27[35m"
}

-- Config
local CONFIG_FILE = os.getenv("HOME") .. "/.dhub/config.json"
local CACHE_DIR = os.getenv("HOME") .. "/.dhub"
local DEVICES = {}
local PACKAGES = {}
local SETTINGS = {
    delay_rejoin = 5,
    delay_between_launch = 3,
    auto_grid = false,
    grid_rows = 2,
    grid_cols = 2,
    clear_cache = true,
    foreground_service = true
}

-- Helper Functions
local function print_header()
    print(colors.cyan .. colors.bright .. [[
    ╔══════════════════════════════════════╗
    ║         DHub Rejoin v1.0             ║
    ║    Auto Rejoin & Cookie Injector     ║
    ║      For Redfinger Android 10+       ║
    ╚══════════════════════════════════════╝
    ]] .. colors.reset)
end

local function log(msg, level)
    level = level or "info"
    local timestamp = os.date("%H:%M:%S")
    local color = colors.reset
    
    if level == "success" then
        color = colors.green
    elseif level == "error" then
        color = colors.red
    elseif level == "warning" then
        color = colors.yellow
    elseif level == "info" then
        color = colors.cyan
    end
    
    print(color .. "[" .. timestamp .. "] " .. msg .. colors.reset)
end

local function execute(cmd)
    log("Executing: " .. cmd, "info")
    local handle = io.popen(cmd .. " 2>&1")
    local result = handle:read("*a")
    handle:close()
    return result
end

local function execute_root(cmd)
    -- Wrapper untuk menjalankan command dengan su
    local full_cmd = 'su -c "' .. cmd .. '"'
    return execute(full_cmd)
end

local function mkdir_p(path)
    os.execute("mkdir -p " .. path)
end

-- Device & Package Detection
local function detect_devices()
    log("Detecting Redfinger devices...", "info")
    
    -- Untuk Redfinger, biasanya hanya 1 device (localhost)
    -- Tapi kita bisa extend untuk multiple devices
    DEVICES[1] = {
        id = "device-1",
        name = "Redfinger Local",
        ip = "127.0.0.1",
        status = "online"
    }
    
    log("Found " .. #DEVICES .. " device(s)", "success")
    return DEVICES
end

local function detect_packages()
    log("Detecting Roblox packages...", "info")
    
    local result = execute_root("pm list packages | grep roblox")
    if not result or result == "" then
        log("No Roblox packages found", "warning")
        return {}
    end
    
    local packages = {}
    for package in result:gmatch("package:([^\n]+)") do
        table.insert(packages, {
            name = package,
            account = "unknown",
            status = "offline",
            place_id = "",
            private_server = "",
            cookie = "",
            auto_rejoin = false
        })
    end
    
    PACKAGES = packages
    log("Found " .. #PACKAGES .. " Roblox package(s)", "success")
    return packages
end

-- Cookie Injection
local function parse_cookie_input(input)
    -- Format: username:password:token
    local parts = {}
    for part in input:gmatch("[^:]+") do
        table.insert(parts, part)
    end
    
    if #parts < 1 then
        return nil, "Invalid cookie format. Use: username:password:token"
    end
    
    return {
        username = parts[1] or "unknown",
        password = parts[2] or "",
        token = parts[3] or parts[1] or ""
    }
end

local function inject_cookie(package_name, token)
    log("Injecting cookie to " .. package_name .. "...", "info")
    
    -- 1. Pre-launch Roblox
    log("Pre-launching " .. package_name .. "...", "info")
    execute_root("am start -n " .. package_name .. "/.MainActivity 2>/dev/null || monkey -p " .. package_name .. " -c android.intent.category.LAUNCHER 1")
    os.execute("sleep 4")
    
    -- 2. Force stop
    execute_root("am force-stop " .. package_name)
    os.execute("sleep 1")
    
    -- 3. Cookie DB path
    local db_path = "/data/data/" .. package_name .. "/app_webview/Default/Cookies"
    
    -- 4. Check if file exists
    local check = execute_root("[ -f \"" .. db_path .. "\" ] && echo OK || echo NOTFOUND")
    if not check:find("OK") then
        log("Cookie database not found for " .. package_name, "error")
        return false
    end
    
    -- 5. Remove WAL/SHM
    execute_root("rm -f \"" .. db_path .. "-wal\" \"" .. db_path .. "-shm\"")
    os.execute("sleep 0.5")
    
    -- 6. Inject via sqlite3
    local timestamp = os.time()
    local creation_micros = timestamp * 1000000
    local expiry_micros = creation_micros + (365 * 24 * 60 * 60 * 1000000)
    
    local sql_cmd = string.format(
        "sqlite3 \"%s\" \"DELETE FROM cookies WHERE name='.ROBLOSECURITY'; INSERT OR REPLACE INTO cookies (creation_utc, host_key, name, value, path, expires_utc, is_secure, is_httponly, last_access_utc, has_expires, is_persistent, priority, samesite, source_scheme, source_port) VALUES (%d, '.roblox.com', '.ROBLOSECURITY', '%s', '/', %d, 1, 1, %d, 1, 1, 1, -1, 2, 443);\"",
        db_path, creation_micros, token, expiry_micros, creation_micros
    )
    
    local result = execute_root(sql_cmd)
    
    -- 7. Fix permission
    execute_root("chmod 660 \"" .. db_path .. "\"")
    local uid = execute_root("stat -c '%u:%g' /data/data/" .. package_name)
    if uid and uid ~= "" then
        execute_root("chown " .. uid:gsub("\n", "") .. " \"" .. db_path .. "\"")
    end
    
    log("Cookie injected to " .. package_name, "success")
    return true
end

-- Auto Rejoin
local function launch_roblox(package_name, place_id)
    log("Launching " .. package_name .. "...", "info")
    
    local cmd
    if place_id and place_id ~= "" then
        cmd = string.format("am start -n %s/.MainActivity -d 'roblox://placeID=%s' 2>/dev/null", package_name, place_id)
    else
        cmd = string.format("am start -n %s/.MainActivity 2>/dev/null", package_name)
    end
    
    execute_root(cmd)
    log("Launched " .. package_name, "success")
end

local function is_package_running(package_name)
    local result = execute_root("pidof " .. package_name)
    return result and result ~= ""
end

local function auto_rejoin()
    log("Starting Auto Rejoin Monitor...", "info")
    
    while true do
        for _, pkg in ipairs(PACKAGES) do
            if pkg.auto_rejoin then
                if not is_package_running(pkg.name) then
                    log("Detected " .. pkg.name .. " not running, rejoining...", "warning")
                    launch_roblox(pkg.name, pkg.place_id)
                    os.execute("sleep " .. SETTINGS.delay_rejoin)
                end
            end
        end
        os.execute("sleep 3")
    end
end

-- Auto Grid
local function auto_grid_arrange()
    if not SETTINGS.auto_grid then
        return
    end
    
    log("Arranging windows in grid (" .. SETTINGS.grid_rows .. "x" .. SETTINGS.grid_cols .. ")...", "info")
    
    local screen_width = 1080 -- Standard Redfinger resolution
    local screen_height = 1920
    local cols = SETTINGS.grid_cols
    local rows = SETTINGS.grid_rows
    
    local width = math.floor(screen_width / cols)
    local height = math.floor(screen_height / rows)
    
    local idx = 0
    for row = 0, rows - 1 do
        for col = 0, cols - 1 do
            idx = idx + 1
            if idx <= #PACKAGES then
                local pkg = PACKAGES[idx]
                local x = col * width
                local y = row * height
                
                -- Set window position via am
                local cmd = string.format(
                    "am start -n %s/.MainActivity --windowingMode 5",
                    pkg.name
                )
                execute_root(cmd)
                
                log("Positioned " .. pkg.name .. " at (" .. x .. ", " .. y .. ")", "info")
                os.execute("sleep " .. SETTINGS.delay_between_launch)
            end
        end
    end
    
    log("Grid arrangement complete", "success")
end

-- Clear Cache
local function clear_cache()
    if not SETTINGS.clear_cache then
        return
    end
    
    log("Clearing cache for Roblox packages...", "info")
    
    for _, pkg in ipairs(PACKAGES) do
        local cmd = string.format("rm -rf /data/data/%s/cache/*", pkg.name)
        execute_root(cmd)
        log("Cleared cache: " .. pkg.name, "success")
    end
end

-- Config Management
local function load_config()
    mkdir_p(CACHE_DIR)
    
    if io.open(CONFIG_FILE, "r") then
        log("Loading config from " .. CONFIG_FILE, "info")
        -- Simple JSON-like config
        local file = io.open(CONFIG_FILE, "r")
        local content = file:read("*a")
        file:close()
        -- Parse config (basic implementation)
    else
        log("Creating new config file...", "info")
        save_config()
    end
end

local function save_config()
    mkdir_p(CACHE_DIR)
    local file = io.open(CONFIG_FILE, "w")
    
    local config_str = {
        "delay_rejoin=" .. SETTINGS.delay_rejoin,
        "delay_between_launch=" .. SETTINGS.delay_between_launch,
        "auto_grid=" .. tostring(SETTINGS.auto_grid),
        "grid_rows=" .. SETTINGS.grid_rows,
        "grid_cols=" .. SETTINGS.grid_cols,
        "clear_cache=" .. tostring(SETTINGS.clear_cache)
    }
    
    file:write(table.concat(config_str, "\n"))
    file:close()
    log("Config saved to " .. CONFIG_FILE, "success")
end

-- Menu
local function show_menu()
    print(colors.bright .. [[
╔════════════════════════════════════════╗
║           DHub Rejoin Menu             ║
╠════════════════════════════════════════╣
║ 1. Detect Packages                     ║
║ 2. Inject Cookie                       ║
║ 3. Set PlaceID                         ║
║ 4. Enable Auto Rejoin                  ║
║ 5. Auto Grid Arrange                   ║
║ 6. Clear Cache                         ║
║ 7. Start Auto Monitor                  ║
║ 8. Settings                            ║
║ 9. Exit                                ║
╚════════════════════════════════════════╝
    ]] .. colors.reset)
end

local function main_menu()
    while true do
        show_menu()
        io.write(colors.bright .. "Select option: " .. colors.reset)
        local choice = io.read()
        
        if choice == "1" then
            detect_devices()
            detect_packages()
            for i, pkg in ipairs(PACKAGES) do
                print(colors.cyan .. i .. ". " .. pkg.name .. colors.reset)
            end
        
        elseif choice == "2" then
            print(colors.cyan .. "Select package number:" .. colors.reset)
            for i, pkg in ipairs(PACKAGES) do
                print(i .. ". " .. pkg.name)
            end
            io.write("Number: ")
            local pkg_idx = tonumber(io.read())
            
            if pkg_idx and PACKAGES[pkg_idx] then
                io.write("Cookie (username:password:token): ")
                local cookie_input = io.read()
                local parsed = parse_cookie_input(cookie_input)
                
                if parsed then
                    inject_cookie(PACKAGES[pkg_idx].name, parsed.token)
                    PACKAGES[pkg_idx].cookie = parsed.token
                    save_config()
                else
                    log("Invalid cookie format", "error")
                end
            end
        
        elseif choice == "3" then
            print(colors.cyan .. "Select package number:" .. colors.reset)
            for i, pkg in ipairs(PACKAGES) do
                print(i .. ". " .. pkg.name .. " (current: " .. (pkg.place_id or "none") .. ")")
            end
            io.write("Number: ")
            local pkg_idx = tonumber(io.read())
            
            if pkg_idx and PACKAGES[pkg_idx] then
                io.write("PlaceID: ")
                PACKAGES[pkg_idx].place_id = io.read()
                log("PlaceID set: " .. PACKAGES[pkg_idx].place_id, "success")
                save_config()
            end
        
        elseif choice == "4" then
            print(colors.cyan .. "Select package number:" .. colors.reset)
            for i, pkg in ipairs(PACKAGES) do
                print(i .. ". " .. pkg.name .. " (auto_rejoin: " .. tostring(pkg.auto_rejoin) .. ")")
            end
            io.write("Number: ")
            local pkg_idx = tonumber(io.read())
            
            if pkg_idx and PACKAGES[pkg_idx] then
                PACKAGES[pkg_idx].auto_rejoin = not PACKAGES[pkg_idx].auto_rejoin
                log("Auto rejoin set to: " .. tostring(PACKAGES[pkg_idx].auto_rejoin), "success")
                save_config()
            end
        
        elseif choice == "5" then
            io.write("Enable auto grid? (y/n): ")
            if io.read():lower() == "y" then
                io.write("Rows [2]: ")
                SETTINGS.grid_rows = tonumber(io.read()) or 2
                io.write("Columns [2]: ")
                SETTINGS.grid_cols = tonumber(io.read()) or 2
                SETTINGS.auto_grid = true
                auto_grid_arrange()
                save_config()
            end
        
        elseif choice == "6" then
            clear_cache()
        
        elseif choice == "7" then
            log("Starting Auto Monitor (Ctrl+C to stop)...", "success")
            auto_rejoin()
        
        elseif choice == "8" then
            print(colors.bright .. "Settings:" .. colors.reset)
            print("1. Delay Rejoin: " .. SETTINGS.delay_rejoin .. "s")
            print("2. Delay Between Launch: " .. SETTINGS.delay_between_launch .. "s")
            print("3. Clear Cache: " .. tostring(SETTINGS.clear_cache))
            
            io.write("Select (or press Enter to skip): ")
            local setting_choice = io.read()
            
            if setting_choice == "1" then
                io.write("New delay (seconds): ")
                SETTINGS.delay_rejoin = tonumber(io.read()) or SETTINGS.delay_rejoin
            elseif setting_choice == "2" then
                io.write("New delay (seconds): ")
                SETTINGS.delay_between_launch = tonumber(io.read()) or SETTINGS.delay_between_launch
            elseif setting_choice == "3" then
                SETTINGS.clear_cache = not SETTINGS.clear_cache
            end
            save_config()
        
        elseif choice == "9" then
            log("Exiting DHub Rejoin", "info")
            break
        
        else
            log("Invalid option", "error")
        end
        
        print("")
    end
end

-- Main
function main()
    print_header()
    load_config()
    detect_devices()
    detect_packages()
    main_menu()
end

-- Error handling
local status, err = pcall(main)
if not status then
    log("Error: " .. tostring(err), "error")
end
