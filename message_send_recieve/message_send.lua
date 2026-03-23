-- message_send.lua
local modem = peripheral.find("modem") or error("[ERROR] No modem detected")
local send_channel = 33

-- check channel availibility
if (modem.isOpen(send_channel)) then
    print("[MODEM] Channel", send_channel, "is already open")
else
    modem.open(send_channel)
    print("[MODEM] Channel", send_channel, "is now open")
end

print("What would you like to say? (input '/q' to quit)")
repeat
    write(">")
    local message = read()
    if message ~= "/q" then
        modem.transmit(send_channel, send_channel, message)
    end
until message == "/q"
