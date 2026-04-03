-- chest.lua

-- iterate through and count every slot
local function read_chest(chest)
    if chest == nil or type(chest.size) ~= "function" or type(chest.list) ~= "function" then
        return nil
    end

    local current = 0
    local max = chest.size() * 64

    for _, item in pairs(chest.list()) do
        current = current + item.count
    end

    local percentage = (current / max) * 100
    local fraction = (current .. "/" .. max)
    local percentage_used = string.format("%.1f %%", percentage)

    return {
        name = peripheral.getName(chest),
        capacity_used = percentage_used .. " (" .. fraction .. ")",
        percentage = percentage,
        fields = {
            { key = "name", label = "Name" },
            { key = "capacity_used", label = "Capacity Used" }
        }
    }
end

return read