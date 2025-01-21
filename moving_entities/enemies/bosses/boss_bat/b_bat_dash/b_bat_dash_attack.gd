extends SpellBase

const B_BAT_FISSION = preload("res://moving_entities/enemies/bosses/boss_bat/b_bat_dash/b_bat_fission.tscn")

@onready var fire_timer = $FireTimer
@onready var ray_cast_2d = $RayCast2D
@export var interval_time: float = 0.3
@export var max_shots: int = 6

var timer: float = 0

func _ready():
	if caster && caster.has_method("dash_to"):
		global_position = caster.global_position
		var player = caster.state_machine.current_state.get_closest_player()
		var player_pos = player.global_position
		var direction = caster.global_position.direction_to(player_pos)
		caster.aim_direction = direction
		ray_cast_2d.target_position = direction * 9999
		ray_cast_2d.force_raycast_update()
		
		if "attempt_anim" in caster: caster.attempt_anim("dash")
		
		caster.get_node("Sprite2D").rotation = caster.global_position.angle_to_point(ray_cast_2d.target_position)

		if is_multiplayer_authority():
			#dash(direction, ray_cast_2d.get_collision_point())
			dash.rpc(direction, ray_cast_2d.get_collision_point())
		await get_tree().process_frame
	
func _physics_process(_delta):
	if !is_instance_valid(caster):
		fire_timer.stop() 
		call_deferred("queue_free")
		return
	
	if caster && \
	caster.state_machine.current_state.name.to_lower() != "dashattack" and \
	caster.state_machine.current_state.name.to_lower() != "blinkattack":
		fire_timer.stop()
		call_deferred("queue_free")

func fire():
	if is_instance_valid(caster) && caster && \
	(caster.state_machine.current_state.name.to_lower() == "dashattack" or \
	caster.state_machine.current_state.name.to_lower() == "blinkattack"): 
		var bullet = B_BAT_FISSION.instantiate()
		bullet.global_position = caster.global_position
		transfer_data(bullet)
		add_sibling(bullet)

@rpc("authority", "call_local", "reliable")
func dash(direction, pos):
	caster.aim_direction = direction
	end_time = caster.dash_to(direction, pos)

func _on_fire_timer_timeout():
	fire()
