--peripherals

local hardware = {}

-- used to track missing peripheral objects
hardware.missing = {}

-- look to find an optional peripheral and record it if not found. for mission, advisory and required to arm (only during operating procedures)
local function optional(p_type, label)
    local p = peripheral.find(p_type)
    if not p then
        table.insert(hardware.missing, label)
    end
    return p
end

-- singular peripherals
local speed_controller = peripheral.find("Create_RotationSpeedController")
local throt_lever = peripheral.find("throttle_lever")
local gimbal_sensor = peripheral.find("gimbal_sensor")
local alt_sensor = peripheral.find("altitude_sensor")
local phys_assembler = peripheral.find("physics_assembler")
-- multiple peripherals
local gas_burners = { peripheral.find("gas_provider") } -- gas burner calls might only be used for setting specific heights
local propeller_bearings = { peripheral.find("propeller_bearing") }

-- peripheral checks per tier
-- flight critical; ship cannot be armed
assert(speed_controller, "Speed Controller not found.")
assert(throt_lever, "Throttle Lever not found.")
assert(gimbal_sensor, "Gimbal Sensor not found.")
assert(alt_sensor, "Altitude Sensor not found.")
assert(phys_assembler, "Physics Assembler not found.")
assert(#gas_burners > 0, "No Gas Burners found.")
assert(#propeller_bearings > 0, "No Propeller Bearings found.")
-- required to arm; cannot arm if missing at startup, set to orange warning in flight
-- mission; orange warning, and the modes that need them become unavailable
hardware.nav_table = optional("navigation_table", "Navigation Table")
hardware.velocity_sensor = optional("velocity_sensor", "Velocity Sensor")
-- advisory; yellow warning only

-- expose peripherals
hardware.throt_lever = throt_lever
hardware.alt_sensor = alt_sensor
hardware.gas_burners = gas_burners
hardware.propeller_bearings = propeller_bearings

-- constants
local PROP_DIR = -1 -- propeller direction; used to set speed controller to clockwise rotation

-- world / subworld values from peripherals
local MASS = phys_assembler.getMass()
assert(MASS > 0, "Mass is 0, ship not assembled.")

local g = gimbal_sensor.getGravity()
local GRAVITY = math.sqrt(g[1]^2 + g[2]^2 + g[3]^2)

-- getters / setters
-- speed_controller
function hardware.setRPM(rpm)
    rpm = math.max(-256, math.min(256, rpm))
    rpm = math.floor(rpm + 0.5)
    return speed_controller.setTargetSpeed(rpm * PROP_DIR)
end

-- gimbal_sensor
-- returns: pitch, roll
function hardware.getAngles()
    local a = gimbal_sensor.getAngles()
    return a[1], a[2]
end

-- returns: pitchRate, yawRate, rollRate
function hardware.getAngularRates()
    local ar = gimbal_sensor.getAngularRates()
    return ar[1], ar[2], ar[3]
end

-- returns: ax, ay, az
function hardware.getLinearAcceleration()
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
function hardware.calibrateThrustConstant(balloon_lift, air_pressure, rpm)
    local ship_weight = MASS * GRAVITY
    return (ship_weight - balloon_lift) / (math.abs(rpm) * air_pressure)
end

function hardware.findHoverRPM(balloon_lift, air_pressure, constant)
    local ship_weight = MASS * GRAVITY
    return (ship_weight - balloon_lift) / (constant * air_pressure)
end

return hardware