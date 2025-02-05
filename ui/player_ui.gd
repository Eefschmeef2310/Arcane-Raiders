extends Control
class_name PlayerUI
#Authored by Xander. Please consult for any modifications or major feature requests.

@export var icons_keyb: Array[Texture2D]
@export var icons_xbox: Array[Texture2D]
@export var icons_ps: Array[Texture2D]
@export var data: PlayerData
@export var scroll_speed : int = 30

@export var damage_stat : Label
@export var kills_stat :Label

@export_group("Node References")
@export var crown : TextureRect
@export var player_username : Label
@export var synergy_text : Label
@export var synergy_height_control : Control
@export var spells: Array[SpellUISlot]
@export var health_bar : TextureProgressBar
@export var border : NinePatchRect
@export var head_panel : Panel
@export var head : TextureRect
@export var health_bar_linger : TextureProgressBar
@export var hat_label : Label
@export var health_bar_label : Label
@export var element_particle : GPUParticles2D

@export_subgroup("StatBox")
var show_stats : bool = false
@export var stat_panel : PanelContainer
@export var damage_label : Label
@export var kills_label : Label
@export var money_label : Label
@export var reactions_label : Label
 
@export var pickups_label : Label
#@onready var select : JoinSelectUI = $SelectUI

#@export var stats_ticker : ScrollContainer
#@export var stats_ticker_label : Label
#var ticker_progress = 0
#var reset_timer = 3
#var ticker_max_scroll = 0
#var scroll_move :float = 0

var input_prompts: Array

#region Godot methods
func _ready():
	if is_instance_valid(data):
		set_data(data)
		
	synergy_updated(0, Color.WHITE)

func _process(delta):
	if is_instance_valid(data):
		for i in spells.size():
			var p = (data.spell_cooldowns[i] / data.spell_cooldowns_max[i]) * 100
			spells[i].set_cooldown_percent(p)
	
		health_bar_linger.value = move_toward(health_bar_linger.value, health_bar.value, delta*100)
		
		damage_stat.text = "Damage: " + str(data.damage)
		kills_stat.text = "Kills: " + str(data.kills)
		crown.visible = crown.texture != null
		player_username.visible = true
		player_username.text = data.player_name
		player_username.self_modulate = data.main_color
		
		update_stats_ui()
		if InputMap.has_action("debug_toggle_stats") and Input.is_action_just_pressed("debug_toggle_stats"):
			show_stats = not show_stats
		
		#update hat
		if data.hat_string == "":
			crown.texture = null
			hat_label.text = ""
#endregion

#region Signal methods
func update_spells(_slot):
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
	health_bar.max_value = data.max_health
	health_bar.value = data.health
	if health_bar.value <= 0.25 * health_bar.max_value:
		$Flasher.play("flash")
	else:
		$Flasher.stop()
		border.modulate = Color.WHITE
		
	health_bar_label.text = str(floor(health_bar.value/10)) + "/" + str(health_bar.max_value/10)

func _pickup_proximity_changed(b: bool):
	show_equip_ui() if b else hide_equip_ui()

#endregion

#region Other methods (please try to separate and organise!)
func set_data(d: PlayerData):
	if is_instance_valid(data):
		if data.device_changed.is_connected(update_prompts): data.device_changed.disconnect(update_prompts)
		if data.spell_changed.is_connected(update_spells): data.spell_changed.disconnect(update_spells)
		if data.health_changed.is_connected(_on_player_health_updated): data.health_changed.disconnect(_on_player_health_updated)
		if data.pickup_proximity_changed.is_connected(_pickup_proximity_changed): data.pickup_proximity_changed.disconnect(_pickup_proximity_changed)
		if data.spell_casted_but_not_ready.is_connected(spell_not_ready): data.spell_casted_but_not_ready.disconnect(spell_not_ready)
		if data.spell_casted_and_ready.is_connected(spell_casted): data.spell_casted_and_ready.disconnect(spell_casted)
		if data.spell_ready.is_connected(spell_ready): data.spell_ready.disconnect(spell_ready)
		if data.hat_label_changed.is_connected(hat_label_changed): data.hat_label_changed.disconnect(hat_label_changed)
		if data.hat_changed.is_connected(show_hat): data.hat_changed.disconnect(show_hat)
		if data.synergy_updated.is_connected(synergy_updated): data.synergy_updated.disconnect(synergy_updated)
	data = d
	data.device_changed.connect(update_prompts)
	data.spell_changed.connect(update_spells)
	data.health_changed.connect(_on_player_health_updated)
	data.pickup_proximity_changed.connect(_pickup_proximity_changed)
	data.spell_casted_but_not_ready.connect(spell_not_ready)
	data.spell_casted_and_ready.connect(spell_casted)
	data.spell_ready.connect(spell_ready)
	data.hat_changed.connect(show_hat)
	data.hat_label_changed.connect(hat_label_changed)
	data.synergy_updated.connect(synergy_updated)
	update_prompts(data.device_id)
	update_spells(0)
	
	health_bar.tint_progress = data.main_color
	border.self_modulate = data.main_color
	head_panel.self_modulate = data.main_color
	if data.character:
		head.texture = data.character.head_texture

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

