extends Node

@onready var Data: Dictionary = {
	"dummy" : {
		"scene" : preload("res://moving_entities/enemies/dummy_enemy.tscn"),
		"difficulty" : 1
	},
	"slime_small" : {
		"scene" : preload("res://moving_entities/enemies/SlimeSmall/SmallSlime.tscn"),
		"difficulty" : 1
	},
	"slime_big" : {
		"scene" : preload("res://moving_entities/enemies/SlimeBig/SlimeBig.tscn"),
		"difficulty" : 1
	},
	"bat_small" : {
		"scene" : preload("res://moving_entities/enemies/bat_small/bat_small.tscn"),
		"difficulty" : 1
	}
}
