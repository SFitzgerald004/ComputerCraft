-- inv_collector.lua
-- Used to collect and send out the inventory data to the computer running inv_reader.lua
dofile("inventory_management/config.lua")
local inventories = { peripheral.find("inventory") }
local modem = peripheral.wrap("top")
local inventory_data = {}
local instance_data = nil

-- Opens channel to recieve requests from reader
modem.open(REQUEST_CHANNEL)
-- Opens channel to send data to reader
modem.open(RESPONSE_CHANNEL)
-- Opens channel to register to inventory collection
modem.open(REGISTER_CHANNEL)

-- Load library files
dofile("inventory_management/inv_libraries/chest.lua")

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

            -- sends peripheral off to library
            for i, inventory in pairs(inventories) do
                instance_data = nil
                -- what this will do is for every instance of an inventory, it will be sent 
                -- out to the file of its specific inventory type to send back the data
                if peripheral.hasType(inventory, "chest") then
                    -- send to chest.lua
                    -- add to instance_data
                    instance_data = read(inventory)
                elseif peripheral.hasType(inventory, "storage_drawer") then -- double check this naming
                    -- send to storage_drawer.lua
                    -- add to instance_data
                elseif peripheral.hasType(inventory, "tank") then -- also double check this naming
                    -- send off to tank.lua
                    -- add to instance_data
                end

                -- add to inventory_data field
                if instance_data ~= nil then
                    table.insert(inventory_data, instance_data)
                end
            end

            -- transmits data
            modem.transmit(RESPONSE_CHANNEL, RESPONSE_CHANNEL, inventory_data)
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