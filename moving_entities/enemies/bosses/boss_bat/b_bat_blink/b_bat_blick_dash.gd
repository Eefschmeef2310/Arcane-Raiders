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
	call_deferred("queue_free")

#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion

