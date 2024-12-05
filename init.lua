--season mod init file

--init constant
local mt = minetest

season = {}
season.modpath = minetest.get_modpath("season")

local settings = mt.settings

local polar_seasons = {"night", "day"}
local temperate_seasons = {"winter", "spring", "summer", "autumn"}
local tropical_seasons = {"wet", "dry"}

season.seasons = {
	night		= true,
	day			= true,
	winter		= true,
	spring		= true,
	summer		= true,
	autumn		= true,
	wet			= true,
	dry			= true,
	equatorial	= true
}

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

--Orbital Tilting
--local polar_orbital_tilt = 60

local temperate_winter_tilt = 25
local temperate_summer_tilt = 5

local tropical_winter_tilt = 15
local tropical_summer_tilt = -5

local equatorial_tilt = 10

--get settings

local yearlength = settings:get("season.length_of_year") or 360

local mode = settings:get("season.mode") or "area"

local cycles = {
	arctic		= settings:get_bool("season.arctic", true),
	temperate	= settings:get_bool("season.temperate", true),
	tropical	= settings:get_bool("season.tropical", true),
	equatorial	= settings:get_bool("season.equatorial", true),
	tropical2	= settings:get_bool("season.tropical2", true),
	temperate2	= settings:get_bool("season.temperate2", true),
	antarctic	= settings:get_bool("season.antarctic", true)
}

season.cycles = cycles

--get storage
local storage = mt.get_mod_storage()

local yearday = storage:get_int("yearday")

--load utility function
dofile(season.modpath.."/utils.lua")

--load areas system
dofile(season.modpath.."/area.lua")

--load mapgen system
dofile(season.modpath.."/mapgen.lua")

--load farming functions (require farming mode)
if minetest.get_modpath("farming") then
	print("Season: Farming functions available")
	dofile(season.modpath.."/farming.lua")
end

--init other variables

local solstice = 0
local equinox = math.round(yearlength*0.25)
local solstice2 = math.round(yearlength*0.5)
local equinox2 = math.round(yearlength*0.75)

local lasttime = 0

local current_season = table.copy(cycles)

current_season.equatorial = "equatorial"

local current_daylength = table.copy(cycles)

for s, _ in pairs(current_daylength) do
	current_daylength[s] = {
		sunrise = 0.25,
		sunset = 0.75,
		--sun = true,
		light = 0.5
	}
end

current_daylength.arctic.tilt = -60
current_daylength.antarctic.tilt = 60

--backward compatibility
if not mt.time_to_day_night_ratio then
	function mt.time_to_day_night_ratio(time)
		local nlight = 0.2
		if time < 0.2 or 0.8 < time then
			return nlight
		elseif time < 0.3 then
			return season.utils.interp(nlight, 1, season.utils.interp2(0.2, 0.3, time))
		elseif time < 0.7 then
			return 1
		else
			return season.utils.interp(1, nlight, season.utils.interp2(0.7, 0.8, time))
		end
		return nlight
	end
end

--privs definition
mt.register_privilege("season", {
	description = "Allow manipulation of seasons areas"
})

--base function of the mod
function season.get_cycle(...)
	if mode == "mapgen" then
		return season.get_cycle_mapgen(...)
	end
	return season.get_cycle_area(...)
end

--return the season in area mode
function season.get_season_area(...)
	return current_season[season.get_cycle_area(...)]
end

--return the season in mapgen mode
function season.get_season_mapgen(...)
	return current_season[season.get_cycle_mapgen(...)]
end

--actuall base function of the mod
function season.get_season(...)
	return current_season[season.get_cycle(...)]
end

