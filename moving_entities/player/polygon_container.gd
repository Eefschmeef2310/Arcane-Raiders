extends Node2D

func set_color(col: Color):
	for child in get_children():
		if child is Polygon2D:
			child.color = col
