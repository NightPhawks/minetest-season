# Season mod for Luanti/Minetest

Luanti mod that keep track of seasons and other phenomenon linked to a year cycle

## Installation

This mod can be installed like
[any other Minetest mod](https://wiki.minetest.net/Installing_Mods).

## Features

Currently the mod is a heavy WIP, expect malfunction. The mod contain 7 cycles
(also know as climates) respectively Polar, Temperate and Tropical for both side of the planet
plus Equatorial. For now seasons are simply assigned to areas (Area mode) and season only affect
player's length of the day, including polar day and night.

Areas are dispatched as the following (Z axis):
- Arctic			(24 km - 32 km North)
- Boreal Temperate	(12 km - 24 km North)
- Boreal Tropical	(4 km - 12 km North)
- Equatorial 		(4 km South - 4 km North)
- Austral Tropical	(4 km - 12 km South)
- Austral Temperate	(12 km - 24 km South)
- Antarctic			(24 km - 32 km South)

### Application Programming Interface

For know there is only one shared function:

`season.get_season(...)`

with `...` any `Object | Vector | {x, y, z} | x, z | x, y, z` arguments and return the current season at the position

### Upcoming Features

- API allowing to communicate with other Minetest mod and much more functionality
- Mapgen mode where cycles are defined by mapgen heat and humidity noises
- Block mode where cycles are defined by biome topsoil

## Settings

Settings can be set manually by editing the `minetest.conf` file in base directory.

Length of a year in in-game day, by default it is 360 almost as much as a real year, with
default time speed a cycle last 180 RL-hour so about a bit more than a RL-week. The
parameter is limited to a minimum of 16 in-game day.

`season.length_of_year = 360`

All cycles are toggelable, however it is highly unrecommended to disable Equatorial cycle as it is
used as a fallback cycle with no season in it.

Check extra information in the `settingtypes.txt` file

## Troubleshooting

The game was designed for Minetest 5.9.0 and is still a heavy WIP, do not hesitate to report bugs!
