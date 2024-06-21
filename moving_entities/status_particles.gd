extends Node2D
class_name StatusParticles
#Authored by Xander. Please consult for any modifications or major feature requests.

@export var lifetime: float
@export var width: float

var parent : Entity

func _ready():
	# Delete for now.
	queue_free()
	
	if !get_parent() is Entity:
		queue_free()
		return
	
	parent = get_parent() as Entity
	$BurnParticles.process_material.emission_box_extents.x = width

func _process(_delta):
	var keys = parent.current_inflictions_dictionary.keys()
	$BurnParticles.emitting = SpellManager.elements["burn"] in keys
