extends SpellBase
class_name BatBlinkSpell

const RAY_CASTS = preload("res://moving_entities/enemies/bosses/boss_bat/b_bat_blink/ray_casts.tscn")

@export var particle_duration: float = 0.5

var pos_array: Array #Order is Left, Right, Up, Down
var center_position: Vector2

func _ready():
	#Calculate the center of the room
	if !is_instance_valid(caster): 
		queue_free()
		return

	if !caster.is_multiplayer_authority(): return
	if !has_node("RayCasts"): 
		var raycasts = RAY_CASTS.instantiate()
		add_child(raycasts)
		raycasts.global_position = global_position
	
	global_position = caster.global_position
	for raycast:RayCast2D in $RayCasts.get_children():
		raycast.force_raycast_update()
		pos_array.push_back(raycast.get_collision_point())
		
	center_position = Vector2((pos_array[0].x + pos_array[1].x)/2,(pos_array[2].y + pos_array[3].y)/2)

func caster_visibility(visible: bool):
	#TODO Play particle effect
	caster.visible = visible
	caster.invincible = !visible
	await get_tree().create_timer(particle_duration).timeout

func teleport_to_center():
	if !is_instance_valid(caster) || !caster.is_multiplayer_authority(): return
	await caster_visibility(false)
	caster.global_position = center_position
	await caster_visibility(true)

func teleport_to_random_side():
	if !caster.is_multiplayer_authority(): return
	await caster_visibility(false)
	caster.global_position = center_position
	var raycast:RayCast2D = $RayCasts/RayCastLeft
	raycast.target_position = Vector2.LEFT.rotated(deg_to_rad(randi() % 360)) * 9999
	raycast.force_raycast_update()
	caster.global_position = raycast.get_collision_point() + raycast.get_collision_normal()*100
	await caster_visibility(true)
