extends CharacterBody2D
class_name Player
#Authored by Xander. Please consult for any modifications or major feature requests.

@export var data: PlayerData

@export_group("Parameters")
@export var movement_speed : float = 300

# Normalised vectors
var move_direction: Vector2
var aim_direction: Vector2

#region Godot methods
func _ready():
	# TODO temporary lines here
	set_input(data.device_id)

func _process(_delta):
	if is_instance_valid(data):
		if get_multiplayer_authority() == data.peer_id:
			velocity = move_direction * movement_speed
			move_and_slide()
		
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func init(new_data: PlayerData):
	data.queue_free()
	data = new_data
	set_input(data.device_id)

func set_input(id: int):
	#print(id)
	$Input.set_device(id)

func cast_spell(slot: int):
	if slot < data.spells.size():
		var spell_node = data.spells[slot].spell_scene.instantiate()
		spell_node.resource = data.spells[slot]
		spell_node.global_position = global_position
		spell_node.rotation = get_angle_to(global_position + aim_direction)
		#print(get_angle_to(aim_direction) - rotation)
		owner.add_child(spell_node)

#endregion
