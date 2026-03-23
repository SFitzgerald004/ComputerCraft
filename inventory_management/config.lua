-- config.lua
-- Config file to hold the numbers for the collector / reader channels regarding inventory management

-- Request Channel is what the reader sends requests on. From here, the collector will craft responses to messages on this channel
REQUEST_CHANNEL = 88

-- Response Channel is what the collector transmits to. This is what the reader uses to display the information
RESPONSE_CHANNEL = 99
