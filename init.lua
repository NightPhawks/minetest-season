--season mod init file

--init constant
local mt = minetest

season = {}

local settings = mt.settings

local polar_seasons = {"Night", "Day"}
local temperate_seasons = {"Winter", "Spring", "Summer", "Autumn"}
local tropical_seasons = {"Wet season", "Dry season"}

local priority = {
	"equatorial",
	"temperate",
	"temperate2",
	"tropical",
	"tropical2",
	"antarctic",
	"artic"
}

local temperate_winter_sunrise = 0.33	--8:00
local temperate_winter_sunset = 0.67	--16:00

local temperate_summer_sunrise = 0.17	--4:00
local temperate_summer_sunset = 0.83	--20:00

local tropical_winter_sunrise = 0.29	--7:00
local tropical_winter_sunset = 0.71		--17:00

local tropical_summer_sunrise = 0.21	--5:00
local tropical_summer_sunset = 0.79		--19:00

--get settings
local cycles = {
	arctic		= settings:get_bool("season.arctic", true),
	temperate	= settings:get_bool("season.temperate", true),
	tropical	= settings:get_bool("season.tropical", true),
	equatorial	= settings:get_bool("season.equatorial", true),
	tropical2	= settings:get_bool("season.tropical2", true),
	temperate2	= settings:get_bool("season.temperate2", true),
	antarctic	= settings:get_bool("season.antarctic", true)
}

local yearlength = settings:get("season.length_of_year") or 360

--get storage
local storage = mt.get_mod_storage()

local yearday = storage:get_int("yearday")

--init other variables

--not really hardcoded
local hardcoded_areas = AreaStore()
if cycles.arctic then
	hardcoded_areas:insert_area(vector.new(-32000, -32000, 24000), vector.new(32000, 32000, 32000), "arctic", 1)
end
if cycles.antarctic then
	hardcoded_areas:insert_area(vector.new(-32000, -32000, -32000), vector.new(32000, 32000, -24000), "antarctic", 2)
end
if cycles.tropical2 then
	hardcoded_areas:insert_area(vector.new(-32000, -32000, -12000), vector.new(32000, 32000, -4000), "tropical2", 3)
end
if cycles.tropical then
	hardcoded_areas:insert_area(vector.new(-32000, -32000, 4000), vector.new(32000, 32000, 12000), "tropical", 4)
end
if cycles.temperate2 then
	hardcoded_areas:insert_area(vector.new(-32000, -32000, -32000), vector.new(32000, 32000, -4000), "temperate2", 5)
end
if cycles.temperate then
	hardcoded_areas:insert_area(vector.new(-32000, -32000, 4000), vector.new(32000, 32000, 32000), "temperate", 6)
end
if cycles.equatorial then
	hardcoded_areas:insert_area(vector.new(-32000, -32000, -32000), vector.new(32000, 32000, 32000), "equatorial", 7)
end

local solstice = 0
local equinox = math.round(yearlength*0.25)
local solstice2 = math.round(yearlength*0.5)
local equinox2 = math.round(yearlength*0.75)

local lasttime = 0

local current_season = table.copy(cycles)
local current_daylength = table.copy(cycles)

for s, _ in pairs(current_daylength) do
	current_daylength[s] = {}
end

current_daylength.equatorial.sunrise = 0.25
current_daylength.equatorial.sunset = 0.75

--linear interpolation
local function interp(min, max, value)
	local delta = max - min
	return min + delta * value
end

--reverse linear interpolation
local function interp2(min, max, value)
	local delta = max - min
	value = value - min
	return value/delta
end

--smothing
local function smoth(val)
	return math.sin(2*val*math.pi)^2
end

--backward compatibility
if not mt.time_to_day_night_ratio then
	function mt.time_to_day_night_ratio(time)
		local nlight = 0.2
		if time < 0.2 or 0.8 < time then
			return nlight
		elseif time < 0.3 then
			return interp(nlight, 1, interp2(0.2, 0.3, time))
		elseif time < 0.7 then
			return 1
		else
			return interp(1, nlight, interp2(0.7, 0.8, time))
		end
		return nlight
	end
