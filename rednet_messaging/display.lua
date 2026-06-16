-- display.lua
dofile("rednet_messaging/config.lua")
local modem = peripheral.find("modem")

if not modem then
    error("No modem attached.", 0)
end

-- opens rednet on the modem
if rednet.isOpen() then
    print("Rednet already opened")
else
    print("Opening rednet")
    rednet.open("top") -- modem required to be on top
end

print("========== Now showing messages with protocol " .. PROTOCOL .. " ==========")

while true do
    local event, sender, message, protocol = os.pullEvent("rednet_message")
    if protocol == PROTOCOL then
        print("Recieved message from " .. sender .. " with protocol " .. protocol .. " and message " .. message)
    end
end