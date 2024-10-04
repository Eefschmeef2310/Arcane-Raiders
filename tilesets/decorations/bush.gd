extends Sprite2D

func _ready():
	(material as ShaderMaterial).set_shader_parameter("offset", randi_range(0,100))