--refresh current season table in function of the day of the year
local function refresh_current_season()
	--polar day/night + tropical season
	if yearday < equinox or equinox2 < yearday then
		current_season.arctic = polar_seasons[1]
		current_season.tropical = tropical_seasons[1]
		current_season.tropical2 = tropical_seasons[2]
		current_season.antarctic = polar_seasons[2]
	else
		current_season.arctic = polar_seasons[2]
		current_season.tropical = tropical_seasons[2]
		current_season.tropical2 = tropical_seasons[1]
		current_season.antarctic = polar_seasons[1]
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
	local factor2 = 0
	--polar-season
	if yearday < equinox and equinox2 < yearday then
		current_daylength.arctic.light = mt.time_to_day_night_ratio(0)
		current_daylength.arctic.sun = false
		current_daylength.antarctic.light = mt.time_to_day_night_ratio(0.5)
		current_daylength.antarctic.sun = true

	else
		current_daylength.arctic.light = mt.time_to_day_night_ratio(0.5)
		current_daylength.arctic.sun = true
		current_daylength.antarctic.light = mt.time_to_day_night_ratio(0)
		current_daylength.antarctic.sun = false

	end
	--non-polar season
	if yearday < equinox then
		factor = season.utils.interp2(solstice, equinox, yearday)
		current_daylength.arctic.light = mt.time_to_day_night_ratio(0)
		current_daylength.arctic.sun = false
		current_daylength.temperate.sunrise = season.utils.interp(temperate_winter_sunrise, 0.25, factor)
		current_daylength.temperate.sunset = season.utils.interp(temperate_winter_sunset, 0.75, factor)
		current_daylength.tropical.sunrise = season.utils.interp(tropical_winter_sunrise, 0.25, factor)
		current_daylength.tropical.sunset = season.utils.interp(tropical_winter_sunset, 0.75, factor)
		current_daylength.tropical2.sunrise = season.utils.interp(tropical_summer_sunrise, 0.25, factor)
		current_daylength.tropical2.sunset = season.utils.interp(tropical_summer_sunset, 0.75, factor)
		current_daylength.temperate2.sunrise = season.utils.interp(temperate_summer_sunrise, 0.25, factor)
		current_daylength.temperate2.sunset = season.utils.interp(temperate_summer_sunset, 0.75, factor)
		current_daylength.antarctic.light = mt.time_to_day_night_ratio(0.5)
		current_daylength.antarctic.sun = true

	elseif yearday < solstice2 then
		factor = season.utils.interp2(equinox, solstice2, yearday)
		current_daylength.temperate.sunrise = season.utils.interp(0.25, temperate_summer_sunrise, factor)
		current_daylength.temperate.sunset = season.utils.interp(0.75, temperate_summer_sunset, factor)
		current_daylength.tropical.sunrise = season.utils.interp(0.25, tropical_summer_sunrise, factor)
		current_daylength.tropical.sunset = season.utils.interp(0.75, tropical_summer_sunset, factor)
		current_daylength.tropical2.sunrise = season.utils.interp(0.25, tropical_winter_sunrise, factor)
		current_daylength.tropical2.sunset = season.utils.interp(0.75, tropical_winter_sunset, factor)
		current_daylength.temperate2.sunrise = season.utils.interp(0.25, temperate_winter_sunrise, factor)
		current_daylength.temperate2.sunset = season.utils.interp(0.75, temperate_winter_sunset, factor)

	elseif yearday < equinox2 then
		factor = season.utils.interp2(solstice2, equinox2, yearday)
		current_daylength.arctic.light = mt.time_to_day_night_ratio(0.5)
		current_daylength.arctic.sun = true
		current_daylength.temperate.sunrise = season.utils.interp(temperate_summer_sunrise, 0.25, factor)
		current_daylength.temperate.sunset = season.utils.interp(temperate_summer_sunset, 0.75, factor)
		current_daylength.tropical.sunrise = season.utils.interp(tropical_summer_sunrise, 0.25, factor)
		current_daylength.tropical.sunset = season.utils.interp(tropical_summer_sunset, 0.75, factor)
		current_daylength.tropical2.sunrise = season.utils.interp(tropical_winter_sunrise, 0.25, factor)
		current_daylength.tropical2.sunset = season.utils.interp(tropical_winter_sunset, 0.75, factor)
		current_daylength.temperate2.sunrise = season.utils.interp(temperate_winter_sunrise, 0.25, factor)
		current_daylength.temperate2.sunset = season.utils.interp(temperate_winter_sunset, 0.75, factor)
		current_daylength.antarctic.light = mt.time_to_day_night_ratio(0)
		current_daylength.antarctic.sun = false

	else
		factor = season.utils.interp2(equinox2, yearlength, yearday)
		current_daylength.temperate.sunrise = season.utils.interp(0.25, temperate_winter_sunrise, factor)
		current_daylength.temperate.sunset = season.utils.interp(0.75, temperate_winter_sunset, factor)
		current_daylength.tropical.sunrise = season.utils.interp(0.25, tropical_winter_sunrise, factor)
		current_daylength.tropical.sunset = season.utils.interp(0.75, tropical_winter_sunset, factor)
		current_daylength.tropical2.sunrise = season.utils.interp(0.25, tropical_summer_sunrise, factor)
		current_daylength.tropical2.sunset = season.utils.interp(0.75, tropical_summer_sunset, factor)
		current_daylength.temperate2.sunrise = season.utils.interp(0.25, temperate_summer_sunrise, factor)
		current_daylength.temperate2.sunset = season.utils.interp(0.75, temperate_summer_sunset, factor)

	end

	--Orbital Tilting
	if yearday < solstice2 then
		factor2 = season.utils.smooth(season.utils.interp2(solstice, solstice2, yearday))
		current_daylength.temperate.tilt = season.utils.interp(-temperate_winter_tilt, -temperate_summer_tilt, factor2)
		current_daylength.tropical.tilt = season.utils.interp(-tropical_winter_tilt, -tropical_summer_tilt, factor2)
		current_daylength.equatorial.tilt = season.utils.interp(-equatorial_tilt, equatorial_tilt, factor2)
		current_daylength.tropical2.tilt = season.utils.interp(tropical_summer_tilt, tropical_winter_tilt, factor2)
		current_daylength.temperate2.tilt = season.utils.interp(temperate_summer_tilt, temperate_winter_tilt, factor2)

	else
		factor2 = season.utils.smooth(season.utils.interp2(solstice2, yearlength, yearday))
		current_daylength.temperate.tilt = season.utils.interp(-temperate_summer_tilt, -temperate_winter_tilt, factor2)
		current_daylength.tropical.tilt = season.utils.interp(-tropical_summer_tilt, -tropical_winter_tilt, factor2)
		current_daylength.equatorial.tilt = season.utils.interp(equatorial_tilt, -equatorial_tilt, factor2)
		current_daylength.tropical2.tilt = season.utils.interp(tropical_winter_tilt, tropical_summer_tilt, factor2)
		current_daylength.temperate2.tilt = season.utils.interp(temperate_winter_tilt, temperate_summer_tilt, factor2)

	end

