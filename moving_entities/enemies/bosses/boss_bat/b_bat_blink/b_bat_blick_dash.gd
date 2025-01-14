extends BatBlinkSpell

const B_BAT_DASH_ATTACK = preload("res://moving_entities/enemies/bosses/boss_bat/b_bat_dash/b_bat_dash_attack.tscn")
@onready var ray_cast_2d = $RayCast2D

func _ready():
	super._ready()
	if "attempt_anim" in caster: caster.attempt_anim("windup")
	await teleport_to_random_side()
	var attack = B_BAT_DASH_ATTACK.instantiate()
	transfer_data(attack)
	add_sibling(attack)
	attack.global_position = global_position
	
	if caster && caster.has_method("dash_to"):
		var player = caster.state_machine.current_state.get_closest_player()
		var player_pos = player.global_position
		var direction = caster.global_position.direction_to(player_pos)
		caster.aim_direction = direction
		ray_cast_2d.target_position = direction * 9999
		ray_cast_2d.force_raycast_update()
		if "attempt_anim" in caster: caster.attempt_anim("dash")
		caster.get_node("Sprite2D").rotation = caster.global_position.angle_to_point(ray_cast_2d.target_position)
		if is_multiplayer_authority():
			dash.rpc(direction, ray_cast_2d.get_collision_point())
		if "dash_calculated" in attack: attack.dash_calculated = true
	call_deferred("queue_free")

#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
@rpc("authority", "call_local", "reliable")
func dash(direction, pos):
	caster.aim_direction = direction
	end_time = caster.dash_to(direction, pos)
#endregion

