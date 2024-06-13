extends Node2D

@export var starting_t : float
@export var amplitude : float = 16
@export var frequency : float = 1

var base_y : float
var t : float

func _ready():
	base_y = rotation_degrees
	t = starting_t

func _process(delta):
	rotation_degrees = base_y - (sin(t * frequency) * amplitude)
	t += delta
	if t >= 360:
		t -= 360
