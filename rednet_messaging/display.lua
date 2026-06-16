-- display.lua
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

while true do
    local event, sender, message, protocol = os.pullEvent("rednet_message")
    if protocol ~= nil then
        print("Recieved message from " .. sender .. " with protocol " .. protocol .. " and message " .. message)
    else
        print("Recieved message from " .. sender .. " and message " .. message)
    end
end