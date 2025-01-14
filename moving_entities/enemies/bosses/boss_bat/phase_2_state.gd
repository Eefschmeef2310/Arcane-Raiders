extends State
#class_name
#Authored by AlexV. Please consult for any modifications or major feature requests.
@export var ray_cast_2d:RayCast2D

func enter():
	play_anim()
	set_position()
	
func physics_update(delta):
	super.physics_update(delta)
	if can_cast_spell(2):
		var random = randi() % 360
		ray_cast_2d.target_position = Vector2.RIGHT.rotated(deg_to_rad(random)) * 9999
		ray_cast_2d.force_raycast_update()
		var wall_pos = ray_cast_2d.get_collision_point()
		if wall_pos.distance_to(enemy.global_position) < 200:
			ray_cast_2d.target_position = Vector2.RIGHT.rotated(deg_to_rad(random - 180))
			ray_cast_2d.force_raycast_update()
			wall_pos = ray_cast_2d.get_collision_point()
		
		enemy.target_player = get_closest_player()
		enemy.dash_prep_pos = wall_pos
		enemy.aim_direction = wall_pos.direction_to(get_closest_player().global_position)
		Transitioned.emit(self, "blinkattack")
