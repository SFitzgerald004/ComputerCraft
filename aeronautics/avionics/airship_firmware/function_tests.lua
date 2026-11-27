-- function_tests.lua

-- based on V3.1
local MASS = 1230.25
local GRAVITY = 11.0

-- dynamic hover constant computation
local function calibrateThrustConstant(balloon_lift, air_pressure, mass, gravity, rpm)
    local ship_weight = mass * gravity -- phys_assembler.getMass() * gimbal_sensor.getGravity()
    return (ship_weight - balloon_lift) / (math.abs(rpm) * air_pressure) -- (ship_weight - total_balloon_lift) / (speed_controller.getTargetSpeed() * air_pressure)
end

local function findHoverRPM(balloon_lift, air_pressure, mass, gravity, constant)
    local ship_weight = mass * gravity -- phys_assembler.getMass() * gimbal_sensor.getGravity()
    return math.floor((ship_weight - balloon_lift) / (constant * air_pressure) + 0.5)
    -- return (ship_weight - balloon_lift) / (constant * air_pressure)
end

-- Calibrated based on analog throttle level 7
local c = calibrateThrustConstant(10994.96, 0.9681, MASS, GRAVITY, 93)
print(string.format("c = %.2f", c))

-- Test data: { analog strength, actual RPM, balloon lift, pressure }
local rows = {
    { 7,  93, 10994.96, 0.9681 },   -- calibration row: will match by definition
    { 8, 106, 11000.56, 0.8474 },   -- every row below is a real prediction
    { 9, 120, 10990.08, 0.7528 },
    {10, 133, 10995.01, 0.6777 },
    {11, 146, 10999.25, 0.6162 },
    {12, 160, 10991.53, 0.5646 },
    {13, 173, 10995.22, 0.5213 },
    {14, 186, 10998.44, 0.4841 },
    {15, 200, 10992.19, 0.4517 },
}

for _, r in ipairs(rows) do
    local predicted = findHoverRPM(r[3], r[4], MASS, GRAVITY, c)
    print(string.format("Str %2d  actual %3d  predicted %6.2f  error %+5.2f",
        r[1], r[2], predicted, predicted - r[2]))
end