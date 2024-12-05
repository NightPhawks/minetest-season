--farming functions

season.farming = {}

--cycles tables preset
season.farming.polar = {
	night		= 2,
	day			= 1,
	winter		= 3,
	spring		= 5,
	summer		= 6,
	autumn		= 4,
	wet			= 7,
	dry			= 8,
	equatorial	= 9
}

season.farming.temperate = {
	night		= 8,
	day			= 6,
	winter		= 4,
	spring		= 1,
	summer		= 2,
	autumn		= 3,
	wet			= 5,
	dry			= 7,
	equatorial	= 9
}

season.farming.tropical = {
	night		= 9,
	day			= 8,
	winter		= 7,
	spring		= 3,
	summer		= 4,
	autumn		= 6,
	wet			= 1,
	dry			= 2,
	equatorial	= 5
}

--equatorial is both a cycle and a season
season.farming.equatorial = {
	night		= 9,
	day			= 8,
	winter		= 7,
	spring		= 4,
	summer		= 5,
	autumn		= 6,
	wet			= 2,
	dry			= 3,
	equatorial	= 1
}

--season table preset
season.farming.night = {
	night		= 1,
	day			= 6,
	winter		= 2,
	spring		= 7,
	summer		= 8,
	autumn		= 3,
	wet			= 4,
	dry			= 9,
	equatorial	= 5
}

season.farming.day = {
	night		= 6,
	day			= 1,
	winter		= 8,
	spring		= 2,
	summer		= 3,
	autumn		= 7,
	wet			= 9,
	dry			= 4,
	equatorial	= 5
}

season.farming.winter = {
	night		= 3,
	day			= 8,
	winter		= 1,
	spring		= 6,
	summer		= 7,
	autumn		= 2,
	wet			= 4,
	dry			= 9,
	equatorial	= 5
}

season.farming.spring = {
	night		= 9,
	day			= 4,
	winter		= 7,
	spring		= 1,
	summer		= 2,
	autumn		= 6,
	wet			= 8,
	dry			= 3,
	equatorial	= 5
}

season.farming.summer = {
	night		= 9,
	day			= 4,
	winter		= 7,
	spring		= 2,
	summer		= 1,
	autumn		= 6,
	wet			= 8,
	dry			= 3,
	equatorial	= 5
}

season.farming.autumn = {
	night		= 3,
	day			= 8,
	winter		= 2,
	spring		= 6,
	summer		= 7,
	autumn		= 1,
	wet			= 4,
	dry			= 9,
	equatorial	= 5
}

season.farming.wet = {
	night		= 5,
	day			= 9,
	winter		= 3,
	spring		= 7,
	summer		= 8,
	autumn		= 2,
	wet			= 1,
	dry			= 6,
	equatorial	= 4
}

season.farming.dry = {
	night		= 9,
	day			= 5,
	winter		= 8,
	spring		= 2,
	summer		= 3,
	autumn		= 7,
	wet			= 6,
	dry			= 1,
	equatorial	= 4
}

function season.farming.can_grow_generator(season_table, wetsoil)
	--sanitize table
	for s, c in pairs(season_table) do
		season_table.s = tonumber(c)

	end
	local function can_grow(pos)
		s = season.get_season(pos)
		if not s and math.random(season_table.s) ~= 1 then
			return false

		end
		if wetsoil and not farming.can_grow(pos) then
			return false

		end
		return true

	end
	return can_grow

end

season.farming.polar_grow = season.farming.can_grow_generator(season.farming.polar, true)
season.farming.temperate_grow = season.farming.can_grow_generator(season.farming.temperate, true)
season.farming.tropical_grow = season.farming.can_grow_generator(season.farming.tropical, true)
season.farming.equatorial_grow = season.farming.can_grow_generator(season.farming.equatorial, true)

season.farming.night_grow = season.farming.can_grow_generator(season.farming.night, true)
season.farming.day_grow = season.farming.can_grow_generator(season.farming.day, true)
season.farming.winter_grow = season.farming.can_grow_generator(season.farming.winter, true)
season.farming.spring_grow = season.farming.can_grow_generator(season.farming.spring, true)
season.farming.summer_grow = season.farming.can_grow_generator(season.farming.summer, true)
season.farming.autumn_grow = season.farming.can_grow_generator(season.farming.autumn, true)
season.farming.wet_grow = season.farming.can_grow_generator(season.farming.wet, true)
season.farming.dry_grow = season.farming.can_grow_generator(season.farming.dry, true)
