extends ProjSpread

@onready var sprite_scene = preload("res://spells/scenes/aoe_local/aoe_local_sprite.tscn")

func _ready():
	super._ready()
	var spr : Node2D = sprite_scene.instantiate()
	spr.global_position = caster.global_position
	if resource.element.gradient:
		(spr.material as ShaderMaterial).set_shader_parameter("gradient", resource.element.gradient)
	add_sibling(spr)
