-- message_read.lua
dofile("message_send_recieve/config.lua")

-- assumes wireless
local modem = peripheral.find("modem") or error("[ERROR] No modem detected")

-- check if read channel is open
if (modem.isOpen(READ_CHANNEL)) then
    print("[MODEM] Channel", READ_CHANNEL, "is already open")
else
    modem.open(READ_CHANNEL)
    print("[MODEM] Channel", READ_CHANNEL, "is now open")
end

local event, name, channel, reply_channel, message, distance
repeat
    event, name, channel, reply_channel, message, distance = os.pullEvent("modem_message")
    print("[MESSAGE]", event, name, channel, reply_channel, message, distance)
until READ_CHANNEL == 9999