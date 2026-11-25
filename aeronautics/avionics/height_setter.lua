-- used to set the desired hover height of
-- the contraption. takes analog lever input
-- of 0-15, and sets height accordingly

local speed_controller = peripheral.find("Create_RotationSpeedController")
local throt_lever = peripheral.find("throttle_lever")

-- check all peripherals are found
-- assert((speed_controller), (throt_lever)), "peripherals not found; Is the controller connected?")
assert(speed_controller, "Speed Controller not found.")
assert(throt_lever, "Throttle Lever not found.")

if not speed_controller and  not throt_lever then
    error("No peripherals found; Is the controller connected?")
elseif not speed_controller or not throt_lever then
    error("At least one peripheral not found; Make sure the contraption is built.")
end

-- actual function call
local function set_throttle(pos, clockwise)
    throt_lever.setSignal(pos)
    -- set speed controller
    -- take pos, multiply by 13.3, round
    local rpm_value = math.floor((pos * 13.3) + 0.5)
    -- !! VERY IMPORTANT

    -- the speed controller is clamped to +-256. that means
    -- if you set the wrong side, the ship will go out of balance.
    -- ALWAYS check the correct rotating direction
    -- negative is clockwise, positive is counter clockwise
    if clockwise == true then
        rpm_value = rpm_value * -1
    end

    speed_controller.setTargetSpeed(rpm_value)
    print("Setting Lever to", pos, "\nSetting Speed Controller to", rpm_value)
end

set_throttle(10)