extends Node
class_name PlayerData

enum {DEVICE_NONE = -3, DEVICE_ANY = -2, DEVICE_KEYB = -1}

signal health_changed()
signal spell_changed()
signal device_changed(id: int)

@export var device_id : int = -2
@export var peer_id : int = 1

@export var health : int:
	set(val):
		health = val
		health_changed.emit()
@export var spells : Array[Spell]:
	set(val):
		spells = val
		spell_changed.emit()
@export var spell_cooldowns : Array[float]

@export var main_color : Color = Color.RED
