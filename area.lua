--scrip to use season in area mode

--still need settings
local settings = minetest.settings

--still need utility functions
dofile(season.modpath.."/utils.lua")

--static area used as a fallback
local static_areas = AreaStore()

if settings:get_bool("season.arctic", true) then
	static_areas:insert_area(vector.new(-32000, -32000, 24000), vector.new(32000, 32000, 32000), "arctic", 1)
end
if settings:get_bool("season.antarctic", true) then
	static_areas:insert_area(vector.new(-32000, -32000, -32000), vector.new(32000, 32000, -24000), "antarctic", 2)
end
if settings:get_bool("season.tropical2", true) then
	static_areas:insert_area(vector.new(-32000, -32000, -12000), vector.new(32000, 32000, -4000), "tropical2", 3)
end
if settings:get_bool("season.tropical", true) then
	static_areas:insert_area(vector.new(-32000, -32000, 4000), vector.new(32000, 32000, 12000), "tropical", 4)
end
if settings:get_bool("season.temperate2", true) then
	static_areas:insert_area(vector.new(-32000, -32000, -32000), vector.new(32000, 32000, -4000), "temperate2", 5)
end
if settings:get_bool("season.temperate", true) then
	static_areas:insert_area(vector.new(-32000, -32000, 4000), vector.new(32000, 32000, 32000), "temperate", 6)
end
if settings:get_bool("season.equatorial", true) then
	static_areas:insert_area(vector.new(-32000, -32000, -32000), vector.new(32000, 32000, 32000), "equatorial", 7)
end

function season.get_season_area(...)
	local pos = universal_pos(...)
	local a = static_areas:get_areas_for_pos(pos, false, true)
	--print(dump2(next(a)))
	return a[next(a)].data
end
