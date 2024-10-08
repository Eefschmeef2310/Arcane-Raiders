extends Area2D
class_name RoomExit

signal player_entered(player: Player)

@export var wait_for_all_players := false
@export var is_locked := false
@export var locked_texture : Texture2D
@export var unlocked_texture : Texture2D
@export var destroy_if_online : bool = false

@onready var sprite = $Sprite2D
@onready var collision = $CollisionPolygon2D

var entered_players : Array[Player]
var number_of_players : int

func _ready():
	if is_locked:
		lock()
		
	if GameManager.isOnline() and destroy_if_online:
		queue_free()

func _process(_delta):
	var cam = get_viewport().get_camera_2d()
	$LabelSize.scale = Vector2(1,1) / cam.zoom
	if !is_locked:
		number_of_players = max(get_tree().get_nodes_in_group("player").size(), get_tree().get_nodes_in_group("hub_select").size())
	$LabelSize/Label.text = "Players ready: " + str(entered_players.size()) + "/" + str(number_of_players)

func lock():
	is_locked = true
	sprite.texture = locked_texture
	collision.set_deferred("disabled", true)

func unlock():
	is_locked = false
	sprite.texture = unlocked_texture
	collision.set_deferred("disabled", false)

func _on_body_entered(body):
	if body is Player:
		print("Player entered.")
		
		if !body in entered_players:
			entered_players.append(body)
			
		var all_players = max(get_tree().get_nodes_in_group("player").size(), get_tree().get_nodes_in_group("hub_select").size())
		if !wait_for_all_players or entered_players.size() >= all_players:
			player_entered.emit(body)
		
		if wait_for_all_players:
			$LabelSize/Label.show()


func _on_body_exited(body):
	if body is Player:
		print("Player exited.")
		
		if body in entered_players:
			entered_players.erase(body)
		
		if wait_for_all_players:
			$LabelSize/Label.visible = entered_players.size() > 0
