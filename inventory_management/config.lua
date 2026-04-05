-- config.lua
-- Config file to hold the numbers for the collector / reader channels regarding inventory management

-- Request Channel is what the reader sends requests on. From here, the collector will craft responses to messages on this channel
REQUEST_CHANNEL = 88

-- Response Channel is what the collector transmits to. This is what the reader uses to display the information
RESPONSE_CHANNEL = 99

-- Register Channel is used to tell the reader the number of different computers that are sending out information
REGISTER_CHANNEL = 77

-- Used only for fluid storage collection
-- Each tank needs a hardcoded max fluid amount for storage. Unfortunately there is no way to obtain that data through the API itself
--
-- Side-based tank assignments by collector computer ID.
-- side must be one of: top, bottom, left, right, front, back
-- max_capacity should be in the same unit used by CC:Tweaked tank.amount.
TANK_ASSIGNMENTS = {
	-- [7] = {
	--     back = {
	--         id = "main_tank",
	--         name = "Main Tank",
	--         max_capacity = 81000
	--     }
	-- }
    [7] = {
        back = {
            id = "main_tank",
            name = "Main Tank",
            max_capacity = 2304000
        }
    }
}
