extends Node2D
#class_name
#Authored by Xander. Please consult for any modifications or major feature requests.

@export var data_to_fuck_with: PlayerData

func _process(_delta):
	if Input.is_action_just_pressed("debug_random") and data_to_fuck_with:
		for i in data_to_fuck_with.spells.size():
			data_to_fuck_with.spells[i] = SpellManager.every_spell[SpellManager.every_spell.keys().pick_random()]
			data_to_fuck_with.spell_changed.emit()
