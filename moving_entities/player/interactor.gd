extends Node

@export var detect_interactables: bool = true
var closest_interactable: Area2D = null
var had_closest_last_frame = false
var max_distance = 100

func _physics_process(_delta):
	closest_interactable = null
	if detect_interactables:
		var all_interactables = get_tree().get_nodes_in_group("interactable")
		if all_interactables.size() > 0:
			var closest = max_distance
			for item in all_interactables:
				var dist = owner.global_position.distance_to(item.global_position)
				if dist < closest:
					closest = dist
					closest_interactable = item
		
		#if had_closest_last_frame and closest_interactable:
			#owner.data.pickup_proximity_changed.emit(false)
		#elif had_closest_last_frame and !closest_interactable:
			#owner.data.pickup_proximity_changed.emit(false)
		had_closest_last_frame = (closest_interactable != null)
