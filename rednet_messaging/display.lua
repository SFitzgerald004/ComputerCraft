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
    rednet.open("modem")
end

local id, message = rednet.receive()
print(("Computer %d sent message %s"):format(id, message))