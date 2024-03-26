extends CharacterBody2D
class_name Player
#Authored by Xander. Please consult for any modifications or major feature requests.

@export var data: PlayerData

@export_group("Parameters")
@export var movement_speed : float = 300

var direction: Vector2

#region Godot methods
func _ready():
	#Runs when all children have entered the tree
	pass

func _process(delta):
	if is_instance_valid(data):
		if get_multiplayer_authority() == data.peer_id:
			velocity = direction * movement_speed
		
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func init(new_data: PlayerData):
	data = new_data

#endregion
