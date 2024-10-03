extends Node2D
class_name StatusParticles
#Authored by Xander. Please consult for any modifications or major feature requests.

@export var lifetime: float
@export var width: float

var parent : Entity

func _ready():
	# Delete for now.
	# queue_free()
	
	if !get_parent() is Entity:
		queue_free()
		return
	
	parent = get_parent() as Entity
	for child in get_children():
		child.process_material.emission_box_extents.x = width
		child.lifetime = lifetime
		child.emitting = false

func _process(_delta):
	var keys = parent.current_inflictions_dictionary.keys()
	$BurnParticles.emitting = SpellManager.elements["burn"] in keys
	$FrostParticles.emitting = SpellManager.elements["frost"] in keys
	$ShockParticles.emitting = SpellManager.elements["shock"] in keys
	$WindParticles.emitting = SpellManager.elements["wind"] in keys
	$WetParticles.emitting = SpellManager.elements["wet"] in keys
	$StunParticles.emitting = SpellManager.elements["stun"] in keys
