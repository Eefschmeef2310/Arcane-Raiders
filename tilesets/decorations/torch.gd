extends Node2D
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

#endregion

#region Godot methods
func _ready():
	var noise = NoiseTexture2D.new()
	noise.noise = FastNoiseLite.new()
	noise.seamless = true
	noise.noise.seed = randi_range(0,100)
	(material as ShaderMaterial).set_shader_parameter("noise_tex", noise)
	
	if get_parent() is TileMap:
		(material as ShaderMaterial).set_shader_parameter("gradient_map", (get_parent().material as ShaderMaterial).get_shader_parameter("gradient") )
		(material as ShaderMaterial).set_shader_parameter("final_saturation", (get_parent().material as ShaderMaterial).get_shader_parameter("final_saturation"))

func _process(_delta):
	$PointLight2D.energy = randf_range(0.4, 0.5)
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion
