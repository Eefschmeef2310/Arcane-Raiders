extends CastleRoom

@export var boss_id: String
@export var bosses_to_kill = 3

func _ready():
	super._ready()
	
	if is_multiplayer_authority() and boss_id != "":
		number_of_enemies_left = bosses_to_kill
		
		var boss = enemy_spawner.spawn(boss_id, enemy_spawns.get_child(0))
		boss.zero_health.connect(_on_enemy_zero_health)
		
		room_exit.lock()
