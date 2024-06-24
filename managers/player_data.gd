extends Node
class_name PlayerData

enum {DEVICE_NONE = -3, DEVICE_ANY = -2, DEVICE_KEYB = -1}

signal health_changed(object, health)
signal spell_changed(slot)
signal device_changed(id: int)
signal pickup_proximity_changed(bool)
signal spell_casted_but_not_ready(spell: int)
signal spell_ready(spell: int)

@export var device_id : int = -2
@export var peer_id : int = 1
@export var player_name : String

@export var max_health : int = 1000
@export var health : int = 1000:
	set(v):
		health = clamp(v, 0, max_health)
var spells : Array[Spell] = [null,null,null]
@export var spell_cooldowns_max : Array[float] = [0,0,0]
var spell_cooldowns : Array[float] = [0,0,0]
@export var spell_strings : Array[String] = ["", "", ""]

@export var main_color : Color = Color.RED
@export var character : RaiderRes

@export var money : int
@export var total_money : int #all the money the player has earnt this run

#stats 
@export var damage : int
@export var kills : int
@export var reactions_created : int
@export var pickups_obtained : int
@export var has_crown : bool

func _ready():
	#spell_strings.resize(3)
	#spells.resize(3)
	
	for i in spells.size():
		if spells[i] != null:
			spells[i] = spells[i].duplicate(true)
	
	spell_cooldowns_max.resize(spells.size())
	spell_cooldowns.resize(spells.size())
	spell_cooldowns.fill(0)
	
	for i in spells.size():
		if spell_strings[i] != "":
			spells[i] = SpellManager.get_spell_from_string(spell_strings[i])

func _process(delta):
	for i in spell_cooldowns.size():
		if spell_cooldowns[i] > 0:
			spell_cooldowns[i] -= delta
			if spell_cooldowns[i] <= 0:
				spell_cooldowns[i] = 0
				spell_ready.emit(i)

func _on_player_health_updated(amount):
	health = amount
	health_changed.emit(self, health)

func start_cooldown(slot: int, time: float):
	spell_cooldowns_max[slot] = time
	
	spell_cooldowns[slot] = time

func set_spell_from_string(slot: int, string: String):
	spell_strings[slot] = string
	spells[slot] = SpellManager.get_spell_from_string(string)
	spell_cooldowns[slot] = 0
	spell_changed.emit(slot)
