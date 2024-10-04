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
@export var base_damage : int = 50
@export var first_available_sector : int = 1

	#Onready Variables
@onready var animation_player = $AnimationPlayer

	#Other Variables (please try to separate and organise!)
var should_fire : bool = true

#endregion

#region Godot methods
func _ready():
	#var castle_climb : CastleClimb = owner.get_parent().get_parent()
	#if castle_climb and castle_climb.get_current_sector() < first_available_sector:
		#queue_free()
		#
	if "all_waves_cleared" in get_parent().get_parent():
		get_parent().get_parent().all_waves_cleared.connect(toggle_fire)
#endregion

#region Signal methods
func _on_area_entered(area):
	if area is ReactionArea or area is ReactionNode:
		should_fire = false
	
	if should_fire:
		if area.owner is Player and !animation_player.is_playing():
			animation_player.play("fire")

func _on_area_exited(area):
	if area is ReactionArea or area is ReactionNode:
		should_fire = true
#endregion

#region Other methods (please try to separate and organise!)
func hurt_everyone():
	if is_multiplayer_authority():
		spike_fired.rpc()

@rpc("call_local", "authority", "reliable")
func spike_fired():
	if should_fire:
		for body in get_overlapping_bodies():
			if "deal_damage" in body:
				body.deal_damage.rpc(null, base_damage, null, null, true)
			
func players_still_overlapping():
	if should_fire:
		for body in get_overlapping_areas():
			if body.owner and body.owner.is_in_group("player"):
				animation_player.play("fire")
				return
			
func toggle_fire():
	should_fire = false
#endregion
