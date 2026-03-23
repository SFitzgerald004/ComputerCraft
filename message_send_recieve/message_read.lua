-- message_read.lua

-- assumes wireless
local modem = peripheral.find("modem") or error("[ERROR] No modem detected")
local read_channel = 33

-- check if read channel is open
if (modem.isOpen(read_channel)) then
    print("[MODEM] Channel", read_channel, "is already open")
else
    modem.open(read_channel)
    print("[MODEM] Channel", read_channel, "is now open")
end

local name, channel, reply_channel, message, distance
repeat
    name, channel, reply_channel, message, distance = os.pullEvent("modem_message")
    print("[MESSAGE]", name, channel, reply_channel, message, distance)
until read_channel == 9999