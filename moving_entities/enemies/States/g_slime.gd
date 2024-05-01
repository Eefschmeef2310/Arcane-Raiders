extends State
class_name GSlime
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
func enter():
	set_position()

func physics_update(delta):
	super.physics_update(delta)
	
	if !player: return
	
	if enemy.enraged: 
		Transitioned.emit(self, "gslimeenraged")
		print("enraged")
	
	var distance = player.global_position.distance_to(enemy.global_position)
	if (enemy.can_cast):
		enemy.aim_direction = enemy.global_position.direction_to(player.global_position)
		enemy.target_area = player.global_position
		enemy.attempt_cast(0)
		if(distance < attack_distance):
			enemy.attempt_cast(1)

func set_position():
	player = get_closest_player()
	if player: navigation_agent.target_position = player.global_position
	else: Transitioned.emit(self, "idle")
#endregion

