-- install.lua
local base = "https://raw.githubusercontent.com/SFitzgerald004/ComputerCraft/main/rednet_messaging/"

local files = {
    { level = "common", url = base .. "README.md", path = "rednet_messaging/README.md" },
    { level = "common", url = base .. "config.lua", path = "rednet_messaging/config.lua" },
    { level = "display", url = base .. "display.lua", path = "rednet_messaging/display.lua" },
    { level = "messaging", url = base .. "messaging.lua", path = "rednet_messaging/messaging.lua" }
}

-- Contains two versions, one for send and recieve, one to just display
local function installSoftware(type)
    -- make initial file directory
    fs.makeDir("rednet_messaging")

    local typeLower = string.lower(type)

    if typeLower == "display" then
        for f, file in ipairs(files) do
            if file.level ~= "messaging" then
                print("Downloading " .. file.path .. "...")
                shell.run("wget", file.url, file.path)
            end
        end
    elseif typeLower == "messaging" then
        for f, file in ipairs(files) do
            if file.level ~= "display" then
                print("Downloading " .. file.path .. "...")
                shell.run("wget", file.url, file.path)
            end
        end
    else
        error("[ERROR] Please choose either 'messaging' or 'display' install type.", 0)
    end

    print("Installation for type " .. typeLower .. " complete!")
end

print("Please select an install type (display/messaging):")
local install_type = io.read()
installSoftware(install_type)