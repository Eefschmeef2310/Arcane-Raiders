extends State
#class_name
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
var player: Entity
#endregion

#region Other methods (please try to separate and organise!)
func enter():
	play_anim()
	
func physics_update(delta):
	super.physics_update(delta)
	if !player: return
	if enemy.can_cast:
		enemy.target_area = player.global_position
		enemy.aim_direction = enemy.global_position.direction_to(player.global_position)
		if(can_cast_spell(1)):
			Transitioned.emit(self, "secondaryattack")
		elif(can_cast_spell(0)):
			if !("attack_range" in enemy):
				Transitioned.emit(self, "primaryattack")
			elif (enemy.global_position.distance_to(player.global_position) <= enemy.attack_range):
				Transitioned.emit(self, "primaryattack")
	
func set_position():
	player = get_closest_player()
	if(player): navigation_agent.target_position = player.global_position
	else: navigation_agent.target_position = enemy.global_position
#endregion

