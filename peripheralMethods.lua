-- peripheralMethods.lua
-- Used to collect and output peripheral methods

local sides = {"front", "back", "bottom", "top", "left", "right"} -- six sides in total
local peripherals = {}

for index, side in ipairs(sides) do
    print(index, side)
    -- checks if anything is attached to the given side
    if peripheral.isPresent(side) then
        print(" !- Peripheral found on side", side)
        print(" !-", peripheral.getName())
        table.insert(peripherals, peripheral.getName(side))
    else
        print(" - No peripheral found on side", side)
    end
end

print(peripherals)