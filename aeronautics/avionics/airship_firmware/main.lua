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

local ok, avi_ship = pcall(require, "avi_ship")

if not ok then
    error("avi_ship module is missing, was it deleted?", 1)
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

local last = os.clock()

while true do
    local now = os.clock()
    -- read all sensors into state
    state.height = ship.alt_sensor.getHeight()
    state.hor_velocity = ship.velocity_sensor.getVelocity()
    state.ver_velocity = ship.alt_sensor.getVerticalSpeed()
    state.pressure = ship.alt_sensor.getAirPressure()
    state.pitch, state.roll = ship.getAngles()
    state.pitch_rate, state.yaw_rate, state.roll_rate = ship.getAngularRates()
    state.balloon_lift = ship.gas_burners[1].getBalloonLift()
    state.propellerRPM = math.abs(ship.propeller_bearings[1].getRotationSpeed()) * 10 / 3

    -- set timing / health
    state.dt = now - last
    last = now
    if state.dt > 0 then state.hz = 1 / state.dt end

    -- test prints
    print("state.hz: " .. state.hz)
    print("state.dt: " .. state.dt)

    sleep(0.05) -- prevents loop from breaking
end