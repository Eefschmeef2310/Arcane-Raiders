extends Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var noise = NoiseTexture2D.new()
	noise.noise = FastNoiseLite.new()
	noise.seamless = true
	noise.noise.seed = randi_range(0,100)
	(material as ShaderMaterial).set_shader_parameter("noise_tex", noise)
	
	if owner.get_parent() is TileMap:
		(material as ShaderMaterial).set_shader_parameter("gradient_map", (owner.get_parent().material as ShaderMaterial).get_shader_parameter("gradient") )
		(material as ShaderMaterial).set_shader_parameter("final_saturation", (owner.get_parent().material as ShaderMaterial).get_shader_parameter("final_saturation"))
