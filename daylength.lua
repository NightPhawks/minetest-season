--file designed for daylength, light calculation and orbital tilting

local setting = minetest.settings

--day base lighting
local dlight = setting:get("season.dlight") or 1

--night base lighting
local nlight = setting:get("season.nlight") or 0.175

--half of the duration of sunrise/sunset
local risetime = setting:get("season.risetime") or 0.025

--8:00
local temperate_winter_sunrise = setting:get("season.temperate_winter_sunrise") or 0.33
--16:00
local temperate_winter_sunset = setting:get("season.temperate_winter_sunset") or 0.67

--4:00
local temperate_summer_sunrise = setting:get("season.temperate_summer_sunrise") or 0.17
--20:00
local temperate_summer_sunset = setting:get("season.temperate_summer_sunset") or 0.83

--7:00
local tropical_winter_sunrise = setting:get("season.tropical_winter_sunrise") or 0.29
--17:00
local tropical_winter_sunset = setting:get("season.temperate_winter_sunset") or 0.71

--5:00
local tropical_summer_sunrise = setting:get("season.temperate_summer_sunrise") or 0.21
--19:00
local tropical_summer_sunset = setting:get("season.temperate_summer_sunset") or 0.79

--Orbital Tilting
local polar_orbital_tilt = setting:get("season.polar_orbital_tilt") or 60

local temperate_winter_tilt = setting:get("season.temperate_winter_tilt") or 25
local temperate_summer_tilt = setting:get("season.temperate_summer_tilt") or 5

local tropical_winter_tilt = setting:get("season.tropical_winter_tilt") or 15
local tropical_summer_tilt = setting:get("season.tropical_summer_tilt") or -5

local equatorial_tilt = setting:get("season.equatorial_tilt") or 10

--this table contain sunset, sunrise, current light and orbital tilt of every cycle
--as well of presence of sun/(stars) for polar cycles
season.daylength = table.copy(season.cycles)

for s, _ in pairs(season.daylength) do
	season.daylength[s] = {
		sunrise = 0.25,
		sunset = 0.75,
		--sun = true,
		light = 0.5
	}
end

season.daylength.arctic.tilt = -polar_orbital_tilt
season.daylength.antarctic.tilt = polar_orbital_tilt

--backward compatibility
--[[ core.time_to_day_night_ratio is more used in light calculation so this placeholder is void
if not minetest.time_to_day_night_ratio then
	function minetest.time_to_day_night_ratio(time)
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
]]

