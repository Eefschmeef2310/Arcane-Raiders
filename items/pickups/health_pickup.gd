extends Area2D
#Authored by Ethan

@export var increase_amount : int = 100

func _on_area_entered(area):
	if area.owner.is_in_group("player") and area.owner.data.health < area.owner.data.max_health:
		area.owner.data._on_player_health_updated(area.owner.data.health + increase_amount)
		queue_free()
