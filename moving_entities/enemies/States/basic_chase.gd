extends State
class_name BasicChase
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var attack_distance: float = 50
	#Onready Variables

	#Other Variables (please try to separate and organise!)
var player: Player
#endregion

#region Godot methods

#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func update(_delta):
	super.update(_delta)
	if !player: return
	var distance = player.global_position.distance_to(enemy.global_position)
	if (distance < attack_distance && can_cast_spell(0)):
		enemy.aim_direction = enemy.global_position.direction_to(player.global_position)
		enemy.target_area = player.global_position
		Transitioned.emit(self, "attack")
	
func physics_update(_delta):
	super.physics_update(_delta)

func enter():
	set_position()
	play_anim()

func set_position():
	player = get_closest_player()
	if player: navigation_agent.target_position = player.global_position
	else: Transitioned.emit(self, "idle")
#endregion

