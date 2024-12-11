--season mod init file

--init constant
local mt = minetest

local S = mt.get_translator("season")

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

--get settings

season.yearlength = settings:get("season.length_of_year") or 360

season.solstice = 0
season.equinox = math.round(season.yearlength*0.25)
season.solstice2 = math.round(season.yearlength*0.5)
season.equinox2 = math.round(season.yearlength*0.75)

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

season.yearday = storage:get_int("yearday")

--load utility function
dofile(season.modpath.."/utils.lua")

--init other variables

local lasttime = 0

local current_season = table.copy(cycles)

current_season.equatorial = "equatorial"

--privs definition
mt.register_privilege("season", {
	description = S("Allow manipulation of seasons areas")
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
	if season.yearday < season.equinox or season.equinox2 < season.yearday then
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
	if season.yearday < season.equinox then
		current_season.temperate = temperate_seasons[1]
		current_season.temperate2 = temperate_seasons[3]
	elseif season.yearday < season.solstice2 then
		current_season.temperate = temperate_seasons[2]
		current_season.temperate2 = temperate_seasons[4]
	elseif season.yearday < season.equinox2 then
		current_season.temperate = temperate_seasons[3]
		current_season.temperate2 = temperate_seasons[1]
	else
		current_season.temperate = temperate_seasons[4]
		current_season.temperate2 = temperate_seasons[2]
	end

end

refresh_current_season()

local function season_loop(t)
	local time = mt.get_timeofday()
	-- once a day
	if time < lasttime then
		season.yearday = (season.yearday+1)%season.yearlength
		storage:set_int("yearday", season.yearday)
		refresh_current_season()
		print(dump2(current_season))

	end
	-- everytime
	lasttime = time

end

--chat command definition

local cmd_yearday = {
	params = "[<yearday> | season.solstice | season.equinox | season.solstice2 | season.equinox2]",
	description = S("Allow to get or set the day of the year"),
	privs = {settime = true},
	func = function(name, param)
		local n = tonumber(param)
		if #param < 1 then
			return true, S("Day of the year is @1", season.yearday)
		else
			if n then
				season.yearday = n%season.yearlength
			elseif param == "solstice" then
				season.yearday = season.solstice
			elseif param == "equinox" then
				season.yearday = season.equinox
			elseif param == "solstice2" then
				season.yearday = season.solstice2
			elseif param == "equinox2" then
				season.yearday = season.equinox2
			end
			refresh_current_season()
			if season.refresh_daylength then
				season.refresh_daylength()

			end
			return true, S("Day of the year is now @1", season.yearday)
		end
		return false
	end
}

mt.register_chatcommand("year-day", cmd_yearday)

mt.register_globalstep(season_loop)

--load daylength system if one feature is activated
if settings:get_bool("season.daylength", true) or
	settings:get_bool("season.orbital_tilting", true) then
	dofile(season.modpath.."/daylength.lua")
	print("Season: Daylength module loaded")
end

--load areas system
dofile(season.modpath.."/area.lua")

--load mapgen system
dofile(season.modpath.."/mapgen.lua")

--load farming functions (require farming mode)
if minetest.get_modpath("farming") then
	print("Season: Farming functions available")
	dofile(season.modpath.."/farming.lua")
end
