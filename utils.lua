--utility functions

season.utils = {}

--linear interpolation
--return min if value = 0 and max if value = 1
function season.utils.interp(min, max, value)
	local delta = max - min
	return min + delta * value
end

--reverse linear interpolation
--return 0 if value is on min and 1 if value is on max
function season.utils.interp2(min, max, value)
	local delta = max - min
	value = value - min
	return value/delta
end

--smothing
function season.utils.smooth(val)
	return math.sin(2*val*math.pi)^2
end

--todo
function season.utils.shift(source, target, intensity)
	return taget
end

--simple checkers
function season.is_polar(season) return season == "arctic" or season == "antarctic" end
function season.is_temperate(season) return season == "temperate" or season == "temperate2" end
function season.is_tropical(season) return season == "tropical" or season == "tropical2" end

--universal position getter, get postion from object/vector/ or simply 3 or 2 variables parameters
function season.utils.universal_pos(x, y, z)
	local type_x = type(x)
	--print(dump2(x))
	--arguments are numbers
	if type_x == "number" and type(y) == "number" then
		--3 numbers argument
		if type(z) == "number" then
			return vector.new(x, y, z)
		--2 numbers argument (Y get zero)
		else
			return vector.new(x, 0, y)
		end
	--first argument is a table
	elseif type_x == "table" then
		--argument is already a vector
		if vector.check(x) then
			return x
		--argument is 'fake' vector
		elseif x.x and x.y and x.z then
			return vector.new(x)
		end
	--argument is an object (apparently object aren't table but userdata)
	elseif x.is_valid then
		return x:get_pos()
	end
	return nil
end
