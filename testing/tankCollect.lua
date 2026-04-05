-- tankCollect.lua

local methods = peripheral.getMethods("back") or {}
print("Methods:", textutils.serialize(methods))

local tankPeriph = peripheral.wrap("back")
if tankPeriph ~= nil then
    local tanks = tankPeriph.tanks()

    local current = 0
    local max = 0

    for value, tank in pairs(tanks) do
        print("Tank:", value, textutils.serialize(tank))
        current = current + (tank.amount or 0)
        max = max + (tank.capacity or 0)
    end

    local percentage = 0
    if max > 0 then
        percentage = (current / max) * 100
    end

    print("Used:", current .. "/" .. max)
    print(string.format("Usage: %.1f%%", percentage))
else
    print("No peripheral on back")
end