@tool
extends CanvasItem

@onready var tiles : TileMap = get_parent().get_parent() as TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	if tiles:
		(material as ShaderMaterial).set_shader_parameter("gradient", (tiles.material as ShaderMaterial).get_shader_parameter("gradient") )
		(material as ShaderMaterial).set_shader_parameter("final_saturation", (tiles.material as ShaderMaterial).get_shader_parameter("final_saturation")) 


func _on_castle_room_tilemap_updated():
	_ready()
