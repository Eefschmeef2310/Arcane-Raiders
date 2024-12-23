extends Control
class_name PlayerHUD

@export var data: PlayerData

@onready var spells : Array = [$SpellContainer/Spell,$SpellContainer/Spell2,$SpellContainer/Spell3]

func _process(_delta):
	if is_instance_valid(data):
		for i in spells.size(): 
			var p = (data.spell_cooldowns[i] / data.spell_cooldowns_max[i]) * 100
			spells[i].set_cooldown_percent(p)

func set_data(d: PlayerData):
	if is_instance_valid(data):
		if data.spell_changed.is_connected(update_spells): data.spell_changed.disconnect(update_spells)
		#if data.health_changed.is_connected(_on_player_health_updated): data.health_changed.disconnect(_on_player_health_updated)
		#if data.pickup_proximity_changed.is_connected(_pickup_proximity_changed): data.pickup_proximity_changed.disconnect(_pickup_proximity_changed)
		if data.spell_casted_but_not_ready.is_connected(spell_not_ready): data.spell_casted_but_not_ready.disconnect(spell_not_ready)
		if data.spell_casted_and_ready.is_connected(spell_casted): data.spell_casted_and_ready.disconnect(spell_casted)
		if data.spell_ready.is_connected(spell_ready): data.spell_ready.disconnect(spell_ready)
	data = d
	data.spell_changed.connect(update_spells)
	#data.health_changed.connect(_on_player_health_updated)
	#data.pickup_proximity_changed.connect(_pickup_proximity_changed)
	data.spell_casted_but_not_ready.connect(spell_not_ready)
	data.spell_casted_and_ready.connect(spell_casted)
	data.spell_ready.connect(spell_ready)
	#update_prompts(data.device_id)
	update_spells(0)
	call_deferred("update_spells", 0)
	#$HBox/Stats/HealthBar.tint_progress = data.main_color
	#$HBox/Stats/HealthBar/Border.self_modulate = data.main_color
	#$HBox/Stats/Spells/Head/Panel.self_modulate = data.main_color
	#$HBox/Stats/Spells/Head.texture = data.character.head_texture

func update_spells(_slot):
	if is_instance_valid(data):
		for i in spells.size():
			spells[i].set_spell(data.spells[i])

func spell_not_ready(slot: int):
	if slot < spells.size() && "shake" in spells[slot]:
		spells[slot].shake()

func spell_casted(slot: int):
	if slot < spells.size() && "pulse" in spells[slot]:
		spells[slot].pulse()

func spell_ready(slot: int):
	if slot < spells.size() && "shake" in spells[slot]:
		spells[slot].flash()
