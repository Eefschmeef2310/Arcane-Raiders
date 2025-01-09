extends Node
class_name PlayerData

enum {DEVICE_NONE = -3, DEVICE_ANY = -2, DEVICE_KEYB = -1}

signal health_changed(object, health)
signal spell_changed(slot)
signal synergy_updated(amount : float, color : Color)
signal hat_changed(hat : Hat)
signal device_changed(id: int)
signal pickup_proximity_changed(bool)
signal spell_casted_but_not_ready(spell: int)
signal spell_casted_and_ready(spell: int)
signal spell_ready(spell: int)
signal hat_label_changed(text: String)
signal destroy()
signal reassign()
signal customise()

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

@export_category("Hats")
@export var hat_string : StringName = ""
@export var hat_sprite : Texture2D

@export var main_color : Color = Color.RED
@export var character : RaiderRes
@export var body_sprite : Texture2D

@export var money : int
@export var total_money : int #all the money the player has earnt this run

#stats 
@export var damage : int
@export var kills : int
@export var reactions_created : int
@export var pickups_obtained : int
@export var has_crown : bool
var took_damage : bool = false

@export var synergy_bonus : float
@export var synergy_element : ElementResource

func _ready():
	#spell_strings.resize(3)
	#spells.resize(3)
	
	spell_changed.connect(get_synergy)
	
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
	#if health < 100:
		#print("tabby: player dmage detected")
		#SteamManager.damageless = false

func start_cooldown(slot: int, time: float):
	spell_cooldowns_max[slot] = time
	spell_cooldowns[slot] = time

func set_spell_from_string(slot: int, string: String):
	spell_strings[slot] = string
	spells[slot] = SpellManager.get_spell_from_string(string)
	spell_cooldowns[slot] = 0
	spell_changed.emit(slot)

func get_synergy(_slot):
	#Update synergy mutliplier
	var color : Color
	if spells[0] and spells[1] and spells[2]:
		if spells[0].element == spells[1].element and spells[1].element == spells[2].element and spells[0].element.prefix != "": #All same element
			synergy_bonus = 0.5
			color = spells[0].element.colour
			synergy_element = spells[0].element
			SteamManager.grant_achievement("synergy")
		elif (spells[0].element == spells[1].element or spells[0].element == spells[2].element) and spells[0].element.prefix != "":
			synergy_bonus = 0.25
			color = spells[0].element.colour
			synergy_element = spells[0].element
		elif spells[1].element == spells[2].element and spells[1].element.prefix != "":
			synergy_bonus = 0.25
			color = spells[1].element.colour
			synergy_element = spells[1].element
		else:
			synergy_bonus = 0
			synergy_element = null
		
		synergy_updated.emit(synergy_bonus, color)
	
	#21st night achievement
	if spells[0] and spells[1] and spells[2]:
		print("tabby:" + spells[0].element.prefix)
		var earth : bool = spells[0].element.prefix == "Stun-" or spells[1].element.prefix == "Stun-" or spells[2].element.prefix == "Stun-"
		var wind : bool = spells[0].element.prefix == "Wind-" or spells[1].element.prefix == "Wind-" or spells[2].element.prefix == "Wind-"
		var fire : bool = spells[0].element.prefix == "Pyro-" or spells[1].element.prefix == "Pyro-" or spells[2].element.prefix == "Pyro-"
		if earth and wind and fire:
			SteamManager.grant_achievement("21st_night")

func set_hat_from_string(s: String):
	hat_string = s
	
	var temp_hat
	if HatManager.get_hat_from_string(hat_string):
		temp_hat = HatManager.get_hat_from_string(hat_string).instantiate()
		hat_sprite = temp_hat.sprite
	
	hat_changed.emit(temp_hat)
