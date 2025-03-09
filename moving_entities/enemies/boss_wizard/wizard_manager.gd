extends EnemyEntity

#array of wizards (added to when you spawn)
@export var wizard_num: int = 2

var wizards: Array

func _ready():
	super._ready()
	if is_multiplayer_authority():
		#await get_tree().create_timer(0.5).timeout
		var room: CastleRoom = get_parent() as CastleRoom
		print("Max Health:" + str(max_health))
		if room:
			for i in wizard_num:
				var wizard: Entity = room.enemy_spawner.spawn({"key": "wizard", "pos": global_position})
				wizard.wizard_hurt.connect(_update_health)
				wizard.wizard_died.connect(_remove_wizard)
				wizards.push_back(wizard)
				
				wizard.element_index = i
				if i >= 2:wizard.is_ranged = false
				else: wizard.is_ranged = true
				wizard.set_spell_element.rpc(i)
				#data.spells[i].element = SpellManager.elements["burn"]
				wizard.max_health = max_health/wizard_num
				wizard.health = wizard.max_health
				print("Wizard Health: " + str(wizard.health))
				print("Wizard Max health: " + str(wizard.max_health))
				

func _remove_wizard(dead_wizard):
	if !is_multiplayer_authority(): return
	print("A wizard has died.")
	wizards.erase(dead_wizard)
	if wizards.size() <= 0:
		set_health.rpc(0)

func _update_health():
	if !is_multiplayer_authority(): return
	var total = 0
	for wizard: Entity in wizards:
		if wizard && is_instance_valid(wizard):
			total += wizard.health
			print("Wizard Health: " + str(wizard.health))
			print("Wizard Health: " + str(wizard.max_health))
	set_health.rpc(total)
