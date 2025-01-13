extends Area2D

@export var candle_parent : Node2D

func _on_area_entered(_area):
	candle_parent.lights.clear()
	for flame in candle_parent.flames:
		if is_instance_valid(flame):
			flame.queue_free()
