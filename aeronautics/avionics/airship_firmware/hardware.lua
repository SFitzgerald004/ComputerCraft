--peripherals

local avi_ship = {}

-- singular peripherals
local speed_controller = peripheral.find("Create_RotationSpeedController")
local throt_lever = peripheral.find("throttle_lever")
local gimbal_sensor = peripheral.find("gimbal_sensor")
local nav_table = peripheral.find("navigation_table")
local alt_sensor = peripheral.find("altitude_sensor")
local phys_assembler = peripheral.find("physics_assembler")
-- multiple peripherals
local velocity_sensor = peripheral.find("velocity_sensor") -- only needs one, altitude sensor can get vertical speed
local gas_burners = { peripheral.find("gas_provider") } -- gas burner calls might only be used for setting specific heights
local propeller_bearings = { peripheral.find("propeller_bearing") }

-- assert to check for each peripheral
assert(speed_controller, "Speed Controller not found.")
assert(throt_lever, "Throttle Lever not found.")
assert(gimbal_sensor, "Gimbal Sensor not found.")
assert(nav_table, "Navigation Table not found.")
assert(alt_sensor, "Altitude Sensor not found.")
assert(phys_assembler, "Physics Assembler not found.")
assert(#gas_burners > 0, "No Gas Burners found.")
assert(velocity_sensor, "No Velocity Sensor found.")
assert(#propeller_bearings > 0, "No Propeller Bearings found.")

-- expose peripherals
avi_ship.throt_lever = throt_lever
avi_ship.nav_table = nav_table
avi_ship.alt_sensor = alt_sensor
avi_ship.gas_burners = gas_burners
avi_ship.velocity_sensor = velocity_sensor
avi_ship.propeller_bearings = propeller_bearings

-- constants
local PROP_DIR = -1 -- propeller direction; used to set speed controller to clockwise rotation

-- world / subworld values from peripherals
local MASS = phys_assembler.getMass()
assert(MASS > 0, "Mass is 0, ship not assembled.")

local g = gimbal_sensor.getGravity()
local GRAVITY = math.sqrt(g[1]^2 + g[2]^2 + g[3]^2)

-- getters / setters
-- speed_controller
function avi_ship.setRPM(rpm)
    rpm = math.max(-256, math.min(256, rpm))
    rpm = math.floor(rpm + 0.5)
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

-- returns: ax, ay, az
function avi_ship.getLinearAcceleration()
    local la = gimbal_sensor.getLinearAcceleration()
    return la[1], la[2], la[3]
end

--[[ HOVER FEEDFORWARD
Predicts the propeller RPM needed to hover, using current conditions.
The props only need to carry what the balloon doesn't:

    Prop thrust needed = W - B
    Effective thrust   = c * RPM * P
    ->  hover RPM      = (W - B) / (c * P)

    W = ship weight  (MASS * GRAVITY)          physics_assembler + gimbal_sensor
    B = balloon lift                           gas_provider.getBalloonLift()
    P = air pressure (1.0 = sea level)         altitude_sensor.getAirPressure()
    c = thrust constant (thrust per RPM*P)     calibrated, see below

Two steps; they must use data from DIFFERENT moments, or the
math is circular (it just returns the RPM you put in):

  1. calibrateThrustConstant(): run ONCE during a steady hover
     (|VS| ~ 0), using the props' ACTUAL speed
     (propeller_bearing.getRotationSpeed() * 10/3). Store the result.
       c = (W - B) / (RPM * P)
  2. findHoverRPM(): run EVERY tick with live B and P plus the stored c.

Notes:
  - c depends on prop design (sails^1.5). Recalibrate after rebuilding props.
    Beta V3.1 (4-block blades): c ~ 28.19
  - Returns a decimal. Rounding happens once, in setRPM().
]]

-- dynamic hover constant computation
function avi_ship.calibrateThrustConstant(balloon_lift, air_pressure, rpm)
    local ship_weight = MASS * GRAVITY
    return (ship_weight - balloon_lift) / (math.abs(rpm) * air_pressure)
end

function avi_ship.findHoverRPM(balloon_lift, air_pressure, constant)
    local ship_weight = MASS * GRAVITY
    return (ship_weight - balloon_lift) / (constant * air_pressure)
end

return avi_ship