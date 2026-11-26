--peripherals

local avi_ship = {}

local speed_controller = peripheral.find("Create_RotationSpeedController")
local throt_lever = peripheral.find("throttle_lever")
local gimbal_sensor = peripheral.find("gimbal_sensor")
local nav_table = peripheral.find("navigation_table")
local alt_sensor = peripheral.find("altitude_sensor")
local gas_burners = { peripheral.find("gas_provider") } -- gas burner calls might only be used for setting specific heights

-- assert to check for each peripheral
assert(speed_controller, "Speed Controller not found.")
assert(throt_lever, "Throttle Lever not found.")
assert(gimbal_sensor, "Gimbal Sensor not found.")
assert(nav_table, "Navigation Table not found.")
assert(alt_sensor, "Altitude Sensor not found.")
assert(#gas_burners > 0, "No Gas Burners found.")

-- expose peripherals
avi_ship.throt_lever = throt_lever
avi_ship.nav_table = nav_table
avi_ship.alt_sensor = alt_sensor
avi_ship.gas_burners = gas_burners

-- constants
local PROP_DIR = -1 -- propeller direction; used to set speed controller to clockwise rotation
avi_ship.HOVER_K = 90.13 -- average product of rpm and pressure over 8 tests

-- getters / setters
-- speed_controller
function avi_ship.setRPM(rpm)
    rpm = math.max(-256, math.min(256, rpm))
    return speed_controller.setTargetSpeed(rpm * PROP_DIR)
end

-- gimbal_sensor
-- returns: pitch, roll
function avi_ship.getAngles()
    local a = gimbal_sensor.getAngles()
    return a[1], a[2]
end

-- returns: pitchRate, yawRate, rollRate
function avi_ship.getAngularRates()
    local ar = gimbal_sensor.getAngularRates()
    return ar[1], ar[2], ar[3]
end

-- returns: wx, wy, wz
function avi_ship.getLinearAcceleration()
    local la = gimbal_sensor.getLinearAcceleration()
    return la[1], la[2], la[3]
end

return avi_ship