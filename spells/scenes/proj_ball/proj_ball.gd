extends SpellBase
#class_name
#Authored by Xander. Please consult for any modifications or major feature requests.

@onready var body = preload("res://spells/scenes/proj_ball/proj_ball_body.tscn")

#region Godot methods
func _ready():
	#await get_tree().create_timer(start_time).timeout
	var ball = body.instantiate()
	transfer_data(ball)
	add_sibling(ball)
	queue_free()
	
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion
