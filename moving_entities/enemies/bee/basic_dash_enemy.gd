extends SpellBase
class_name BasicDashEnemy

@export var duration: float = 0.3

func _ready():
	if !caster: queue_free()
	
	if get_parent():
		get_parent().remove_child(self)
		caster.add_child(self)
		
	global_position = caster.global_position
	
	if caster.has_method("dash"):
		caster.dash(caster.aim_direction, duration)


func _process(_delta):
	if !caster: queue_free()
	
	if "is_dashing" in caster:
		if !caster.is_dashing:
			queue_free()
