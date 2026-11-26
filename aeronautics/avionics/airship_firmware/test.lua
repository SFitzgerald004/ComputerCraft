-- test.lua: Phase 1 hardware check
-- Live-prints every reading through the hardware module.
-- Keys:  H = set hover RPM (feedforward test)
--        Q = quit
-- NOTE: reads only go through `hw`; this file never touches a peripheral directly.

local hw = require("hardware")   -- change to whatever you named the file

local REFRESH = 0.25             -- seconds between screen updates (4 Hz is plenty to read)

-- Format a number to 2 decimals; shows "nil" instead of crashing if a reading is missing
local function f(x)
    if x == nil then return "nil" end
    return string.format("%.2f", x)
end

local last_cmd = "none"          -- last RPM we commanded, shown on screen

local function draw()
    -- read everything fresh each frame
    local pitch, roll          = hw.getAngles()
    local pRate, yRate, rRate  = hw.getAngularRates()
    local ax, ay, az           = hw.getLinearAcceleration()
    local height   = hw.alt_sensor.getHeight()
    local pressure = hw.alt_sensor.getAirPressure()
    local vs       = hw.alt_sensor.getVerticalSpeed()

    term.clear()
    term.setCursorPos(1, 1)
    print("=== HARDWARE TEST ===")
    print("Height   " .. f(height) .. "   VS " .. f(vs) .. " m/s")
    print("Pressure " .. f(pressure))
    print("Pitch    " .. f(pitch) .. "   Roll " .. f(roll))
    print("Rates    P " .. f(pRate) .. "  Y " .. f(yRate) .. "  R " .. f(rRate))
    print("Accel    " .. f(ax) .. "  " .. f(ay) .. "  " .. f(az))
    print("Lever    " .. hw.throt_lever.getState())
    print("Burners  " .. #hw.gas_burners)
    print("Hover RPM (calc) " .. f(hw.HOVER_K / pressure))
    print("Last cmd " .. last_cmd)
    print("")
    print("[H] set hover RPM   [Q] quit")
end

-- Main loop: a timer drives redraws; key events are handled as they come in.
local timer = os.startTimer(REFRESH)
while true do
    local event, p1 = os.pullEvent()

    if event == "timer" and p1 == timer then
        draw()
        timer = os.startTimer(REFRESH)   -- re-arm for the next frame

    elseif event == "key" then
        if p1 == keys.h then
            -- Feedforward test: if HOVER_K is right, the ship should hold altitude
            local rpm = hw.HOVER_K / hw.alt_sensor.getAirPressure()
            hw.setRPM(rpm)               -- yields one tick (mainThread setter)
            last_cmd = f(rpm)
        elseif p1 == keys.q then
            break
        end
    end
end

term.clear()
term.setCursorPos(1, 1)
print("Test ended.")