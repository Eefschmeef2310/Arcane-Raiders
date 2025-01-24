extends Hat
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants
const EXPLOSION_HAT_BURST = preload("res://hats/scenes/explosion_hat/explosion_hat_burst.tscn")

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var active_timer : Timer

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var active : bool = true

#endregion

#region Godot methods
func _ready():
	super._ready()
	player.taken_damage.connect(explode)

func _process(_delta):
	if !active:
		var explosion_cooldown = "%.1f" % active_timer.time_left
		player.data.hat_label_changed.emit(str(explosion_cooldown) + "s until explosion")
	else:
		player.data.hat_label_changed.emit("Explosion ready!")
#endregion

#region Signal methods
func _on_timer_timeout():
	active = true
	
func explode():
	if active:
		active = false
		active_timer.start(5)
		
		var burst = EXPLOSION_HAT_BURST.instantiate()
		burst.global_position = player.global_position
		burst.caster = player
		burst.deal_force = true
		player.call_deferred("add_sibling", burst)
#endregion

#region Other methods (please try to separate and organise!)

#endregion
