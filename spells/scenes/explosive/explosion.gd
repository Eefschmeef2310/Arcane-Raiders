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

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var size : float = 1

var base_damage : int
var resource : Spell
var caster : Player
var cast_uuid : CastUUIDManager

#endregion

#region Godot methods
func _ready():
	scale *= size
	process_mode = Node.PROCESS_MODE_INHERIT
	
	if resource:
		modulate = resource.element.colour
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 1).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(queue_free)
#endregion

#region Signal methods
func _on_body_entered(body):
	if body != caster and "on_hurt" in body:
		body.on_hurt(self)

func _on_area_entered(area):
	if area != caster and "on_hurt" in area:
		area.on_hurt(self)
#endregion

#region Other methods (please try to separate and organise!)

#endregion
