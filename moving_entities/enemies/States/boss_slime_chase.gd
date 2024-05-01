extends State
#class_name
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var prefix: String = "w"
	#Onready Variables

	#Other Variables (please try to separate and organise!)
var player: Entity
#endregion

#region Godot methods
func physics_update(delta):
	super.physics_update(delta)
	if !player: return
	
	if enemy.perma_enraged:
		Transitioned.emit(self, prefix + "slimeperma")
	enemy.aim_direction = enemy.global_position.direction_to(player.global_position)
	if enemy.can_cast:
		if(enemy.enraged):
			Transitioned.emit(self, prefix+"slimetemp")
			return
		
		elif !("attack_range" in enemy):
			enemy.attempt_cast(0)
		elif (enemy.global_position.distance_to(player.global_position) <= enemy.attack_range):
			enemy.attempt_cast(0)
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

func set_position():
	player = get_closest_player()
	if(player): navigation_agent.target_position = player.global_position
	else: Transitioned.emit(self, "idle")
#endregion

