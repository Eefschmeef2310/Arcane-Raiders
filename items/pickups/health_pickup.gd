extends Area2D
#Authored by Ethan

@export var increase_amount : int = 100

func _on_area_entered(area):
	if is_multiplayer_authority() and area.owner.is_in_group("player") and area.owner.health < area.owner.max_health:
		area.owner.health += increase_amount
		queue_free()
