extends Node2D
class_name CastleRoom
#Authored by Xander. Please consult for any modifications or major feature requests.

@onready var dynamic_camera: DynamicCamera = $DynamicCamera
@onready var PLAYER_SCENE = preload("res://moving_entities/player/player.tscn")

func spawn_players(player_data: Array[PlayerData], number_of_players: int):
	var spawn_points = get_tree().get_nodes_in_group("player_spawn")
	for i in number_of_players:
		if i < player_data.size():
			var player: Player = PLAYER_SCENE.instantiate()
			player.set_data(player_data[i])
			player.global_position = spawn_points[0].global_position
			dynamic_camera.add_target(player)
			add_child(player)
