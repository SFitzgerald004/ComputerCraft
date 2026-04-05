-- tank.lua

local function read_tank(inventory_name, metadata, side_name)
    if type(inventory_name) ~= "string" then
        return nil
    end

    local ok_tanks, tanks = pcall(peripheral.call, inventory_name, "tanks")
    if not ok_tanks or type(tanks) ~= "table" then
        return nil
    end

    local configured_name = nil
    local max_capacity = nil
    if type(metadata) == "table" then
        if type(metadata.name) == "string" and metadata.name ~= "" then
            configured_name = metadata.name
        end
        if type(metadata.max_capacity) == "number" and metadata.max_capacity > 0 then
            max_capacity = metadata.max_capacity
        end
    end

    local current = 0
    local fluid_count = 0
    local primary_fluid_name = nil

    for _, tank in pairs(tanks) do
        if type(tank) == "table" then
            local amount = tank.amount or 0
            current = current + amount

            if amount > 0 then
                fluid_count = fluid_count + 1
                if primary_fluid_name == nil and type(tank.name) == "string" then
                    primary_fluid_name = tank.name
                end
            end
        end
    end

    local percentage = 0
    local capacity_used
    if max_capacity ~= nil then
        percentage = (current / max_capacity) * 100
        capacity_used = string.format("%.1f %% (%d/%d)", percentage, current, max_capacity)
    else
        capacity_used = tostring(current) .. " / unknown"
    end

    local display_name = configured_name or inventory_name
    if type(side_name) == "string" and side_name ~= "" then
        display_name = display_name .. " [" .. side_name .. "]"
    end

    local fluid_summary = "Empty"
    if fluid_count > 1 then
        fluid_summary = "Mixed (" .. tostring(fluid_count) .. " fluids)"
    elseif fluid_count == 1 and primary_fluid_name ~= nil then
        fluid_summary = primary_fluid_name
    end

    return {
        name = display_name,
        capacity_used = capacity_used,
        percentage = percentage,
        fluid = fluid_summary,
        fields = {
            { key = "name", label = "Name" },
            { key = "capacity_used", label = "Capacity Used" },
            { key = "fluid", label = "Fluid" }
        }
    }
end

return read_tank