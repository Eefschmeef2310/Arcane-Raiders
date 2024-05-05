extends Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if owner.get_parent() is TileMap:
		(material as ShaderMaterial).set_shader_parameter("gradient_map", (owner.get_parent().material as ShaderMaterial).get_shader_parameter("gradient") )
		(material as ShaderMaterial).set_shader_parameter("final_saturation", (owner.get_parent().material as ShaderMaterial).get_shader_parameter("final_saturation"))
