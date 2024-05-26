extends Sprite2D

@export var starting_t : float
@export var amplitude : float = 16
@export var frequency : float = 1

var base_y : float
var t : float

func _ready():
	base_y = position.y
	t = starting_t
	position.y = base_y - (abs(sin(t * frequency)) * amplitude)

func _process(delta):
	position.y = base_y - (abs(sin(t * frequency)) * amplitude)
	t += delta
	if t >= 360:
		t -= 360
