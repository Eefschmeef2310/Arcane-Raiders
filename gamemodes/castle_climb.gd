extends Node

@export var player_data : Array[Node]
@export var start_on_spawn : bool = false

var seed : int = 6969

# Called when the node enters the scene tree for the first time.
func _ready():
	if start_on_spawn:
		print("lesgo")

func start_climb(seed: int):
	pass
