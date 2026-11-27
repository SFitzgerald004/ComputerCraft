-- main 20 hz loop
-- Each sensor value gets read out into a shared table that updates each loop
-- table holds values for the following: 
--[[
    height
    vertical velocity
    horizontal velocity
    pitch
    roll
    rates
    pressure
    current mode
]] 

local hardware = require("hardware")
assert(hardware, "hardware module not found, was it deleted?")

local DEBUG_LOG = true -- only set to true when written info is needed
local log_file = DEBUG_LOG and fs.open("flight.log", "w") or nil

local function logLine(text)
    if not log_file then return end
    local ok = pcall(function()
        log_file.writeLine(text)
        log_file.flush()
    end)
    if not ok then log_file = nil end
end

local state = {
    -- sensors; these get refreshed each tick
    --[[
    height,
    hor_velocity,
    ver_velocity,
    pressure,
    pitch,
    roll,
    pitch_rate,
    yaw_rate,
    roll_rate,
    balloon_lift,
    propellerRPM,
    ]]
    -- control
    mode = "DISARMED",
    constant = 28.19,
    hoverRPM = 0,
    cmdRPM = 0,
    -- timing / health
    dt = 0,
    hz = 0,
    steadyTime = 0,
    lastError
}

-- used to find failsafe cases
local function checkFaults()
    -- pitch or roll over 15 degrees
    local pitch, roll = hardware.getAngles()
    if (math.abs(pitch) > 15) or (math.abs(roll) > 15) then
        return true, "Pitch / Roll > 15 degrees"
        -- state.mode = "FAILSAFE"
    end

    -- angular rate over 20 degrees/s
    local pitchRate, yawRate, rollRate = hardware.getAngularRates()
    if (math.abs(pitchRate) > 20) or (math.abs(yawRate) > 20) or (math.abs(rollRate) > 20) then
        return true, "Pitch / Yaw / Roll Rate > 20 degrees/s"
        -- state.mode = "FAILSAFE"
    end

    -- any nil readings

    return false
end

local function mode(switch, rising)
    if not switch then
        state.mode = "DISARMED"
    elseif (rising and state.mode == "DISARMED") then 
        -- DISARMED -> ARMED when the switch turns on, but only if no critical faults are active
        -- does not yet check for critical faults
        state.mode = "ARMED"
    elseif state.mode == "ARMED" then
        -- ARMED -> FAILSAFE when any trigger fires
        local fault, reason = checkFaults()
        if fault then
            state.lastError = reason
            state.mode = "FAILSAFE"
            return
        end

        state.hoverRPM = hardware.findHoverRPM(state.balloon_lift, state.pressure, state.constant)
        hardware.setRPM(state.hoverRPM)
        state.cmdRPM = state.hoverRPM
    end
end

local last_switch = redstone.getInput("bottom")

local last = os.clock()

while true do
    local tick_timer = os.startTimer(0.05)

    local now = os.clock()

    -- read all sensors into state
    state.height = hardware.alt_sensor.getHeight()
    if hardware.velocity_sensor then
        state.hor_velocity = hardware.velocity_sensor.getVelocity()
    end
    state.ver_velocity = hardware.alt_sensor.getVerticalSpeed()
    state.pressure = hardware.alt_sensor.getAirPressure()
    state.pitch, state.roll = hardware.getAngles()
    state.pitch_rate, state.yaw_rate, state.roll_rate = hardware.getAngularRates()
    state.balloon_lift = hardware.gas_burners[1].getBalloonLift()
    state.propellerRPM = math.abs(hardware.propeller_bearings[1].getRotationSpeed()) * 10 / 3

    -- set timing / health
    state.dt = now - last
    last = now
    if state.dt > 0 then state.hz = 1 / state.dt end

    -- check that the lever to arm the ship is enabled
    local armed = redstone.getInput("bottom")

    -- check to make sure ship does not become armed immediately upon assembly
    local rising = armed and not last_switch
    mode(armed, rising)

    -- test prints
    print("state.hz: " .. state.hz)
    print("state.dt: " .. state.dt)
    print("state.mode: " .. state.mode)

    -- reset last armed position
    last_switch = armed

    if state.mode == "DISARMED" then
        logLine("========== NEW LOOP ==========")
        for property, property_value in pairs(state) do
            local text = property .. ": " .. property_value
            logLine(text)
        end
    end
    

    repeat -- prevents loop from breaking
        local _, id = os.pullEvent("timer")
    until id == tick_timer
end