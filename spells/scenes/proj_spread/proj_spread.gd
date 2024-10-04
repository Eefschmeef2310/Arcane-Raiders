extends SpellBase
class_name ProjSpread
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var EXPLOSION = preload("res://spells/scenes/proj_burst/proj_burst_explosion.tscn")
@export var waves : int = 10
@export var explosions_per_wave : int = 5
@export_range(0, TAU) var max_radians : float = 0.2

@export var distance_from_caster : float = 40

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _ready():
	global_position = caster.global_position + (caster.aim_direction * distance_from_caster) + Vector2(0,-16)
	# await get_tree().create_timer(start_time).timeout
	_on_wave_timer_timeout()
#endregion

func _process(_delta):
	#if caster : global_position = caster.global_position
	global_position = caster.global_position + (caster.aim_direction * distance_from_caster) + Vector2(0,-16)

#region Signal methods
func _on_wave_timer_timeout():
	if waves > 0:
		#spawn
		var angle_step = max_radians / (explosions_per_wave - 1)
		
		for x in explosions_per_wave:
			var explosion = EXPLOSION.instantiate()
			transfer_data(explosion)
			
			var rotation_offset = angle_step * x - max_radians / 2
			explosion.rotation = (caster.aim_direction.angle() if caster else 0.) + rotation_offset
			
			explosion.global_position = global_position
			call_deferred("add_sibling", explosion)
		waves -= 1
		$WaveTimer.start(0.05)
	else:
		queue_free()
#endregion

#region Other methods (please try to separate and organise!)

#endregion
