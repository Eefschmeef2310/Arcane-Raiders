extends SpellBase
class_name ProjOrbit

@onready var path_2d = $Path2D
@onready var kill_timer = $KillTimer
const PROJ_ORBIT_FOLLOW = preload("res://spells/scenes/proj_orbit/proj_orbit_follow.tscn")
const PROJ_ORBIT_EXPLOSION = preload("res://spells/scenes/proj_orbit/proj_orbit_explosion.tscn")

@export var proj_amount : float = 1
@export var expand_time : float = 1

func _ready():
	for i in proj_amount:
		var follow : ProjOrbitFollow = PROJ_ORBIT_FOLLOW.instantiate()
		path_2d.add_child(follow)
		follow.progress_ratio = i * (1.0/proj_amount)
		if caster and "aim_direction" in caster:
			var angle = caster.aim_direction.angle()
			if angle > PI * 0.5 and angle < PI * 1.5:
				follow.orbit_time *= -1
		
		var explosion = PROJ_ORBIT_EXPLOSION.instantiate()
		transfer_data(explosion)
		follow.add_child(explosion)
	
	if is_instance_valid(caster):
		global_position = caster.global_position
		global_position.y -= 5

func _process(delta):
	if is_instance_valid(caster):
		global_position = caster.global_position
		global_position.y -= 5
	else:
		queue_free()
	
	scale.x = move_toward(scale.x, 1, expand_time * delta)
	scale.y = scale.x

func _on_kill_timer_timeout():
	queue_free()
