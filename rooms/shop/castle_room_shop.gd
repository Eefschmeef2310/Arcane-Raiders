extends CastleRoom

func _ready():
	super._ready()
	
	var spells_remaining = min(2, number_of_players)
	var elements_remaining = SpellManager.elements.keys()
	var scenes_remaining = SpellManager.spell_scenes.keys()
	
	if is_multiplayer_authority():
		for spawn_spot in $ShopSpawns.get_children():
			if spells_remaining >= 1:
				var element = elements_remaining.pick_random()
				elements_remaining.erase(element)
				
				var scene = scenes_remaining.pick_random()
				scenes_remaining.erase(scene)
				
				var spell_string = element + "-" + scene
				var pickup = spell_pickup_spawner.spawn(spell_string)
				pickup.global_position = spawn_spot.global_position
				spells_remaining -= 1