end

--simple checkers
local function is_polar(season) return season == "arctic" or season == "antarctic" end
local function is_temperate(season) return season == "temperate" or season == "temperate2" end
local function is_tropical(season) return season == "tropical" or season == "tropical2" end

--base function of the mod
function season.get_season(arg)
	local a = hardcoded_areas:get_areas_for_pos(arg:get_pos(), false, true)
	--print(dump2(next(a)))
	return a[next(a)].data
end

--refresh current season table in function of the day of the year
local function refresh_current_season()
	--polar day/night + tropical season
	if yearday < equinox or equinox2 < yearday then
		current_season.arctic = polar_seasons[1]
		current_daylength.arctic.light = mt.time_to_day_night_ratio(0)
		current_daylength.arctic.sun = false
		current_season.tropical = tropical_seasons[1]
		current_season.tropical2 = tropical_seasons[2]
		current_season.antarctic = polar_seasons[2]
		current_daylength.antarctic.light = mt.time_to_day_night_ratio(0.5)
		current_daylength.antarctic.sun = true
	else
		current_season.arctic = polar_seasons[2]
		current_daylength.arctic.light = mt.time_to_day_night_ratio(0.5)
		current_daylength.arctic.sun = true
		current_season.tropical = tropical_seasons[2]
		current_season.tropical2 = tropical_seasons[1]
		current_season.antarctic = polar_seasons[1]
		current_daylength.antarctic.light = mt.time_to_day_night_ratio(0)
		current_daylength.antarctic.sun = false
	end
	--temperate season
	if yearday < equinox then
		current_season.temperate = temperate_seasons[1]
		current_season.temperate2 = temperate_seasons[3]
	elseif yearday < solstice2 then
		current_season.temperate = temperate_seasons[2]
		current_season.temperate2 = temperate_seasons[4]
	elseif yearday < equinox2 then
		current_season.temperate = temperate_seasons[3]
		current_season.temperate2 = temperate_seasons[1]
	else
		current_season.temperate = temperate_seasons[4]
		current_season.temperate2 = temperate_seasons[2]
	end

end

local function refresh_daylength()
	local factor = 0
	if yearday < equinox then
		factor = interp2(solstice, equinox, yearday)
		current_daylength.temperate.sunrise = interp(temperate_winter_sunrise, 0.25, factor)
		current_daylength.temperate.sunset = interp(temperate_winter_sunset, 0.75, factor)
		current_daylength.tropical.sunrise = interp(tropical_winter_sunrise, 0.25, factor)
		current_daylength.tropical.sunset = interp(tropical_winter_sunset, 0.75, factor)
		current_daylength.tropical2.sunrise = interp(tropical_summer_sunrise, 0.25, factor)
		current_daylength.tropical2.sunset = interp(tropical_summer_sunset, 0.75, factor)
		current_daylength.temperate2.sunrise = interp(temperate_summer_sunrise, 0.25, factor)
		current_daylength.temperate2.sunset = interp(temperate_summer_sunset, 0.75, factor)
		return
	elseif yearday < solstice2 then
		factor = interp2(equinox, solstice2, yearday)
		current_daylength.temperate.sunrise = interp(0.25, temperate_summer_sunrise, factor)
		current_daylength.temperate.sunset = interp(0.75, temperate_summer_sunset, factor)
		current_daylength.tropical.sunrise = interp(0.25, tropical_summer_sunrise, factor)
		current_daylength.tropical.sunset = interp(0.75, tropical_summer_sunset, factor)
		current_daylength.tropical2.sunrise = interp(0.25, tropical_winter_sunrise, factor)
		current_daylength.tropical2.sunset = interp(0.75, tropical_winter_sunset, factor)
		current_daylength.temperate2.sunrise = interp(0.25, temperate_winter_sunrise, factor)
		current_daylength.temperate2.sunset = interp(0.75, temperate_winter_sunset, factor)
		return
	elseif yearday < equinox2 then
		factor = interp2(solstice2, equinox2, yearday)
		current_daylength.temperate.sunrise = interp(temperate_summer_sunrise, 0.25, factor)
		current_daylength.temperate.sunset = interp(temperate_summer_sunset, 0.75, factor)
		current_daylength.tropical.sunrise = interp(tropical_summer_sunrise, 0.25, factor)
		current_daylength.tropical.sunset = interp(tropical_summer_sunset, 0.75, factor)
		current_daylength.tropical2.sunrise = interp(tropical_winter_sunrise, 0.25, factor)
		current_daylength.tropical2.sunset = interp(tropical_winter_sunset, 0.75, factor)
		current_daylength.temperate2.sunrise = interp(temperate_winter_sunrise, 0.25, factor)
		current_daylength.temperate2.sunset = interp(temperate_winter_sunset, 0.75, factor)
		return
	else
		factor = interp2(equinox2, yearlength, yearday)
		current_daylength.temperate.sunrise = interp(0.25, temperate_winter_sunrise, factor)
		current_daylength.temperate.sunset = interp(0.75, temperate_winter_sunset, factor)
		current_daylength.tropical.sunrise = interp(0.25, tropical_winter_sunrise, factor)
		current_daylength.tropical.sunset = interp(0.75, tropical_winter_sunset, factor)
		current_daylength.tropical2.sunrise = interp(0.25, tropical_summer_sunrise, factor)
		current_daylength.tropical2.sunset = interp(0.75, tropical_summer_sunset, factor)
		current_daylength.temperate2.sunrise = interp(0.25, temperate_summer_sunrise, factor)
		current_daylength.temperate2.sunset = interp(0.75, temperate_summer_sunset, factor)
	end
