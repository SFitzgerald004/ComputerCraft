-- peripheralMethods.lua
-- Used to collect and output peripheral methods

local sides = {"front", "back", "bottom", "top", "left", "right"} -- six sides in total
local peripherals = {}
local currentPeriph

for index, side in ipairs(sides) do
    print(index, side)
    -- checks if anything is attached to the given side
    if peripheral.isPresent(side) then
        print(" !- Peripheral found on side", side)
        currentPeriph = peripheral.wrap(side)
        print(" !-", peripheral.getName(currentPeriph))
        table.insert(peripherals, currentPeriph)
    else
        print(" - No peripheral found on side", side)
    end
end

print(peripherals)