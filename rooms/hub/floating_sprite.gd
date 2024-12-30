@tool
extends Sprite2D
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Exported Variables
@export var frequency : float = 1
@export var amplitude : float = 1

@onready var base_y = position.y
#endregion

#region Godot methods
func _process(_delta):
	position.y = base_y + amplitude * sin(Time.get_ticks_msec() * frequency)
#endregion
