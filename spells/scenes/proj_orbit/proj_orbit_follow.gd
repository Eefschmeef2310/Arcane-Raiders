extends PathFollow2D
class_name ProjOrbitFollow



@export var orbit_time : float = 1

func _process(delta):
	progress_ratio += orbit_time * delta
