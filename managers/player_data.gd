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
@export var spell_cooldowns_max : Array[float]
@export var spell_cooldowns : Array[float]

@export var main_color : Color = Color.RED

func _ready():
	spells.resize(3)
	
	spell_cooldowns_max.resize(3)
	spell_cooldowns.fill(1)
	
	spell_cooldowns.resize(3)
	spell_cooldowns.fill(0)
	

func _process(delta):
	for i in spell_cooldowns.size():
		if spell_cooldowns[i] > 0:
			spell_cooldowns[i] -= delta
			if spell_cooldowns[i] < 0:
				spell_cooldowns[i] = 0
