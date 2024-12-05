# Season mod for Luanti/Minetest

Luanti mod that keep track of seasons and other phenomenon linked to a year cycle

## Installation

This mod can be installed like
[any other Minetest mod](https://wiki.minetest.net/Installing_Mods).

## Features

Currently the mod is a heavy WIP, expect malfunction. The mod contain 7 cycles
(also know as climates) respectively Polar, Temperate and Tropical for both side of the planet
plus Equatorial. There are currently 2 mode for defining cycle, area and mapgenmode.
Currently season only affect player's length of the day, including polar day and night and orbital
tilt of sun and moon.

### Area mode

Area mode allow to define cycles by areas using the chat command `/season-area`.
There are also statically defined area used as a fallback. In case of deactivated cycle,
temperates cycles will overlap their side of "the hemisphere", if temperates cycles are deactivated
equatorial cycle will replace the empty space, if equatorial cycle is deactivated... game crash :P

Static areas are dispatched as the following (Z axis) (Replacement area):
- Arctic			(24 km - 32 km North)		(None)
- Boreal Temperate	(12 km - 24 km North)		(4km - 32 km North)
- Boreal Tropical	(4 km - 12 km North)		(None)
- Equatorial 		(4 km South - 4 km North)	(The entire map)
- Austral Tropical	(4 km - 12 km South)		(None)
- Austral Temperate	(12 km - 24 km South)		(4km - 32 km South)
- Antarctic			(24 km - 32 km South)		(None)

### Mapgen mode

Mapgen mode use the map generator heat and humidity map used to define biome.
This guarantee that cycles are mostly aligned with their biome at the cost of being as
variable as them.

### Chat Commands

`/year-day [<yearday> | solstice | equinox | solstice2 | equinox2]`

Allow to get or set the day of the year, require the `settime` privilege.

`/season-area [new <cycle> <pos1> [<pos2>]] | [remove [id]]`

Get current cycle area or define a new one, require the `season` privilege.

### Application Programming Interface

Functions:

`season.get_season(...)`

`season.get_cycle(...)`

`season.get_season_area(...)`

`season.get_season_mapgen(...)`

`season.get_cycle_area(...)`

`season.get_cycle_mapgen(...)`

with `...` any `Object | Vector | {x, y, z} | x, z | x, y, z` arguments and return the
current season at the position

#### Farming API

Season mod feature a function usable with the `can_grow` field of the farming mod plant
definitions allowing to teak plant growth in function of season, it come with pre-defined
functions and tables.

`season.farming.can_grow_generator(season_table, wetsoil)`

`season_table` is a table containing season as key and chance as value e.g.
`{winter = 5}` where the probability to grow in winter is 1/5. Missing season will cause
the crops to not growth in that season.

`wetsoil` is a boolean, if `true` it check is the crops is on a wet soil like the default
farmin mod.

the function return a function that can be used in the `can_grow` field of the farming
plant definition

Here are the pre-defined functions output by `season.farming.can_grow_generator(...)`:

```
season.farming.polar_grow(pos)
season.farming.temperate_grow(pos)
season.farming.tropical_grow(pos)
season.farming.equatorial_grow(pos)
season.farming.night_grow(pos)
season.farming.day_grow(pos)
season.farming.winter_grow(pos)
season.farming.spring_grow(pos)
season.farming.summer_grow(pos)
season.farming.autumn_grow(pos)
season.farming.wet_grow(pos)
season.farming.dry_grow(pos)
```

theses functions are only available if the farming mod is present

### Upcoming Features

- API allowing to communicate with other Minetest mod and much more functionality
- Block mode where cycles are defined by biome topsoil
- Override default farming to a more challenging level
- Moonphase and tides

## Settings

Settings can be set manually by editing the `minetest.conf` file in base directory.

Mode is the way season are defined, there are currently 2 modes available: Area (default) and Mapgen

`season.mode = area`
`season.mode = mapgen`

Length of a year in in-game day, by default it is 360 almost as much as a real year, with
default time speed a cycle last 180 RL-hour so about a bit more than a RL-week. The
parameter is limited to a minimum of 16 in-game day.

`season.length_of_year = 360`

All cycles are toggelable, however it is highly unrecommended to disable Equatorial cycle as it is
used as a fallback cycle with no season in it.

Check extra information in the `settingtypes.txt` file

## Troubleshooting

The game was designed for Minetest 5.9.0 and is still a heavy WIP, do not hesitate to report bugs!
