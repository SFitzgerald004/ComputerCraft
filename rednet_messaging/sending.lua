-- sending.lua
dofile("rednet_messaging/config.lua")
local modem = peripheral.find("modem")

if not modem then
    error("No modem attached.", 0)
else 
    print("Modem found")
end

-- opens rednet on the modem; checks if wireless first
if not modem.isWireless() then
    if rednet.isOpen() then
        print("Rednet already opened")
    else
        print("Opening rednet")
        rednet.open("top") -- modem required to be on top
    end
else
    peripheral.find("modem", rednet.open)
end

local message = io.read()
rednet.broadcast(message, PROTOCOL)