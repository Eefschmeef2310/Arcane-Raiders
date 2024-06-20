extends Area2D
#Authored by Ethan

@export var increase_amount : int = 100

var i = 0
var amp = 10
var freq = 2

@onready var init_pos = $Shadow.scale

func _ready():
	i = randf_range(0, 360)

func _process(delta):
	i += delta
	if i > 360:
		i -= 360
	$Icon.position.y = (sin(i*freq)*amp)
	var test = 1 + sin(i*2)*0.25
	$Shadow.scale = Vector2(init_pos.x*test, init_pos.y*test)

func _on_area_entered(area):
	if is_multiplayer_authority() and area.owner.is_in_group("player") and area.owner.health < area.owner.max_health:
		area.owner.heal_damage.rpc(increase_amount)
		area.owner.add_pickup.rpc()
		queue_free()
