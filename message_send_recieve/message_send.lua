-- message_send.lua
local modem = peripheral.find("modem") or error("[ERROR] No modem detected")

dofile("message_send_recieve/config.lua")

-- check channel availibility
if (modem.isOpen(SEND_CHANNEL)) then
    print("[MODEM] Channel", SEND_CHANNEL, "is already open")
else
    modem.open(SEND_CHANNEL)
    print("[MODEM] Channel", SEND_CHANNEL, "is now open")
end

print("What would you like to say? (input '/q' to quit)")
repeat
    write(">")
    local message = read()
    if message ~= "/q" then
        modem.transmit(SEND_CHANNEL, SEND_CHANNEL, message)
    end
until message == "/q"
