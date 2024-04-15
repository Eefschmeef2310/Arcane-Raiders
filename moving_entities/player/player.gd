extends Entity
class_name Player
#Authored by Xander. Please consult for any modifications or major feature requests.

@export var debug : bool = false
@export var data: PlayerData

@export_group("Parameters")
@export var movement_speed : float = 300

@onready var animation_player = $AnimationPlayer

# Normalised vectors
@export var move_direction: Vector2
@export var aim_direction: Vector2

var preparing_cast_slot := -1
var is_casting := false
var can_cast := true
var cast_end_time : float

#region Godot methods
func _ready():
	aim_direction = Vector2(1,1)
	animation_player.play("idle", -1, 1)
	
	# TODO temporary lines here
	if debug:
		set_data(data, false)
		
	

func _process(_delta):
	super._process(_delta)
	if is_instance_valid(data):
		if get_multiplayer_authority() == data.peer_id:
			velocity = move_direction * movement_speed * frost_speed_scale
			if is_casting or preparing_cast_slot >= 0:
				velocity *= 0.25
			move_and_slide()
	
	if aim_direction.x < 0:
		$SpritesFlip.scale.x = -1
	else:
		$SpritesFlip.scale.x = 1
	
	if !is_casting and preparing_cast_slot < 0:
		if move_direction != Vector2.ZERO:
			animation_player.play("move", -1, 1)
		else:
			animation_player.play("idle", -1, 1)
	
	if debug:
		$PrepareCast.text = str(preparing_cast_slot)
		$CanCast.text = str(can_cast)
	
#endregion

#region Signal methods
func _on_animation_player_animation_finished(anim_name: String):
	if anim_name.contains("cast_end"):
		animation_player.play("idle", -1, 1)
		is_casting = false
#endregion

#region Other methods (please try to separate and organise!)
func set_data(new_data: PlayerData, destroy_old := true):
	if destroy_old:
		data.queue_free()
	data = new_data
	
	set_input(data.device_id)
	$SpellDirection/Sprite2D.modulate = data.main_color
	$SpritesFlip/SpritesScale/Body.self_modulate = data.main_color
	
	if data.character:
		print(data.character.raider_name)
		$SpritesFlip/SpritesScale/Head.texture = data.character.head_texture
		$SpritesFlip/SpritesScale/RightHand.self_modulate = data.character.skin_color
		$SpritesFlip/SpritesScale/LeftHand.self_modulate = data.character.skin_color
	
	call_deferred("set_multiplayer_authority", data.peer_id, true)

func set_input(id: int):
	print("Setting input" + str(id))
	$Input.set_device(id)

func prepare_cast(slot: int):
	if can_cast and preparing_cast_slot < 0 and data.spell_cooldowns[slot] <= 0:
		preparing_cast_slot = slot
		animation_player.stop()
		animation_player.play("cast_start")

# Splitting the functions to separate input from action for RPC
func attempt_cast(slot: int):
	if can_cast and data.spell_cooldowns[slot] <= 0:
		cast_spell.rpc(slot)
	preparing_cast_slot = -1

@rpc("authority", "call_local", "reliable")
func cast_spell(slot: int):
	if slot < data.spells.size() and data.spells[slot]:
		# Initialise spell object and add to tree
		var spell_node = data.spells[slot].scene.instantiate()
		spell_node.resource = data.spells[slot]
		spell_node.caster = self
		spell_node.set_multiplayer_authority(get_multiplayer_authority(), true)
		
		#print(get_angle_to(aim_direction) - rotation)
		add_sibling(spell_node)
		
		# Set cooldown
		data.spell_cooldowns_max[slot] = spell_node.cooldown_time
		data.spell_cooldowns[slot] = spell_node.cooldown_time
		
		# Set own animation properties
		is_casting = true
		can_cast = false
		cast_end_time = spell_node.end_time
		animation_player.play("cast_end", -1, 1/spell_node.end_time)
		
		# Allow us to cast a spell again in a certain amount of time
		# (only the authority uses this though)
		await get_tree().create_timer(spell_node.cancel_time).timeout
		can_cast = true
		



#endregion
