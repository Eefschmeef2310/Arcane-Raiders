extends SpellBase
#class_name
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var size: float = 4
@export var delay: float = 1
	#Onready Variables

var path = ""

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _ready():
	scale *= 0.5
	var tween = get_tree().create_tween()
	if(caster): 
		global_position = caster.global_position
		path = get_path_to(caster)
		
	
	tween.tween_property(self, "scale", Vector2(size, size), end_time - delay)
	tween.tween_interval(delay)
	tween.tween_callback(explode)
	tween.tween_callback(queue_free)
	pass

func _process(delta):
	#Hopefully this code doesn't break anything need to test
	if(!has_node(path) && resource): queue_free()
	$Ring/Sprite2D.rotation -= delta
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func explode():
	#will probably instantiate the explosion here instead but this works for now
	for moving_entity in $ExplosionArea.get_overlapping_bodies():
		if moving_entity.is_in_group("player") and moving_entity != caster:
			moving_entity.on_hurt(self)
#endregion

