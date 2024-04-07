extends Entity
class_name Player
#Authored by Xander. Please consult for any modifications or major feature requests.

@export var debug : bool = false
@export var data: PlayerData

@export_group("Parameters")
@export var movement_speed : float = 300

@onready var animation_player = $AnimationPlayer

# Normalised vectors
var move_direction: Vector2
var aim_direction: Vector2

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
	if is_instance_valid(data):
		if get_multiplayer_authority() == data.peer_id:
			velocity = move_direction * movement_speed
			if is_casting:
				velocity *= 0.25
			move_and_slide()
		
#endregion

#region Signal methods
func _on_animation_player_animation_finished(anim_name: String):
	if anim_name.contains("cast_start"):
		animation_player.play("cast_end", -1, 1/cast_end_time)
	elif anim_name.contains("cast_end"):
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

func set_input(id: int):
	print("Setting input" + str(id))
	$Input.set_device(id)

# Splitting the functions to separate input from action for RPC
func attempt_cast(slot: int):
	if can_cast and data.spell_cooldowns[slot] <= 0:
		cast_spell(slot)

func cast_spell(slot: int):
	if slot < data.spells.size():
		# Initialise spell object and add to tree
		var spell_node = data.spells[slot].scene.instantiate()
		spell_node.resource = data.spells[slot]
		spell_node.caster = self
		
		#print(get_angle_to(aim_direction) - rotation)
		add_sibling(spell_node)
		
		# Set cooldown
		data.spell_cooldowns_max[slot] = spell_node.cooldown_time
		data.spell_cooldowns[slot] = spell_node.cooldown_time
		
		# Set own animation properties
		is_casting = true
		can_cast = false
		cast_end_time = spell_node.end_time
		animation_player.play("cast_start", -1, 1/spell_node.start_time)
		
		# Allow us to cast a spell again in a certain amount of time
		# (only the authority uses this though)
		await get_tree().create_timer(spell_node.cancel_time).timeout
		can_cast = true
		



#endregion
