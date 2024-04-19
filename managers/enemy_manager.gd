extends Node

@onready var Data: Dictionary = {
	"slime_small" : {
		"scene" : preload("res://moving_entities/enemies/SlimeSmall/SmallSlime.tscn"),
		"difficulty" : 1
	},
	"slime_big" : {
		"scene" : preload("res://moving_entities/enemies/SlimeBig/SlimeBig.tscn"),
		"difficulty" : 1
	}
}
