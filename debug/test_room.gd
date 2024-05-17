extends Node2D
#class_name
#Authored by Xander. Please consult for any modifications or major feature requests.

@export var data_to_fuck_with: PlayerData
@onready var dynamic_camera = $DynamicCamera

func _ready():
	for player in get_tree().get_nodes_in_group("player"):
		dynamic_camera.add_target(player)

func _process(_delta):
	if Input.is_action_just_pressed("debug_random") and data_to_fuck_with:
		for i in data_to_fuck_with.spells.size():
			data_to_fuck_with.spells[i] = SpellManager.get_random_spell()
			data_to_fuck_with.spell_changed.emit()
