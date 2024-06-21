extends Area2D
class_name Pickup
#Authored by Ethan

enum PickupType {
	HEALTH,
	SPEED,
	COOLDOWN
}

@export var effect_type: PickupType

var i = 0
var amp = 10
var freq = 2

@onready var init_pos = $Shadow.scale
@onready var icon_init_pos = $Icon.position

func _ready():
	i = randf_range(0, 360)

func _process(delta):
	i += delta
	if i > 360:
		i -= 360
	$Icon.position.y = (sin(i*freq)*amp) + icon_init_pos.y
	var test = 1 + sin(i*2)*0.25
	$Shadow.scale = Vector2(init_pos.x*test, init_pos.y*test)

func _on_area_entered(area):
	if is_multiplayer_authority() and area.owner.is_in_group("player"):
		if effect_type == PickupType.SPEED:
			area.owner.add_speed_effect.rpc()
		elif effect_type == PickupType.COOLDOWN:
			area.owner.add_cooldown_effect.rpc()
		queue_free()
