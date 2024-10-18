extends Node2D
#Authored by Ethan. Please consult for any modifications or major feature requests.

@export var flames : Array[Sprite2D]
@export var lights : Array[PointLight2D]

@export var min_energy : float = 0.4
@export var max_energy : float = 0.5

#region Godot methods
func _ready():
	var noise = NoiseTexture2D.new()
	noise.noise = FastNoiseLite.new()
	noise.seamless = true
	noise.noise.seed = randi_range(0,100)
	
	for flame in flames:
		(flame.material as ShaderMaterial).set_shader_parameter("noise_tex", noise)

func _process(_delta):
	for light in lights:
		light.energy = randf_range(min_energy, max_energy)
#endregion