func spell_not_ready(slot: int):
	if "shake" in spells[slot]:
		spells[slot].shake()

func spell_casted(slot: int):
	if "pulse" in spells[slot]:
		spells[slot].pulse()

func spell_ready(slot: int):
	if "shake" in spells[slot]:
		spells[slot].flash()

func hat_label_changed(stri: String):
	hat_label.text = stri

func show_hat(hat : Hat):
	#hat_label.visible = data.hat_string
	if hat and hat.sprite:
		crown.texture = hat.sprite
		crown.show()

func synergy_updated(synergy_bonus, color):
	if synergy_bonus == 0:
		synergy_height_control.hide()
		synergy_text.text = ""
		for slot in spells:
			slot.set_particles(false)
	else:
		synergy_height_control.show()
		for slot in range(spells.size()):
			spells[slot].set_particles(data.spells[slot].element == data.synergy_element)
		
		element_particle.texture = data.spells[0].element.pip_texture
		element_particle.emitting = data.spells[0].element == data.spells[1].element and data.spells[0].element == data.spells[2].element
			
		synergy_text.text = "Synergy Bonus! + " + str(synergy_bonus*100) + "% damage!"
		synergy_text.add_theme_color_override("font_color", color)
#endregion

#region Stats Ticker Experiment
#func show_stats_ticker():
	#stats_ticker.visible = true
	#stats_ticker.scroll_horizontal = 0
	#ticker_max_scroll = stats_ticker.get_h_scroll_bar().max_value
	#
#
#func hide_stats_ticker():
	#stats_ticker.visible = false
	#
#func stats_ticker_process(delta : float):
	##update stats
	#stats_ticker_label.text = "Damage: " + str(data.damage) + "   •   Kills: " + str(data.kills) + "   •   Total Money Earnt: " + str(data.total_money) + "   •   Reactions Created: " + str(data.reactions_created) + "   •   Pickups Obtained: " + str(data.pickups_obtained)
	##stats_ticker.scroll_horizontal += delta * scroll_speed
	#scroll_move += delta * scroll_speed
	#if (scroll_move > 1):
		#var scroll_amount = floor(scroll_move)
		#scroll_move -= scroll_amount
		#stats_ticker.scroll_horizontal += scroll_amount
#
	#print_debug("Current Scroll/Max Scroll: " + str(stats_ticker.scroll_horizontal)+"/"+str(ticker_max_scroll))
	#if stats_ticker.scroll_horizontal >= ticker_max_scroll -5:
		#reset_timer -= delta
		#if reset_timer < 0:
			#reset_timer = 3
			#scroll_move = 0
			##stats_ticker.visible = true
			##stats_ticker.scroll_horizontal = 0
			##ticker_max_scroll = stats_ticker.get_h_scroll_bar().max_value
			#show_stats_ticker()
			#
#endregion

func show_stats_ui():
	$StatsAnimation.play("show")
	show_stats = true
	
func hide_stats_ui():
	$StatsAnimation.play("hide")
	show_stats = false

func update_stats_ui():
	$StatsUI.visible = show_stats and not $EquipUI.visible
	damage_label.text = "Damage: " + str(data.damage)
	kills_label.text = "Kills: " + str(data.kills)
	money_label.text = "Total Money: " + str(data.total_money)
	reactions_label.text = "Reactions: " + str(data.reactions_created)
	pickups_label.text = "Pickups: " + str(data.pickups_obtained)

