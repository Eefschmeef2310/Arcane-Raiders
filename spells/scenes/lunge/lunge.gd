extends SpellBase

@onready var dash_ray_rotator = $DashRayRotator
@onready var dash_ray = $DashRayRotator/DashRay

@export var lunge_duration : float = 0.5
@export var lunge_speed : float

var lunge_time : float
var lunge_direction : Vector2
var lunge_target_pos : Vector2
@onready var lunge_explosion = $LungeExplosion


func _ready():
	if !is_instance_valid(caster):
		queue_free()
	
	global_position = caster.global_position
	
	lunge_direction = caster.aim_direction
	lunge_target_pos = to_global(lunge_direction.normalized() * lunge_speed * lunge_duration)
	
	lunge_time = lunge_duration
	
	transfer_data(lunge_explosion)

func _process(delta):
	global_position = caster.global_position
	caster.ignore_movement_input_next_tick = true
	
	dash_muck_with_collider()
	caster.velocity = lunge_direction * lunge_speed
	caster.move_and_slide()
	
	lunge_time -= delta
	if lunge_time <= 0:
		caster.collision_shape.disabled = false
		queue_free()

func dash_muck_with_collider():
	dash_ray.get_parent().rotation = lunge_direction.angle()
	dash_ray.target_position = dash_ray.to_local(lunge_target_pos)
	dash_ray.force_raycast_update()
	
	caster.collision_shape.disabled = dash_ray.is_colliding()
