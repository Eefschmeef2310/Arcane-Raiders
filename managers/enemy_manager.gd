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
	"nest" : {
		"scene" : preload("res://moving_entities/enemies/nest/basic_nest.tscn"),
		"difficulty" : 3
	},
	"spider_big" : {
		"scene" : preload("res://moving_entities/enemies/large_spider/large_spider.tscn"),
		"difficulty" : 10
	},
	"spiderling" : {
		"scene" : preload("res://moving_entities/enemies/spiderling/spiderling.tscn"),
		"difficulty" : 0.5
	},
	"boss_slime": {
		"scene" : preload("res://moving_entities/enemies/boss_slime/giant_slime/boss_slime.tscn"),
		"difficulty" : 999
	},
	"water_slime": {
		"scene" : preload("res://moving_entities/enemies/boss_slime/water_slime/water_slime.tscn"),
		"difficulty" : 999
	},
	"electric_slime": {
		"scene" : preload("res://moving_entities/enemies/boss_slime/elec_slime/elec_slime.tscn"),
		"difficulty" : 999
	}
}
