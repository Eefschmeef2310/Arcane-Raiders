extends SpellBase
class_name BatBlinkSpell

const RAY_CASTS = preload("res://moving_entities/enemies/bosses/boss_bat/b_bat_blink/ray_casts.tscn")
const POOF_SCENE = preload("res://moving_entities/enemies/bosses/boss_bat/poof.tscn")

@export var particle_duration: float = 0.5

var pos_array: Array #Order is Left, Right, Up, Down
var center_position: Vector2

func _ready():
	#Calculate the center of the room
	if !is_instance_valid(caster): 
		queue_free()
		return

	if !has_node("RayCasts"): 
		var raycasts = RAY_CASTS.instantiate()
		add_child(raycasts)
		raycasts.global_position = global_position
	
	global_position = caster.global_position
	var is_inside:bool = true
	for raycast:RayCast2D in $RayCasts.get_children():
		raycast.force_raycast_update()
		if !raycast.is_colliding():
			is_inside = false
		pos_array.push_back(raycast.get_collision_point())
		
	if !is_inside and "spawn_point" in caster:
		center_position = caster.spawn_point
	else:
		center_position = Vector2((pos_array[0].x + pos_array[1].x)/2,(pos_array[2].y + pos_array[3].y)/2)

func caster_visibility(vis: bool):
	var poof = POOF_SCENE.instantiate()
	poof.global_position = caster.global_position
	poof.z_index = caster.z_index + 1
	add_sibling(poof)
	
	caster.visible = vis
	caster.invincible = !vis
	await get_tree().create_timer(particle_duration).timeout

func teleport_to_center():
	if !is_instance_valid(caster): return
	await caster_visibility(false)
	caster.global_position = center_position
	await caster_visibility(true)

func teleport_to_random_side():
	#if !caster.is_multiplayer_authority(): return
	await caster_visibility(false)
	global_position = center_position
	var raycast:RayCast2D = $RayCasts/RayCastLeft
	raycast.target_position = Vector2.LEFT.rotated(deg_to_rad(randi() % 360)) * 9999
	raycast.force_raycast_update()
	caster.global_position = raycast.get_collision_point() + raycast.get_collision_normal()*100
	
	await caster_visibility(true)
	
	caster.target_player = get_closest_player(caster.global_position)
	caster.aim_direction = caster.global_position.direction_to(caster.target_player.global_position)

func get_closest_player(pos: Vector2) -> CharacterBody2D:
	var p_arr = get_tree().get_nodes_in_group("player")
	var target
	var dist = INF
	for p in p_arr:
		if p is Player and pos.distance_to(p.global_position) < dist and !p.is_in_group("enemy"):
			target = p
			dist = pos.distance_to(p.global_position)
			
	if target: return target
	return null
