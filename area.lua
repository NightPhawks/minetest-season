--script to use season in area mode

--still need settings
local settings = minetest.settings

--and storage
local storage = minetest.get_mod_storage()

--store area defined by user
local defined_areas = AreaStore()

--static area used as a fallback
local static_areas = AreaStore()

local v1 = vector.new(-32000, -32000, 24000)
local v2 = vector.new(32000, 32000, 32000)
if season.cycles.arctic then
	static_areas:insert_area(v1, v2, "arctic", 1)
end
v1 = vector.new(-32000, -32000, -32000)
v2 = vector.new(32000, 32000, -24000)
if season.cycles.antarctic then
	static_areas:insert_area(v1, v2, "antarctic", 2)
end
v1 = vector.new(-32000, -32000, -12000)
v2 = vector.new(32000, 32000, -4000)
if season.cycles.tropical2 then
	static_areas:insert_area(v1, v2, "tropical2", 3)
end
v1 = vector.new(-32000, -32000, 4000)
v2 = vector.new(32000, 32000, 12000)
if season.cycles.tropical then
	static_areas:insert_area(v1, v2, "tropical", 4)
end
v1 = vector.new(-32000, -32000, -32000)
v2 = vector.new(32000, 32000, -4000)
if season.cycles.temperate2 then
	static_areas:insert_area(v1, v2, "temperate2", 5)
end
v1 = vector.new(-32000, -32000, 4000)
v2 = vector.new(32000, 32000, 32000)
if season.cycles.temperate then
	static_areas:insert_area(v1, v2, "temperate", 6)
end
v1 = vector.new(-32000, -32000, -32000)
if season.cycles.equatorial then
	static_areas:insert_area(v1, v2, "equatorial", 7)
end

function season.get_cycle_area(...)
	local pos = season.utils.universal_pos(...)
	if not pos then
		return nil
	end
	local at = defined_areas:get_areas_for_pos(pos, false, true)
	local id, a = next(at)
	if not id then
		at = static_areas:get_areas_for_pos(pos, false, true)
		local min = 8
		for i, a in pairs(at) do
			if i < min then
				min = i
			end
		end
		id = min
		a = at[id]
		--id, a = next(at)
	end
	--print(dump2(at))
	return a.data, id
end

--loading defined area
defined_areas:from_string(storage:get_string("season_area"))

local function save_areas()
	storage:set_string("season_area", defined_areas:to_string())
end

local cmd_areadef = {
params = "[new <cycle> <pos1> [<pos2>]] | [remove [id]]",
	description = "Get current cycle area or define a new one",
	privs = {season = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		local plrpos = player:get_pos()
		local params = param:split(" ")
		--no parameters
		if not next(params) then
			local s, id = season.get_cycle_area(plrpos)
			return true, "You are currently in a "..s.." area ["..id.."]"
		--defining new season
		elseif params[1] == "new" then
			--invalid cycles
			if not season.cycles[params[2]] then
				return false, "Specified cycle is invalid or disabled"
			end
			local id
			local pos1, pos2
			if params[4] then
				pos1, pos2 = minetest.string_to_area(params[3]..params[4], plrpos)
				if pos1 and pos2 then
					id = defined_areas:insert_area(pos1, pos2, params[2])
				end
			elseif params[3] then
				pos1 = minetest.string_to_pos(params[3])
				if pos1 then
					id = defined_areas:insert_area(pos1, plrpos, params[2])
				end
			end
			if id then
				save_areas()
				return true, "Season area ["..id.."] has beed sucsefully created"
			else
				return false, "Invalid position parameters, pos syntaxe is (X,Y,Z)"
			end
		elseif params[1] == "remove" then
			local id = tonumber(params[2]) or next(defined_areas:get_areas_for_pos(plrpos))
			if id and defined_areas:remove_area(id) then
				save_areas()
				return true, "Area succefully removed"
			else
				return false, "Failure, area ID is invalid or player not standing in defined area"
			end
		end
		return false
	end
}

minetest.register_chatcommand("season-area", cmd_areadef)
