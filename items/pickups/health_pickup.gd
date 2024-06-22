extends Pickup
#Authored by Ethan. Please consult for any modifications or major feature requests.

@export var increase_amount : int = 100

#region Signal methods
func _on_area_entered(area):
	if is_multiplayer_authority() and area.owner.is_in_group("player") and area.owner.health < area.owner.max_health:
		area.owner.heal_damage.rpc(increase_amount)
		queue_free()
#endregion