end

local function refresh_light(time)
	--equinox have a regular time
	if yearday == equinox or yearday == equinox2 then
		current_daylength.temperate.light = nil
		current_daylength.tropical.light = nil
		current_daylength.tropical2.light = nil
		current_daylength.temperate2.light = nil
		if yearday == equinox then
			current_daylength.arctic.light = mt.time_to_day_night_ratio(time/2)
			current_daylength.antarctic.light = mt.time_to_day_night_ratio(0.5+time/2)
		else
			current_daylength.arctic.light = mt.time_to_day_night_ratio(0.5+time/2)
			current_daylength.antarctic.light = mt.time_to_day_night_ratio(time/2)
		end
	else
		for _, s in pairs({"temperate", "temperate2", "tropical", "tropical2"}) do
			local dl = current_daylength[s]
			if time < dl.sunrise then
				local time = interp(0, 0.25, interp2(0, dl.sunrise, time))
			elseif time < dl.sunset then
				local time = interp(0.25, 0.75, interp2(dl.sunrise, dl.sunset, time))
			else
				local time = interp(0.75, 1, interp2(dl.sunset, 1, time))
			end
			current_daylength[s].light = mt.time_to_day_night_ratio(time)
		end
	end
	--current_daylength.equatorial.time = time
end

local function season_loop(t)
	local time = mt.get_timeofday()
	if time < lasttime then
		yearday = (yearday+1)%yearlength
		storage:set_int("yearday", yearday)
		refresh_current_season()
		refresh_daylength()
		print(dump2(current_season))
		print(dump2(current_daylength))
	end
	refresh_light(time)
	for _, player in pairs(mt.get_connected_players()) do
		local plr_season = season.get_season(player)
		local sky = player:get_sky(true)
		player:override_day_night_ratio(current_daylength[plr_season].light)
		if is_polar(plr_season) then
			local sun = player:get_sun()
			local stars = player:get_stars()
			sun.visible = current_daylength[plr_season].sun
			stars.visible = not current_daylength[plr_season].sun
			stars.day_opacity = current_daylength[plr_season].sun and 0 or 1
			player:set_sun(sun)
			player:set_stars(stars)
		end
	end
	lasttime = time
end

refresh_current_season()
refresh_daylength()

mt.register_globalstep(season_loop)
