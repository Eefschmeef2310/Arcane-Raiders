extends Node2D
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Godot methods
func _ready():
	var noise = NoiseTexture2D.new()
	noise.noise = FastNoiseLite.new()
	noise.seamless = true
	noise.noise.seed = randi_range(0,100)
	($Flame.material as ShaderMaterial).set_shader_parameter("noise_tex", noise)

func _process(_delta):
	$PointLight2D.energy = randf_range(0.4, 0.5)
#endregion
