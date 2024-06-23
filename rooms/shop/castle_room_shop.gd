extends CastleRoom

@export var show_stats: bool = false

func _ready():
	super._ready()
	
	if show_stats:
		var castle_climb : CastleClimb = get_parent()
		if castle_climb:
			for child in castle_climb.player_ui:
				child.show_stats_ui()
		
	var spells_remaining = max(2, number_of_players)
	var elements_remaining = SpellManager.elements_sorted
	var scenes_remaining = SpellManager.spell_scenes.keys()
	
	var element_index = rng.randi_range(0, elements_remaining.size() - 1)
	
	if is_multiplayer_authority():
		for spawn_spot in $ShopSpawns.get_children():
			if spells_remaining >= 1:
				var element = elements_remaining[element_index]
				var scene = scenes_remaining[rng.randi_range(0, scenes_remaining.size()-1)]
				scenes_remaining.erase(scene)
				
				var spell_string = element + "-" + scene
				var pickup = spell_pickup_spawner.spawn(spell_string)
				pickup.global_position = spawn_spot.global_position
				
				spells_remaining -= 1
				element_index += 1
				if element_index >= elements_remaining.size():
					element_index = 0
