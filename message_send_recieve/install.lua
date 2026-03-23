-- install.lua (messaging system)
local base = "https://raw.githubusercontent.com/SFitzgerald004/ComputerCraft/main/message_send_recieve/"

-- files may be added over time
local files = {
    -- common files, meant for both installations
    { level = "common", url = base .. "config.lua", path = "message_send_recieve/config.lua" },
    { level = "common", url = base .. "README.md", path = "message_send_recieve/README.md" },
    -- send files, meant only for installations that collect inventory data
    { level = "send", url = base .. "message_send.lua", path = "message_send_recieve/message_send.lua" },
    -- read files, meant only for installations that show inventory data
    { level = "read", url = base .. "message_read.lua", path = "message_send_recieve/message_read.lua" }
}

-- Supposed to be called upon running the script, user chooses either 'read' or 'send'
local function installSoftware(type)
    -- make initial directory
    fs.makeDir("message_send_recieve")

    -- reader / collector path
    if string.lower(type) == "read" then
        for f, file in ipairs(files) do
            if file.level ~= "send" then
                print("Downloading " .. file.path .. "...")
                shell.run("wget", file.url, file.path)
            end
        end
    elseif string.lower(type) == "send" then
        for f, file in ipairs(files) do
            if file.level ~= "read" then
                print("Downloading " .. file.path .. "...")
                shell.run("wget", file.url, file.path)
            end
        end
    else
        error("[ERROR] Bad parameter, input either 'read' or 'send'.", 0)
    end

    print("Installation for type " .. type .. " complete!")
end

-- user type prompt
print("Install type (read/send): ")
local install_type = io.read()
installSoftware(install_type)