extends SpellBase
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var BULLET = preload("res://spells/scenes/proj_spread/bullet.tscn")
@export var waves : int = 10
@export var bullets_per_wave : int = 5
@export_range(0, TAU) var max_radians : float = 0.2

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _ready():
	await get_tree().create_timer(start_time).timeout
	_on_wave_timer_timeout()
#endregion

#region Signal methods
func _on_wave_timer_timeout():
	if waves > 0:
		#spawn
		var angle_step = max_radians / (bullets_per_wave - 1)
		
		for x in bullets_per_wave:
			var bullet = BULLET.instantiate()
			transfer_data(bullet)
			
			var rotation_offset = angle_step * x - max_radians / 2
			bullet.rotation = caster.aim_direction.angle() + rotation_offset
			
			bullet.global_position = caster.global_position
			get_tree().root.add_child(bullet)
		waves -= 1
		$WaveTimer.start(0.05)
	else:
		queue_free()
#endregion

#region Other methods (please try to separate and organise!)

#endregion
