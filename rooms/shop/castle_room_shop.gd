extends CastleRoom

func _ready():
	super._ready()
	
	if is_multiplayer_authority():
		for spawn_spot in $ShopSpawns.get_children():
			var random_spell_string = SpellManager.get_random_spell_string()
			var pickup = spell_pickup_spawner.spawn(random_spell_string)
			pickup.global_position = spawn_spot.global_position
