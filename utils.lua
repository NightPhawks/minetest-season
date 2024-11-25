--utility functions

--linear interpolation
function interp(min, max, value)
	local delta = max - min
	return min + delta * value
end

--reverse linear interpolation
function interp2(min, max, value)
	local delta = max - min
	value = value - min
	return value/delta
end

--smothing
function smoth(val)
	return math.sin(2*val*math.pi)^2
end

--simple checkers
function is_polar(season) return season == "arctic" or season == "antarctic" end
function is_temperate(season) return season == "temperate" or season == "temperate2" end
function is_tropical(season) return season == "tropical" or season == "tropical2" end

--universal position getter, get postion from object/vector/ or simply 3 or 2 variables parameters
function universal_pos(x, y, z)
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
			return v
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
