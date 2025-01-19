extends State
class_name BeeChase
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
@export var attack_range: float = 200
@export var move_distance: float = 200
var player: Player
var flip_val = 0
#endregion

#region Godot methods

#endregion

#region Signal methods
func _on_navigation_agent_2d_target_reached():
	nav_timer = 0.5
#endregion

#region Other methods (please try to separate and organise!)
func enter():
	play_anim()

#Attack when in attack range
func physics_update(delta):
	super.physics_update(delta)
	if !player: return
	
	var distance = enemy.global_position.distance_to(player.global_position)
	if distance <= attack_range && can_cast_spell(0):
		enemy.aim_direction = enemy.global_position.direction_to(player.global_position)
		Transitioned.emit(self, "attack")

#Get direction to player, add a random rotation, then set that as the target pos
func set_position():
	player = get_closest_player()
	if !player: 
		Transitioned.emit(self, "idle")
		return
	
	#If spell is on cooldown, move away from the player
	flip_val = 0 if can_cast_spell(0) else 180
	
	var direction = enemy.global_position.direction_to(player.global_position).rotated(deg_to_rad(randi()%121 - 60 + flip_val))
	navigation_agent.target_position = direction * move_distance + enemy.global_position
#endregion



