--mapgen mode system

dofile(season.modpath.."/utils.lua")

local mapgencycles = table.copy(season.cycles)

if mapgencycles.arctic then
	mapgencycles.arctic = {
		heat = 15,
		humidity = 85
	}
else
	mapgencycles.arctic = nil
end
--------------------------------
if mapgencycles.temperate then
	mapgencycles.temperate = {
		heat = 50,
		humidity = 100
	}
else
	mapgencycles.temperate = nil
end
---------------------------------
if mapgencycles.tropical then
	mapgencycles.tropical = {
		heat = 85,
		humidity = 85
	}
else
	mapgencycles.tropical = nil
end
----------------------------------
if mapgencycles.equatorial then
	mapgencycles.equatorial = {
		heat = 100,
		humidity = 50
	}
else
	mapgencycles.equatorial = nil
end
----------------------------------
if mapgencycles.tropical2 then
	mapgencycles.tropical2 = {
		heat = 85,
		humidity = 15
	}
else
	mapgencycles.tropical2 = nil
end
-----------------------------------
if mapgencycles.temperate2 then
	mapgencycles.temperate2 = {
		heat = 50,
		humidity = 0
	}
else
	mapgencycles.temperate2 = nil
end
---------------------------------
if mapgencycles.antarctic then
	mapgencycles.antarctic = {
		heat = 15,
		humidity = 15
	}
else
	mapgencycles.antarctic = nil
end

season.mapgencycles = mapgencycles

function season.get_cycle_mapgen(...)
	local pos = universal_pos(...)
	if not pos then
		return nil
	end
	local heat = minetest.get_heat(pos)
	local humidity = minetest.get_humidity(pos)
	if not heat or not humidity then
		return error("Season: Mapgen mode failed, please fallback to area mode")
	end
	local cycle = "equatorial"
	local dist = 200
	local d
	for c, h in pairs(mapgencycles) do
		d = math.hypot(h.heat - heat, h.humidity - humidity)
		if d < dist then
			cycle = c
			dist = d
		end
	end
	return cycle
end
