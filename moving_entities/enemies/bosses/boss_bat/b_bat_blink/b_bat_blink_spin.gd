extends BatBlinkSpell
#class_name
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
const B_BAT_SPIN = preload("res://moving_entities/enemies/bosses/boss_bat/b_bat_spin.tscn")

@export var fire_delay: float = 2
#endregion

#region Godot methods
func _ready():
	super._ready()
	await teleport_to_center()
	await get_tree().create_timer(fire_delay, false).timeout
	if caster: 
		global_position = caster.global_position
		if "attempt_anim" in caster: 
			caster.attempt_anim("spin")
	fire()
	queue_free()
#endregion

#region Other methods (please try to separate and organise!)
func fire():
	var bullet = B_BAT_SPIN.instantiate()
	bullet.global_position = global_position
	transfer_data(bullet)
	call_deferred("add_sibling", bullet)
#endregion

