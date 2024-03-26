extends CharacterBody2D
class_name Player
#Authored by Xander. Please consult for any modifications or major feature requests.

@export var data: PlayerData

@export_group("Parameters")
@export var movement_speed : float = 300

var direction: Vector2

#region Godot methods
func _ready():
	# TODO temporary lines here
	set_input(data.device_id)

func _process(delta):
	if is_instance_valid(data):
		if get_multiplayer_authority() == data.peer_id:
			velocity = direction * movement_speed
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
	print(id)
	$Input.input = DeviceInput.new(id)

func cast_spell(slot: int):
	if slot < data.spells.size():
		var cast_spell = data.spells[slot].spell_scene.instantiate()
		cast_spell.resource = data.spells[slot]
		cast_spell.global_position = global_position
		owner.add_child(cast_spell)

#endregion
