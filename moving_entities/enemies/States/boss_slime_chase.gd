extends State
#class_name
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
var player: Entity
#endregion

#region Godot methods
func physics_update(delta):
	super.physics_update(delta)
	if !player: return
	
	if enemy.perma_enraged:
		Transitioned.emit(self, "bslimesolo")
		return
	enemy.aim_direction = enemy.global_position.direction_to(player.global_position)
	if enemy.can_cast:
		if(enemy.enraged && can_cast_spell(1)):
			enemy.enraged = false
			Transitioned.emit(self, "secondaryattack")
			return
			
		if(can_cast_spell(0)):
			if !("attack_range" in enemy):
				Transitioned.emit(self, "primaryattack")
			elif (enemy.global_position.distance_to(player.global_position) <= enemy.attack_range):
				Transitioned.emit(self, "primaryattack")
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func enter():
	play_anim()

func set_position():
	player = get_closest_player()
	if(player): navigation_agent.target_position = player.global_position
	else: Transitioned.emit(self, "idle")
#endregion

