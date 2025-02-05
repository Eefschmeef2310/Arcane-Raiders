extends Node

@onready var Data: Dictionary = {
	"slime_small" : {
		"scene" : preload("res://moving_entities/enemies/SlimeSmall/SmallSlime.tscn"),
		"difficulty" : 1
	},
	"slime_big" : {
		"scene" : preload("res://moving_entities/enemies/SlimeBig/SlimeBig.tscn"),
		"difficulty" : 4
	},
	"bat_small" : {
		"scene" : preload("res://moving_entities/enemies/bat_small/bat_small.tscn"),
		"difficulty" : 4
	},
	"bat_big" : {
		"scene" : preload("res://moving_entities/enemies/bat_big/bat_big.tscn"),
		"difficulty" : 8
	},
	"nest" : {
		"scene" : preload("res://moving_entities/enemies/nest/basic_nest.tscn"),
		"difficulty" : 6
	},
	"spider_big" : {
		"scene" : preload("res://moving_entities/enemies/large_spider/large_spider.tscn"),
		"difficulty" : 10
	},
	"spiderling" : {
		"scene" : preload("res://moving_entities/enemies/spiderling/spiderling.tscn"),
		"difficulty" : 0.5
	},
	"bee" : {
		"scene" : preload("res://moving_entities/enemies/bee/bee.tscn"),
		"difficulty" : 2
	},
	#"hornet" : {
		#"scene" : preload("res://moving_entities/enemies/hornet/hornet.tscn"),
		#"difficulty" : 8
	#},
	"boss_slime": {
		"scene" : preload("res://moving_entities/enemies/boss_slime/giant_slime/boss_slime.tscn"),
		"difficulty" : 999
	},
	"fire_ice_slime": {
		"scene" : preload("res://moving_entities/enemies/boss_slime/fire_ice_slime/giant_fire_ice_slime.tscn"),
		"difficulty" : 999
	},
	"wind_rock_slime": {
		"scene" : preload("res://moving_entities/enemies/boss_slime/wind_rock_slime/giant_wind_rock_slime.tscn"),
		"difficulty" : 999
	},
	"water_slime": {
		"scene" : preload("res://moving_entities/enemies/boss_slime/water_slime/water_slime.tscn"),
		"difficulty" : 999
	},
	"electric_slime": {
		"scene" : preload("res://moving_entities/enemies/boss_slime/elec_slime/elec_slime.tscn"),
		"difficulty" : 999
	},
	"fire_slime": {
		"scene" : preload("res://moving_entities/enemies/boss_slime/fire_ice_slime/fire_slime.tscn"),
		"difficulty" : 999
	},
	"ice_slime": {
		"scene" : preload("res://moving_entities/enemies/boss_slime/fire_ice_slime/ice_slime.tscn"),
		"difficulty" : 999
	},
	"wind_slime": {
		"scene" : preload("res://moving_entities/enemies/boss_slime/wind_rock_slime/wind_slime.tscn"),
		"difficulty" : 999
	},
	"rock_slime": {
		"scene" : preload("res://moving_entities/enemies/boss_slime/wind_rock_slime/rock_slime.tscn"),
		"difficulty" : 999
	},
	"boss_bat": {
		"scene" : preload("res://moving_entities/enemies/bosses/boss_bat/boss_bat.tscn"),
		"difficulty" : 999
	},
	"wizard_manager": {
		"scene" : preload("res://moving_entities/enemies/boss_wizard/wizard_manager.tscn"),
		"difficulty" : 999
	},
	"wizard": {
		"scene" : preload("res://moving_entities/enemies/boss_wizard/evil_wizard.tscn"),
		"difficulty" : 999
	}
}
