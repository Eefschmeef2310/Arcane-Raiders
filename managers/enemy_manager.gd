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
	}
}