--function called once a day to refresh sunrise, sunset, orbital tilting, and light of
--polar cycles
function season.refresh_daylength()
	--factor used to interpolate sunrise and sunset between equinox/solstice
	local factor = 0
	--factor used to interpolate orbital tilting between solstices
	local factor2 = 0
	--polar-season
	--boreal winter/autumn
	if season.yearday < season.equinox and season.equinox2 < season.yearday then
		season.daylength.arctic.light = nlight
		season.daylength.arctic.sun = false
		season.daylength.antarctic.light = dlight
		season.daylength.antarctic.sun = true

	--boreal summer/spring
	else
		season.daylength.arctic.light = dlight
		season.daylength.arctic.sun = true
		season.daylength.antarctic.light = nlight
		season.daylength.antarctic.sun = false

	end
	--non-polar season
	--boreal winter
	if season.yearday < season.equinox then
		factor = season.utils.smooth(2*season.utils.interp2(season.solstice, season.solstice2, season.yearday))
		season.daylength.temperate.sunrise = season.utils.interp(temperate_winter_sunrise, 0.25, factor)
		season.daylength.temperate.sunset = season.utils.interp(temperate_winter_sunset, 0.75, factor)
		season.daylength.tropical.sunrise = season.utils.interp(tropical_winter_sunrise, 0.25, factor)
		season.daylength.tropical.sunset = season.utils.interp(tropical_winter_sunset, 0.75, factor)
		season.daylength.tropical2.sunrise = season.utils.interp(tropical_summer_sunrise, 0.25, factor)
		season.daylength.tropical2.sunset = season.utils.interp(tropical_summer_sunset, 0.75, factor)
		season.daylength.temperate2.sunrise = season.utils.interp(temperate_summer_sunrise, 0.25, factor)
		season.daylength.temperate2.sunset = season.utils.interp(temperate_summer_sunset, 0.75, factor)

	--boreal spring
	elseif season.yearday < season.solstice2 then
		factor = season.utils.smooth(2*season.utils.interp2(season.solstice, season.solstice2, season.yearday)-1)
		season.daylength.temperate.sunrise = season.utils.interp(0.25, temperate_summer_sunrise, factor)
		season.daylength.temperate.sunset = season.utils.interp(0.75, temperate_summer_sunset, factor)
		season.daylength.tropical.sunrise = season.utils.interp(0.25, tropical_summer_sunrise, factor)
		season.daylength.tropical.sunset = season.utils.interp(0.75, tropical_summer_sunset, factor)
		season.daylength.tropical2.sunrise = season.utils.interp(0.25, tropical_winter_sunrise, factor)
		season.daylength.tropical2.sunset = season.utils.interp(0.75, tropical_winter_sunset, factor)
		season.daylength.temperate2.sunrise = season.utils.interp(0.25, temperate_winter_sunrise, factor)
		season.daylength.temperate2.sunset = season.utils.interp(0.75, temperate_winter_sunset, factor)

	--boreal summer
	elseif season.yearday < season.equinox2 then
		factor = season.utils.smooth(2*season.utils.interp2(season.solstice2, season.yearlength, season.yearday)-1)
		season.daylength.temperate.sunrise = season.utils.interp(temperate_summer_sunrise, 0.25, factor)
		season.daylength.temperate.sunset = season.utils.interp(temperate_summer_sunset, 0.75, factor)
		season.daylength.tropical.sunrise = season.utils.interp(tropical_summer_sunrise, 0.25, factor)
		season.daylength.tropical.sunset = season.utils.interp(tropical_summer_sunset, 0.75, factor)
		season.daylength.tropical2.sunrise = season.utils.interp(tropical_winter_sunrise, 0.25, factor)
		season.daylength.tropical2.sunset = season.utils.interp(tropical_winter_sunset, 0.75, factor)
		season.daylength.temperate2.sunrise = season.utils.interp(temperate_winter_sunrise, 0.25, factor)
		season.daylength.temperate2.sunset = season.utils.interp(temperate_winter_sunset, 0.75, factor)

	--boreal autumn
	else
		factor = season.utils.smooth(2*season.utils.interp2(season.solstice2, season.yearlength, season.yearday))
		season.daylength.temperate.sunrise = season.utils.interp(0.25, temperate_winter_sunrise, factor)
		season.daylength.temperate.sunset = season.utils.interp(0.75, temperate_winter_sunset, factor)
		season.daylength.tropical.sunrise = season.utils.interp(0.25, tropical_winter_sunrise, factor)
		season.daylength.tropical.sunset = season.utils.interp(0.75, tropical_winter_sunset, factor)
		season.daylength.tropical2.sunrise = season.utils.interp(0.25, tropical_summer_sunrise, factor)
		season.daylength.tropical2.sunset = season.utils.interp(0.75, tropical_summer_sunset, factor)
		season.daylength.temperate2.sunrise = season.utils.interp(0.25, temperate_summer_sunrise, factor)
		season.daylength.temperate2.sunset = season.utils.interp(0.75, temperate_summer_sunset, factor)

	end

	--Orbital Tilting
	--boreal winter/spring
	if season.yearday < season.solstice2 then
		factor2 = season.utils.smooth(season.utils.interp2(season.solstice, season.solstice2, season.yearday))
		season.daylength.temperate.tilt = season.utils.interp(-temperate_winter_tilt, -temperate_summer_tilt, factor2)
		season.daylength.tropical.tilt = season.utils.interp(-tropical_winter_tilt, -tropical_summer_tilt, factor2)
		season.daylength.equatorial.tilt = season.utils.interp(-equatorial_tilt, equatorial_tilt, factor2)
		season.daylength.tropical2.tilt = season.utils.interp(tropical_summer_tilt, tropical_winter_tilt, factor2)
		season.daylength.temperate2.tilt = season.utils.interp(temperate_summer_tilt, temperate_winter_tilt, factor2)

	--boreal summer/autumn
	else
		factor2 = season.utils.smooth(season.utils.interp2(season.solstice2, season.yearlength, season.yearday))
		season.daylength.temperate.tilt = season.utils.interp(-temperate_summer_tilt, -temperate_winter_tilt, factor2)
		season.daylength.tropical.tilt = season.utils.interp(-tropical_summer_tilt, -tropical_winter_tilt, factor2)
		season.daylength.equatorial.tilt = season.utils.interp(equatorial_tilt, -equatorial_tilt, factor2)
		season.daylength.tropical2.tilt = season.utils.interp(tropical_winter_tilt, tropical_summer_tilt, factor2)
		season.daylength.temperate2.tilt = season.utils.interp(temperate_winter_tilt, temperate_summer_tilt, factor2)

	end

