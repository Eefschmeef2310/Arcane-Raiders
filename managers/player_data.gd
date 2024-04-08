extends Node
class_name PlayerData

enum {DEVICE_NONE = -3, DEVICE_ANY = -2, DEVICE_KEYB = -1}

signal health_changed(object, health)
signal spell_changed()
signal device_changed(id: int)

@export var device_id : int = -2
@export var peer_id : int = 1

@export var health : int = 1000
@export var spells : Array[Spell]
@export var spell_cooldowns_max : Array[float]
@export var spell_cooldowns : Array[float]

@export var main_color : Color = Color.RED
@export var character : RaiderRes

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

func _on_player_health_updated(amount):
	health = amount
	health_changed.emit(self, health)

@rpc("any_peer", "call_local", "reliable")
func start_cooldown(slot: int, time: float):
	spell_cooldowns_max[slot] = time
	spell_cooldowns[slot] = time

@rpc("authority", "call_local", "reliable")
func set_spell(slot: int, string: String):
	spells[slot] = SpellManager.get_spell_fron_string(string)
