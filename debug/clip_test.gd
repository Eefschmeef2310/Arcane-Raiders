@tool
extends Sprite2D

var pos : Vector2 = Vector2(-1000,-1000)

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = pos