end
season.refresh_daylength()

--function called every global step to refresh natural light
local function refresh_light(time)
	--sun rise and sunset on polar cycle during season.equinox
	if season.yearday == season.equinox or season.yearday == season.equinox2 then
		season.daylength.antarctic.sun = true
		--spring equinox
		if season.yearday == season.equinox then
			season.daylength.arctic.light = math.clamp(nlight, time, dlight)
			season.daylength.antarctic.light = math.clamp(nlight, 1-time, dlight)

		--autumn equinox
		else
			season.daylength.arctic.light = math.clamp(nlight, 1-time, dlight)
			season.daylength.antarctic.light = math.clamp(nlight, time, dlight)

		end

	end
	--compute light for each non-polar cycle
	for _, s in pairs({"temperate", "temperate2", "tropical", "tropical2", "equatorial"}) do
		local sunrise_start = season.daylength[s].sunrise - risetime
		local sunrise_stop = season.daylength[s].sunrise + risetime
		local sunset_start = season.daylength[s].sunset - risetime
		local sunset_stop = season.daylength[s].sunset + risetime
		--night
		if time < sunrise_start or sunset_stop < time then
			season.daylength[s].light = nlight

		--sunrise
		elseif time < sunrise_stop then
			season.daylength[s].light = season.utils.interpolate(sunrise_start, sunrise_stop, time, nlight, dlight, true)

		--day
		elseif time < sunset_start then
			season.daylength[s].light = dlight

		--sunset
		else
			season.daylength[s].light = season.utils.interpolate(sunset_start, sunset_stop, time, dlight, nlight, true)

		end

	end

end

local lasttime = 0

local function daylength_loop(t)
	local time = minetest.get_timeofday()
	-- once a day
	if time < lasttime then
		season.refresh_daylength()
		print(dump2(season.daylength))

	end
	refresh_light(time)
	for _, player in pairs(minetest.get_connected_players()) do
		local plr_cycle = season.get_cycle(player)
		if setting:get_bool("season.daylength", true) then
			local polar = season.is_polar(plr_cycle)
			local sun = player:get_sun()
			local stars = player:get_stars()
			--sun and stars are alway visible outside polar region
			sun.visible = season.daylength[plr_cycle].sun or not polar
			stars.visible = not season.daylength[plr_cycle].sun or not polar
			stars.day_opacity = stars.visible and polar and 1 or 0
			player:override_day_night_ratio(season.daylength[plr_cycle].light)
			player:set_sun(sun)
			player:set_stars(stars)

		end
		if setting:get_bool("season.orbital_tilting", true) then
			local sky = player:get_sky(true)
			sky.body_orbit_tilt = season.daylength[plr_cycle].tilt
			player:set_sky(sky)

		end
		--print(plr_cycle)

	end
	lasttime = time

end

minetest.register_globalstep(daylength_loop)
