local base = "https://raw.githubusercontent.com/SFitzgerald004/ComputerCraft/main/aeronautics/avionics/airship_firmware/"

local files = {
    { level = "common", url = base .. "hardware.lua", path = "airship_firmware/hardware.lua" },
    { level = "common", url = base .. "control.lua", path = "airship_firmware/control.lua" },
    { level = "common", url = base .. "main.lua", path = "airship_firmware/main.lua" },
    { level = "common", url = base .. "test.lua", path = "airship_firmware/test.lua" },
}

local function installSoftware()
    fs.makeDir("airship_firmware")
    fs.makeDir("airship_firmware/modes")

    for f, file in ipairs(files) do
        shell.run("wget", file.url, file.path)
    end

    print("Installation Complete!")
end

print("Installing Airship Firmware")
installSoftware()