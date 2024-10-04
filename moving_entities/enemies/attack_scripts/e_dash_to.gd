extends SpellBase
class_name DashToEnemy

func _ready():
	if !caster: queue_free()
	
	if get_parent():
		get_parent().remove_child(self)
		caster.add_child(self)
		
	global_position = caster.global_position
	if caster.has_method("dash_to"):
		caster.dash_to(caster.aim_direction, caster.target_area)


func _process(delta):
	if !caster: queue_free()
	if !caster.is_dashing:
		queue_free()
