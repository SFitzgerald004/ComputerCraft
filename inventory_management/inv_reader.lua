-- inv_reader.lua
-- This is the program used by the computer used to view the inventories of connected blocks
-- This is NOT used on the computers collecting the data
local monitor = peripheral.find("monitor")
local modem = peripheral.wrap("top")
dofile("inventory_management/config.lua")

-- open modem on request / recieve / register channels
modem.open(RESPONSE_CHANNEL)
modem.open(REQUEST_CHANNEL)
modem.open(REGISTER_CHANNEL)

-- these tables are used to keep track of the computers registered to send out information
local collectors = {}
local last_seen = {}
local responses = {}

local function count(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

os.startTimer(5)
while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent()
    if event == "timer" then
        -- check if any computers need to be pruned
        for id in pairs(collectors) do
            if os.epoch("utc") - last_seen[id] > 3000 then
                collectors[id] = nil
                last_seen[id] = nil
            end
        end

        -- reset responses table
        responses = {}
        -- send collection response
        modem.transmit(REQUEST_CHANNEL, RESPONSE_CHANNEL, "Collect Data")

        os.startTimer(5)
    elseif event == "modem_message" then
        if channel == RESPONSE_CHANNEL then
            -- collect all info into responses table
            table.insert(responses, message)

            -- check if all collectors have responded
            if #responses == count(collectors) then
                -- redraw monitor with new data
                -- monitor rendering
                local y = 1
                monitor.setCursorPos(1, y)
                monitor.clear()

                -- force white text coloring
                monitor.setTextColor(colors.white)
                monitor.write("========== INVENTORY RESPONSE " .. os.time() .. " ==========")
                y = 3
                table.sort(responses, function(a, b) return a.id < b.id end)
                for k, response in pairs(responses) do
                    for i, record in pairs(response.data) do
                        local name = record.name
                        local percentage = record.percentage
                        local fields = record.fields

                        for j, field in pairs(fields) do
                            local key = field.key
                            local label = field.label
                            monitor.setTextColor(colors.white)

                            if key == "capacity_used" then
                                if percentage >= 90 then
                                    monitor.setTextColor(colors.red)
                                elseif percentage >= 75 then
                                    monitor.setTextColor(colors.orange)
                                elseif percentage >= 50 then
                                    monitor.setTextColor(colors.yellow)
                                end
                            end

                            -- Need to adjust coloring for just percentage / fraction

                            monitor.setCursorPos(1, y)
                            y = y + 1
                            monitor.write(field.label.. ": " .. record[field.key])
                        end
                        y = y + 1
                    end
                end
                monitor.setTextColor(colors.white)
                monitor.setCursorPos(1, y)
                monitor.write("===============================================")

                -- clear responses table
                responses = {}
            end
        elseif channel == REGISTER_CHANNEL then
            collectors[message] = true
            last_seen[message] = os.epoch("utc")
        end
    end
end