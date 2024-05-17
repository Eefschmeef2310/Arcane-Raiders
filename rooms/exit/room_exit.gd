extends Area2D
class_name RoomExit

signal player_entered(player: Player)

@export var is_locked := false
@export var locked_texture : Texture2D
@export var unlocked_texture : Texture2D
@onready var sprite = $Sprite2D
@onready var collision = $CollisionPolygon2D

func _ready():
	if is_locked:
		lock()

func lock():
	is_locked = true
	sprite.texture = locked_texture
	collision.set_deferred("disabled", true)

func unlock():
	is_locked = false
	sprite.texture = unlocked_texture
	collision.set_deferred("disabled", false)

func _on_body_entered(body):
	print("Player detected. Telling room...")
	player_entered.emit(body)
