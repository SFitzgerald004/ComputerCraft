-- zinc_homelander.lua

local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")
local decoder = dfpwm.make_decoder()

if speaker then
    print("Speaker found")
else
    error("No speaker connected")
end

for chunk in io.lines("hey_deep/whats_the_box_made_of.dfpwm", 16 * 1024) do
    local buffer = decoder(chunk)

    while not speaker.playAudio(buffer) do
        os.pullEvent("speaker_audio_empty")
    end
end

return "zinc"