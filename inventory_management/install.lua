-- install.lua (used to install inventory management system)
local base = "https://raw.githubusercontent.com/SFitzgerald004/ComputerCraft/main/inventory_management/"

-- files will be added over time 
local files = {
    -- common files, meant for both installations
    { level = "common", url = base .. "config.lua", path = "inventory_management/config.lua" },
    -- collector files, meant only for installations that collect inventory data
    { level = "collector", url = base .. "inv_collector.lua", path = "inventory_management/inv_collector.lua" },
    { level = "collector", url = base .. "inv_libraries/chest.lua", path = "inventory_management/inv_libraries/chest.lua" },
    -- reader files, meant only for installations that show inventory data
    { level = "reader", url = base .. "inv_reader.lua", path = "inventory_management/inv_reader.lua" }
}

-- Supposed to be called upon running the script, user chooses either 'reader' or 'collector'
local function installSoftware(type)
    -- make initial directory
    fs.makeDir("inventory_management")

    -- reader / collector path
    if string.lower(type) == "reader" then
        for f, file in ipairs(files) do
            if file.level ~= "collector" then
                print("Downloading " .. file.path .. "...")
                shell.run("wget", file.url, file.path)
            end
        end
    elseif string.lower(type) == "collector" then
        fs.makeDir("inventory_management/inv_libraries")

        for f, file in ipairs(files) do
            if file.level ~= "reader" then
                print("Downloading " .. file.path .. "...")
                shell.run("wget", file.url, file.path)
            end
        end
    else
        error("[ERROR] Bad parameter, input either 'reader' or 'collector'.", 1)
    end

    print("Installation for type " .. type .. " complete!")
end

-- user type prompt
print("Install type (reader/collector): ")
local install_type = io.read()
installSoftware(install_type)