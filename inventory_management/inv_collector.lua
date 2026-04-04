-- inv_collector.lua
-- Used to collect and send out the inventory data to the computer running inv_reader.lua
dofile("inventory_management/config.lua")
local modem = peripheral.wrap("top")
local inventory_data = {}

-- Opens channel to recieve requests from reader
modem.open(REQUEST_CHANNEL)
-- Opens channel to send data to reader
modem.open(RESPONSE_CHANNEL)
-- Opens channel to register to inventory collection
modem.open(REGISTER_CHANNEL)

-- Load library files
local read_chest = dofile("inventory_management/inv_libraries/chest.lua")

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
            for _, inventory_name in ipairs(peripheral.getNames()) do
                if peripheral.hasType(inventory_name, "inventory") then
                    local ok, data = pcall(read_chest, inventory_name)
                    if ok and data ~= nil then
                        table.insert(inventory_data, data)
                    elseif not ok then
                        print("Inventory read failed for", inventory_name, tostring(data))
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