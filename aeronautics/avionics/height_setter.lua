-- used to set the desired hover height of
-- the contraption. takes analog lever input
-- of 0-15, and sets height accordingly

local speed_controller = peripheral.find("Create_RotationSpeedController")
local throt_lever = peripheral.find("throttle_lever")

-- check all peripherals are found
-- assert((speed_controller), (throt_lever)), "peripherals not found; Is the controller connected?")
assert(speed_controller, "Speed Controller not found.")
assert(throt_lever, "Throttle Lever not found.")

if !speed_controller and !throt_lever then
    error("No peripherals found; Is the controller connected?")
elseif !speed_controller or !throt_lever then
    error("At least one peripheral not found; Make sure the contraption is built.")
end

-- actual function call
local function set_throttle(pos)
    throt_lever.setSignal(pos)
    -- set speed controller
    -- take pos, multiply by 13.3, round
    local rpm_value = math.floor((pos * 13.3) + 0.5)
    speed_controller.setTargetSpeed(rpm_value)
end