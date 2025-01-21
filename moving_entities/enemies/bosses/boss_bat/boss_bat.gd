extends EnemyEntity

var spawn_point:Vector2
var dash_prep_pos: Vector2
var dark_room:bool = false
var target_player: Entity
var invincible: bool = false
var canvas_modulate: PointLight2D
var players: Array[Player]

func _ready():
	super._ready()
	if get_parent().has_node("CoverLight"):
		canvas_modulate = get_parent().get_node("CoverLight")
	spawn_point = global_position

func get_players():
	var p_arr = get_tree().get_nodes_in_group("player")
	for p in p_arr:
		players.push_back(p)

func _on_zero_health():
	change_room_light(false)
	super._on_zero_health()

func change_room_light(dark_room:bool):
	var light_lvl = 1 if dark_room else 0.25
	var player_lvl = 1 if dark_room else 0.1
	var player_size = 2 if dark_room else 1
	$PointLight2D.energy = 0
	var tween = get_tree().create_tween()
	tween.tween_property(canvas_modulate, "energy", light_lvl, 2)
	for p in players:
		if is_instance_valid(p) && p.has_node("PointLight2D"):
			var light = p.get_node("PointLight2D")
			var tween0 = get_tree().create_tween()
			tween0.tween_property(light, "energy", player_lvl, 2)
			tween0.parallel().tween_property(light, "texture_scale", player_size, 2)
			
func on_hurt(attack):
	if invincible: return
	super.on_hurt(attack)
