extends TextureRect
#class_name
#Authored by Xander. Please consult for any modifications or major feature requests.

func set_data(element: ElementResource, time_left: float):
	texture = element.pip_texture
	modulate = element.colour
	$TextureProgressBar.tint_progress = element.colour
	$TextureProgressBar.value = (time_left / element.max_infliction_time) * 100
