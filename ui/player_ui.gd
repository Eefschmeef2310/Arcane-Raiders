extends VBoxContainer
class_name PlayerUI
#Authored by Xander. Please consult for any modifications or major feature requests.

@export var icons_keyb: Array[Texture2D]
@export var icons_xbox: Array[Texture2D]
@export var icons_ps: Array[Texture2D]
@export var data: PlayerData

@onready var spells: Array = [$HBox/Stats/Spells/Spell0, $HBox/Stats/Spells/Spell1, $HBox/Stats/Spells/Spell2]
@onready var health_bar = $HBox/Stats/HealthBar
@onready var health_bar_linger = $HBox/Stats/HealthBar/HealthBarLinger


var input_prompts: Array

#region Godot methods
func _ready():
	if is_instance_valid(data):
		set_data(data)

func _process(delta):
	if is_instance_valid(data):
		for i in spells.size():
			var p = (data.spell_cooldowns[i] / data.spell_cooldowns_max[i]) * 100
			spells[i].set_cooldown_percent(p)
	
	health_bar_linger.value = move_toward(health_bar_linger.value, health_bar.value, delta*100)
#endregion

#region Signal methods
func update_spells():
	if is_instance_valid(data):
		for i in spells.size():
			spells[i].set_spell(data.spells[i])

func update_prompts(id: int):
	if id <= -2 or data.peer_id != multiplayer.get_unique_id():
		for spell in spells:
			spell.hide_prompt()
	else:
		var lib: PromptLibrary = PromptManager.get_prompt_lib(id)
		if lib:
			var icons = [lib.spell0, lib.spell1, lib.spell2]
			for i in spells.size():
				spells[i].show_prompt()
				spells[i].change_prompt(icons[i])

func _on_player_health_updated(_player_data, _amount):
	print("updating health bar")
	health_bar.value = data.health
	$HBox/Stats/HealthBar/Label.text = str(floor(health_bar.value/10)) + "/" + str(health_bar.max_value/10)

func _pickup_proximity_changed(b: bool):
	show_equip_ui() if b else hide_equip_ui()

#endregion

#region Other methods (please try to separate and organise!)
func set_data(d: PlayerData):
	if is_instance_valid(data):
		data.device_changed.disconnect(update_prompts)
		data.spell_changed.disconnect(update_spells)
		data.health_changed.disconnect(_on_player_health_updated)
		data.pickup_proximity_changed.disconnect(_pickup_proximity_changed)
	data = d
	data.device_changed.connect(update_prompts)
	data.spell_changed.connect(update_spells)
	data.health_changed.connect(_on_player_health_updated)
	data.pickup_proximity_changed.connect(_pickup_proximity_changed)
	update_prompts(data.device_id)
	update_spells()
	$HBox/Stats/HealthBar.tint_progress = data.main_color
	$HBox/Stats/HealthBar/Border.self_modulate = data.main_color
	$HBox/Stats/Spells/Head.texture = data.character.head_texture

# TODO RUNS EVERY FRAME
# convert to signals if possible
func show_equip_ui():
	$EquipUI.show()
	$EquipUI/Label.text = "Press to equip!"
	for spell in spells:
		spell.show_arrow()

func hide_equip_ui():
	$EquipUI.hide()
	for spell in spells:
		spell.hide_arrow()

#endregion
