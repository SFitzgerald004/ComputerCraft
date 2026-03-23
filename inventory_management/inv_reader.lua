-- inv_reader.lua
-- This is the program used by the computer used to view the inventories of connected blocks
-- This is NOT used on the computers collecting the data
local monitor = peripheral.find("monitor")
local modem = peripheral.wrap("top")
dofile("inventory_management/config.lua")

-- open modem on request / recieve channel
modem.open(RESPONSE_CHANNEL)
modem.open(REQUEST_CHANNEL)

os.startTimer(5)
while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent()
    if event == "timer" then
        -- send collection response
        modem.transmit(REQUEST_CHANNEL, RESPONSE_CHANNEL, "Collect Data")

        os.startTimer(5)
    elseif event == "modem_message" then
        -- redraw monitor with new data
        -- monitor rendering
        local y = 1
        monitor.setCursorPos(1, y)
        monitor.clear()

        monitor.write("========== INVENTORY RESPONSE " .. os.time() .. " ==========")
        y = 3
        for i, record in pairs(message) do
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

                monitor.setCursorPos(1, y)
                y = y + 1
                monitor.write(field.label.. ": " .. record[field.key])
            end
            y = y + 1
        end
        monitor.setCursorPos(1, y)
        monitor.write("==========================================")
    end
end