end

local function refresh_light(time)
	--sun rine and sunset on polar cycle
	if yearday == equinox or yearday == equinox2 then
		current_daylength.antarctic.sun = true
		if yearday == equinox then
			current_daylength.arctic.light = mt.time_to_day_night_ratio(time/2)
			current_daylength.antarctic.light = mt.time_to_day_night_ratio(0.5+time/2)

		else
			current_daylength.arctic.light = mt.time_to_day_night_ratio(0.5+time/2)
			current_daylength.antarctic.light = mt.time_to_day_night_ratio(time/2)

		end

	end
	--compute light for each cycle
	current_daylength.equatorial.light = mt.time_to_day_night_ratio(time)
	for _, s in pairs({"temperate", "temperate2", "tropical", "tropical2"}) do
		local dl = current_daylength[s]
		if time < dl.sunrise then
			local time = season.utils.interp(0, 0.25, season.utils.interp2(0, dl.sunrise, time))

		elseif time < dl.sunset then
			local time = season.utils.interp(0.25, 0.75, season.utils.interp2(dl.sunrise, dl.sunset, time))

		else
			local time = season.utils.interp(0.75, 1, season.utils.interp2(dl.sunset, 1, time))

		end
		current_daylength[s].light = mt.time_to_day_night_ratio(time)

	end

end

local function season_loop(t)
	local time = mt.get_timeofday()
	-- once a day
	if time < lasttime then
		yearday = (yearday+1)%yearlength
		storage:set_int("yearday", yearday)
		refresh_current_season()
		refresh_daylength()
		print(dump2(current_season))
		print(dump2(current_daylength))
	end
	-- everytime
	refresh_light(time)
	for _, player in pairs(mt.get_connected_players()) do
		local plr_cycle = season.get_cycle(player)
		local polar = season.is_polar(plr_cycle)
		local sky = player:get_sky(true)
		player:override_day_night_ratio(current_daylength[plr_cycle].light)
		local sun = player:get_sun()
		local stars = player:get_stars()
		sky.body_orbit_tilt = current_daylength[plr_cycle].tilt
		--sun and stars are alway visible outside polar region
		sun.visible = current_daylength[plr_cycle].sun or not polar
		stars.visible = not current_daylength[plr_cycle].sun or not polar
		stars.day_opacity = stars.visible and polar and 1 or 0
		player:set_sky(sky)
		player:set_sun(sun)
		player:set_stars(stars)
		--print(plr_cycle)
	end
	lasttime = time
end

--chat command definition

local cmd_yearday = {
	params = "[<yearday> | solstice | equinox | solstice2 | equinox2]",
	description = "allow to get or set year",
	privs = {settime = true},
	func = function(name, param)
		local n = tonumber(param)
		if #param < 1 then
			return true, "Day of the year is "..yearday
		else
			if n then
				yearday = n%yearlength
				return true, "Day of the year is now "..yearday
			elseif param == "solstice" then
				yearday = solstice
				return true, "Day of the year is now "..yearday
			elseif param == "equinox" then
				yearday = equinox
				return true, "Day of the year is now "..yearday
			elseif param == "solstice2" then
				yearday = solstice2
				return true, "Day of the year is now "..yearday
			elseif param == "equinox2" then
				yearday = equinox2
			end
			refresh_current_season()
			return true, "Day of the year is now "..yearday
		end
		return false
	end
}

refresh_current_season()
refresh_daylength()

mt.register_chatcommand("year-day", cmd_yearday)

mt.register_globalstep(season_loop)
