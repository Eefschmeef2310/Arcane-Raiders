@tool
extends Sprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	(material as ShaderMaterial).set_shader_parameter("y_zoom", get_viewport().global_canvas_transform.y.y)
	
func _on_item_rect_changed():
	(material as ShaderMaterial).set_shader_parameter("scale", scale)
