extends CastleRoom

@export var boss_id: String
@export var bosses_to_kill = 3

func _ready():
	super._ready()
	
	AudioManager.switch_to_boss()
	
	if is_multiplayer_authority() and boss_id != "":
		number_of_enemies_left = bosses_to_kill
		var boss = enemy_spawner.spawn({"key": boss_id, "pos":enemy_spawns.get_child(0).global_position})
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
