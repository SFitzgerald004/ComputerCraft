-- detect almanac
local almanac = peripheral.find("almanac")
local rain_gauge = peripheral.find("rain_gauge")

if !almanac or !rain_gauge then
    error("[WEATHER] No almanac / rain gauge peripheral(s) found")
end

-- almanac peripheral
local season_info = {}
season_info.season = almanac.getSeason()
season_info.subSeason = almanac.getSubSeason()
season_info.day = almanac.getDay()
season_info.moonPhase = almanac.getMoonPhase()
season_info.day = almanac.getDay()

-- rain gauge peripheral
local weather = {}
weather.precipitation = rain_gauge.getPrecipitation()
weather.total = rain_gauge.getTotal()