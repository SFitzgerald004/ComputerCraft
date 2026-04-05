-- inv_collector.lua
-- Used to collect and send out the inventory data to the computer running inv_reader.lua
dofile("inventory_management/config.lua")
local modem = peripheral.wrap("top")
local inventory_data = {}
local SIDES = { "top", "bottom", "left", "right", "front", "back" }

-- Opens channel to recieve requests from reader
modem.open(REQUEST_CHANNEL)
-- Opens channel to send data to reader
modem.open(RESPONSE_CHANNEL)
-- Opens channel to register to inventory collection
modem.open(REGISTER_CHANNEL)

-- Load library files
local read_chest = dofile("inventory_management/inv_libraries/chest.lua")
local read_tank = dofile("inventory_management/inv_libraries/tank.lua")

local function has_entries(t)
    return type(t) == "table" and next(t) ~= nil
end

local function build_side_map()
    local side_map = {}

    for _, side_name in ipairs(SIDES) do
        local peripheral_name = peripheral.getName(side_name)
        if peripheral_name ~= nil then
            side_map[side_name] = peripheral_name
        end
    end

    return side_map
end

local function get_tank_assignments_for_computer()
    if type(TANK_ASSIGNMENTS) ~= "table" then
        return nil
    end

    local computer_id = os.getComputerID()
    local assignments = TANK_ASSIGNMENTS[computer_id]
    if type(assignments) ~= "table" then
        return nil
    end

    return assignments
end

local function validate_tank_assignments(side_map, assignments)
    if not has_entries(assignments) then
        return
    end

    for side_name, metadata in pairs(assignments) do
        local actual_name = side_map[side_name]
        if actual_name == nil then
            print("Tank config warning: no peripheral on side", side_name)
        elseif not peripheral.hasType(actual_name, "fluid_storage") then
            print("Tank config warning: side", side_name, "is not fluid_storage")
        elseif type(metadata) == "table" and type(metadata.peripheral_name) == "string" and metadata.peripheral_name ~= actual_name then
            print("Tank config warning: side", side_name, "expected", metadata.peripheral_name, "but found", actual_name)
        end
    end
end

local function collect_configured_tanks(side_map, assignments)
    for side_name, metadata in pairs(assignments) do
        local inventory_name = side_map[side_name]
        if inventory_name ~= nil and peripheral.hasType(inventory_name, "fluid_storage") then
            local ok, data = pcall(read_tank, inventory_name, metadata, side_name)
            if ok and data ~= nil then
                table.insert(inventory_data, data)
            elseif not ok then
                print("Tank read failed for", inventory_name, tostring(data))
            end
        end
    end
end

local function listenForRequests()
    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if channel == REQUEST_CHANNEL then
            print("Event Name:", event)
            print("Side:", side)
            print("Channel:", channel)
            print("Reply Channel:", replyChannel)
            print("Message:", message)
            print("Distance:", distance)

            local side_map = build_side_map()
            local tank_assignments = get_tank_assignments_for_computer()

            if has_entries(tank_assignments) then
                validate_tank_assignments(side_map, tank_assignments)
                collect_configured_tanks(side_map, tank_assignments)
            end

            -- sends peripheral off to library
            for _, inventory_name in ipairs(peripheral.getNames()) do
                if peripheral.hasType(inventory_name, "inventory") then
                    -- should be separate calls or at least a way to determine the type of storage
                    -- for example, could pass in either 'minecraft:chest' or 'minecraft:barrel' to help determine which kind of path to take

                    local ok, data = pcall(read_chest, inventory_name)
                    if ok and data ~= nil then
                        table.insert(inventory_data, data)
                    elseif not ok then
                        print("Inventory read failed for", inventory_name, tostring(data))
                    end
                elseif not has_entries(tank_assignments) and peripheral.hasType(inventory_name, "fluid_storage") then
                    -- no side assignment configured for this collector, so gather all fluid storage peripherals.
                    local ok, data = pcall(read_tank, inventory_name, nil, nil)
                    if ok and data ~= nil then
                        table.insert(inventory_data, data)
                    elseif not ok then
                        print("Tank read failed for", inventory_name, tostring(data))
                    end
                end
            end

            -- transmits data
            modem.transmit(RESPONSE_CHANNEL, RESPONSE_CHANNEL, { id = os.getComputerID(), data = inventory_data })
            inventory_data = {}
        end
    end
end

local function sendPings()
    while true do
        modem.transmit(REGISTER_CHANNEL, RESPONSE_CHANNEL, os.getComputerID())
        os.sleep(1)
    end
end

-- run both functions together and wait for both to complete
parallel.waitForAll(listenForRequests, sendPings)