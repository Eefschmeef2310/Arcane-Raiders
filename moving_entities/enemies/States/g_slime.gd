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
	play_anim()

func physics_update(delta):
	super.physics_update(delta)
	
	if !player: return
	
	if enemy.enraged && can_cast_spell(2): 
		Transitioned.emit(self, "lobattackex")
	
	var distance = player.global_position.distance_to(enemy.global_position)
	if (enemy.can_cast):
		enemy.aim_direction = enemy.global_position.direction_to(player.global_position)
		enemy.target_area = player.global_position
		if(can_cast_spell(0)): Transitioned.emit(self, "lobattack")
		elif(distance < attack_distance && can_cast_spell(1)): Transitioned.emit(self, "spikeattack")

func set_position():
	player = get_closest_player()
	if player: navigation_agent.target_position = player.global_position
	else: Transitioned.emit(self, "idle")
#endregion

