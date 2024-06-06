extends Area2D
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var trap_damage : int = 50

	#Onready Variables
@onready var animation_player = $AnimationPlayer

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
#endregion

#region Signal methods
func _on_body_entered(body):
	if body is Entity and !animation_player.is_playing():
		animation_player.play("fire")
#endregion

#region Other methods (please try to separate and organise!)
func hurt_everyone():
	if is_multiplayer_authority():
		spike_fired.rpc()

@rpc("call_local", "authority", "reliable")
func spike_fired():
	for body in get_overlapping_bodies():
		if "deal_damage" in body:
			body.deal_damage.rpc(null, trap_damage, null, null, true)
#endregion


