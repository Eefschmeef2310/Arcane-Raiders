extends CastleRoom

@export var boss_id: String
@export var bosses_to_kill = 3
var slimes = ["boss_slime", "fire_ice_slime", "wind_rock_slime"]

func _ready():
	super._ready()
	
	AudioManager.switch_to_boss()
	
	if is_multiplayer_authority() and boss_id != "":
		number_of_enemies_left = bosses_to_kill
		if boss_id == "random_slime":
			var key = slimes[rng.randi_range(0,slimes.size()-1)]
			var _boss = enemy_spawner.spawn({"key": key, "pos":enemy_spawns.get_child(0).global_position})
		else:
			var _boss = enemy_spawner.spawn({"key": boss_id, "pos":enemy_spawns.get_child(0).global_position})
		room_exit.lock()

func on_floor_cleared():
	all_waves_cleared.emit()
	AudioManager.switch_to_end()

func _on_boss_zero_health():
	if is_multiplayer_authority():
		bosses_to_kill -= 1
		print("Bosses left: " + str(bosses_to_kill))
		if bosses_to_kill <= 0:
			on_floor_cleared.rpc()

func _on_enemy_zero_health():
	pass
