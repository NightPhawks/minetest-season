--utility functions

season.utils = {}

function math.clamp(min, value, max)
	return math.min(math.max(value, min), max)
end

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

--smothing (--use precalculation with sin^2 function)
function season.utils.smooth(val)
	local sin2 = {
		[0] = 0.0, [1] = 0.0002, [2] = 0.0007, [3] = 0.0015, [4] = 0.0027, [5] = 0.0043,
		[6] = 0.0062, [7] = 0.0084, [8] = 0.0109, [9] = 0.0138, [10] = 0.017, [11] = 0.0206,
		[12] = 0.0245, [13] = 0.0287, [14] = 0.0332, [15] = 0.0381, [16] = 0.0432, [17] = 0.0487,
		[18] = 0.0545, [19] = 0.0606, [20] = 0.067, [21] = 0.0737, [22] = 0.0807, [23] = 0.0879,
		[24] = 0.0955, [25] = 0.1033, [26] = 0.1114, [27] = 0.1198, [28] = 0.1284, [29] = 0.1373,
		[30] = 0.1464, [31] = 0.1558, [32] = 0.1654, [33] = 0.1753, [34] = 0.1853, [35] = 0.1956,
		[36] = 0.2061, [37] = 0.2168, [38] = 0.2277, [39] = 0.2388, [40] = 0.25, [41] = 0.2614,
		[42] = 0.273, [43] = 0.2847, [44] = 0.2966, [45] = 0.3087, [46] = 0.3208, [47] = 0.3331,
		[48] = 0.3455, [49] = 0.358, [50] = 0.3706, [51] = 0.3833, [52] = 0.396, [53] = 0.4089,
		[54] = 0.4218, [55] = 0.4347, [56] = 0.4477, [57] = 0.4608, [58] = 0.4738, [59] = 0.4869,
		[60] = 0.5, [61] = 0.5131, [62] = 0.5262, [63] = 0.5392, [64] = 0.5523, [65] = 0.5653,
		[66] = 0.5782, [67] = 0.5911, [68] = 0.604, [69] = 0.6167, [70] = 0.6294, [71] = 0.642,
		[72] = 0.6545, [73] = 0.6669, [74] = 0.6792, [75] = 0.6913, [76] = 0.7034, [77] = 0.7153,
		[78] = 0.727, [79] = 0.7386, [80] = 0.75, [81] = 0.7612, [82] = 0.7723, [83] = 0.7832,
		[84] = 0.7939, [85] = 0.8044, [86] = 0.8147, [87] = 0.8247, [88] = 0.8346, [89] = 0.8442,
		[90] = 0.8536, [91] = 0.8627, [92] = 0.8716, [93] = 0.8802, [94] = 0.8886, [95] = 0.8967,
		[96] = 0.9045, [97] = 0.9121, [98] = 0.9193, [99] = 0.9263, [100] = 0.933, [101] = 0.9394,
		[102] = 0.9455, [103] = 0.9513, [104] = 0.9568, [105] = 0.9619, [106] = 0.9668,
		[107] = 0.9713, [108] = 0.9755, [109] = 0.9794, [110] = 0.983, [111] = 0.9862,
		[112] = 0.9891, [113] = 0.9916, [114] = 0.9938, [115] = 0.9957, [116] = 0.9973,
		[117] = 0.9985, [118] = 0.9993, [119] = 0.9998, [120] = 1.0
	}
	if 0 <= val and val <= 1 then
		return sin2[math.round((val)*120)]

	end
	return val
end

--fully interpolate value from source to target with optional smoothing
function season.utils.interpolate(source1, source2, value, target1, target2, smooth)
	local v = season.utils.interp2(source1, source2, value)
	v = smooth and season.utils.smooth(v) or v
	return season.utils.interp(target1, target2, v)

end

--todo
function season.utils.shift(source, target, intensity)
	local gap = math.abs(source) + math.abs(target)
	local variation = intensity * gap
	if math.abs(source - target) < variation then
		return target

	end
	local sign = source < target and 1 or -1
	return sign * variation + source
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
