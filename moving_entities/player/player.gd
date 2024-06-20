extends Entity
class_name Player
#Authored by Xander. Please consult for any modifications or major feature requests.

signal spell_pickup_requested(Player, int, SpellPickup)
signal dead(Player)
signal revived(Player)

@export var debug : bool = false
@export var data: PlayerData

@export_group("Parameters")
@export var movement_speed : float = 300

#@onready var animation_player = $"Animation Players/AnimationPlayer"
#@onready var dash_ray = $DashRay

@onready var player_notif_scene = preload("res://moving_entities/player/player_notif.tscn")

# Normalised vectors
@export var move_direction: Vector2
@export var aim_direction: Vector2

#stats
#@onready var crown = $SpritesFlip/SpritesScale/HeadGroup/Crown



var preparing_cast_slot := -1
var is_casting := false
var can_cast := true
var cast_end_time : float

var is_invincible = false;

var is_dashing: bool = false
var dash_cooldown: float = 0.0
var dash_cooldown_max: float = 1.0
var dash_direction: Vector2
var dash_speed = 1200
var dash_duration = 0.24 # Is only used for checking if a dash will end in a wall

var friends_nearby : Array = []
@export var revival_time : float
var revival_time_max : float = 5

@export_group("Node References")
@export var revival_meter : ProgressBar
@export var hurtbox : Area2D
@export var help_label : Label
@export var collision_shape : CollisionShape2D
@export var input_node : Node
@export var invincibility_timer : Timer

@export_subgroup("Spells")
@export var notif_spawn_pos : Node2D
@export var spell_pickup_detector_node : Node
@export var prepare_cast_label : Label
@export var can_cast_label : Label
@export var spell_sprite_2d_projection : Sprite2D
@export var spell_sprite_2d : Sprite2D

@export_subgroup("Dash")
@export var dash_ray : RayCast2D
@export var dash_bar : ProgressBar
@export var dash_sound_player : AudioStreamPlayer2D

@export_subgroup("Animations")
@export var animation_player : AnimationPlayer
@export var invincibility_animation : AnimationPlayer
@export var flashing_animation : AnimationPlayer

@export_subgroup("Player Sprite Components")
@export var sprites_flip : Node2D
@export var sprites_scale : Node2D
@export var body_sprite : Sprite2D
@export var head_sprite : Sprite2D
@export var right_hand_sprite : Sprite2D
@export var left_hand_sprite : Sprite2D
@export var crown : Node2D


#region Godot methods
func _ready():
	aim_direction = Vector2(1,1)
	animation_player.play("idle", -1, 1)
	animation_player.seek(randf_range(0,2))
	revival_meter.max_value = revival_time_max
	
	killed_entity.connect(_on_killed_entity);
	dealt_damage.connect(_on_dealt_damage)
	
	# TODO temporary lines here
	if debug:
		set_data(data, false)

func _process(delta):
	super._process(delta)
	if is_instance_valid(data):
		if get_multiplayer_authority() == data.peer_id:
			if is_dead:
				velocity = Vector2.ZERO
			elif is_dashing:
				var dash_spd = dash_speed
				if frost_speed_scale < 1:
					dash_spd *= 0.5 
				velocity = dash_direction * dash_spd
			else:
				velocity = get_knockback_velocity() + get_attraction_velocity()
				if can_input:
					var input_velocity = move_direction * movement_speed * frost_speed_scale
					if is_casting or preparing_cast_slot >= 0:
						input_velocity *= 0.25
					velocity += input_velocity
					
			move_and_slide()
	
	# Dashing and invincibility
	if dash_cooldown > 0:
		dash_cooldown -= delta
		dash_bar.value = dash_cooldown
	
	var overlay_col = Color.WHITE
	if data and is_dashing:
		overlay_col.a = 0.5
	else:
		overlay_col.a = 0
	set_sprite_overlay(overlay_col)
	
	hurtbox.monitoring = !(is_invincible or is_dashing)
	
	if !is_dead and !is_dashing:
		if aim_direction.x < 0:
			sprites_flip.scale.x = -1
		else:
			sprites_flip.scale.x = 1
		
		if !is_casting and preparing_cast_slot < 0:
			if move_direction != Vector2.ZERO:
				animation_player.play("move", -1, 1)
			else:
				animation_player.play("idle", -1, 1)
	
	spell_sprite_2d_projection.visible = (preparing_cast_slot >= 0 and !is_near_pickup())
	
	# Death logic
	if is_dead:
		help_label.show()
		revival_meter.show()
		revival_meter.value = revival_time
		
		# Remove people who died next to you
		for friend in get_tree().get_nodes_in_group("player"):
			if friend in friends_nearby and friend.is_dead:
				friends_nearby.erase(friend)

		if is_multiplayer_authority():
			var number_of_friends = friends_nearby.size()
			if number_of_friends > 0:
				revival_time += delta * (1 + (0.25 * (number_of_friends - 1)))
				if revival_time >= revival_time_max:
					health = 250
			else:
				revival_time -= delta
				if revival_time <= 0:
					revival_time = 0
			
			if health > 0:
				toggle_dead.rpc(false);
	else:
		help_label.hide()
		revival_meter.hide()
		
	
	if debug:
		prepare_cast_label.text = str(preparing_cast_slot)
		can_cast_label.text = str(can_cast)
	
	crown.visible = data.has_crown
#endregion

#region Signal methods
func _on_animation_player_animation_finished(anim_name: String):
	if anim_name.contains("cast_end"):
		animation_player.play("idle", -1, 1)
		is_casting = false
	elif anim_name.contains("dash"):
		animation_player.play("idle", -1, 1)
		is_dashing = false
		collision_shape.disabled = false
#endregion

#region Other methods (please try to separate and organise!)
func set_data(new_data: PlayerData, destroy_old := true):
	if destroy_old:
		data.queue_free()
	data = new_data
	
	health = data.health
	if !health_updated.is_connected(data._on_player_health_updated): health_updated.connect(data._on_player_health_updated)
	if !data.spell_ready.is_connected(_on_spell_ready): data.spell_ready.connect(_on_spell_ready)
	
	set_input(data.device_id)
	spell_sprite_2d.modulate = data.main_color
	spell_sprite_2d_projection.modulate = data.main_color
	spell_sprite_2d_projection.modulate.a = 0.5
	body_sprite.self_modulate = data.main_color
	help_label.add_theme_color_override("font_color", data.main_color)
	
	if data.character:
		#print(data.character.raider_name)
		head_sprite.texture = data.character.head_texture
		right_hand_sprite.self_modulate = data.character.skin_color
		left_hand_sprite.self_modulate = data.character.skin_color
	
	call_deferred("set_multiplayer_authority", data.peer_id, true)

func set_input(id: int):
	#print("Setting input" + str(id))
	input_node.set_device(id)

func set_sprite_overlay(c: Color):
	for sprite in sprites_scale.get_children(): 
		if "color" in sprite.get_child(0):
			sprite.get_child(0).color = c

func attempt_dash():
	if !is_casting and dash_cooldown <= 0:
		start_dash.rpc(aim_direction if move_direction == Vector2.ZERO else move_direction)
		
@rpc("authority", "call_local", "reliable")
func start_dash(dir: Vector2):
	#print("dash!")
	dash_sound_player.play()
	if dir == Vector2.ZERO:
		dir = Vector2(1, 0)
	dash_cooldown = dash_cooldown_max
	dash_direction = dir
	is_dashing = true
	animation_player.play("dash")
	
	var dash_spd = dash_speed
	if frost_speed_scale < 1:
		dash_spd *= 0.5 
	
	# Check if we're going to end in a wall or not.
	# Raycast with unwalkables:
	dash_ray.target_position = (dir.normalized() * dash_spd * dash_duration)
	dash_ray.force_raycast_update()
	if !dash_ray.is_colliding():
		# Point check for walkable floor:
		var pp = PhysicsPointQueryParameters2D.new()
		pp.collision_mask = collision_mask
		pp.position = global_position + (dir.normalized() * dash_spd * dash_duration)
		if !get_world_2d().direct_space_state.intersect_point(pp, 1):
			# Disable collision and allow passthrough colliders.
			collision_shape.disabled = true

func prepare_cast_down(slot: int):
	if data.spell_cooldowns[slot] > 0:
		
		data.spell_casted_but_not_ready.emit(slot)
		
		#var notif: PlayerNotif = player_notif_scene.instantiate()
		#add_child(notif)
		#notif.position = $NotifSpawnPos.position
		#notif.set_recharging(data.spell_cooldowns[slot])
		#notif.start_tween()
	

func prepare_cast(slot: int):
	if can_cast and data.spell_strings[slot] != "" and !is_dashing and preparing_cast_slot < 0 and data.spell_cooldowns[slot] <= 0 and !is_near_pickup():
		preparing_cast_slot = slot
		spell_sprite_2d_projection.texture = data.spells[slot].projection_texture
		animation_player.stop()
		animation_player.play("cast_start")

# Splitting the functions to separate input from action for RPC
func attempt_cast(slot: int):
	if can_cast and !is_dashing and data.spell_cooldowns[slot] <= 0 and !is_near_pickup():
		cast_spell.rpc(slot)
	preparing_cast_slot = -1

@rpc("authority", "call_local", "reliable")
func cast_spell(slot: int):
	if slot < data.spells.size() and data.spells[slot]:
		var cooldown_time
		var end_time
		var cancel_time
		
		if data.spells[slot] is CombinedSpell:
			var spell_node0 = data.spells[slot].spells[0].scene.instantiate()
			spell_node0.resource = data.spells[slot].spells[0]
			spell_node0.caster = self
			spell_node0.set_multiplayer_authority(get_multiplayer_authority(), true)
			add_sibling(spell_node0)
			
			var spell_node1 = data.spells[slot].spells[1].scene.instantiate()
			spell_node1.resource = data.spells[slot].spells[1]
			spell_node1.caster = self
			spell_node1.set_multiplayer_authority(get_multiplayer_authority(), true)
			add_sibling(spell_node1)
			
			if spell_node0.resource == spell_node1.resource:
				spell_node0.combined_spell_index = 0
				spell_node1.combined_spell_index = 1
			
			cooldown_time = (spell_node0.cooldown_time + spell_node1.cooldown_time)/2
			end_time = (spell_node0.end_time + spell_node1.end_time)/2
			cancel_time = (spell_node0.cancel_time + spell_node1.cancel_time)/2
			
		else:
			# Initialise spell object and add to tree
			var spell_node = data.spells[slot].scene.instantiate()
			spell_node.resource = data.spells[slot]
			spell_node.caster = self
			spell_node.set_multiplayer_authority(get_multiplayer_authority(), true)
			add_sibling(spell_node)
			
			cooldown_time = spell_node.cooldown_time
			end_time = spell_node.end_time
			cancel_time = spell_node.cancel_time
		
		# Set cooldown
		data.spell_cooldowns_max[slot] = cooldown_time
		data.spell_cooldowns[slot] = cooldown_time
		
		# Set own animation properties
		is_casting = true
		can_cast = false
		cast_end_time = end_time
		animation_player.play("cast_end", -1, 1/end_time)
		
		# Allow us to cast a spell again in a certain amount of time
		# (only the authority uses this though)
		await get_tree().create_timer(cancel_time).timeout
		can_cast = true

func on_hurt(attack):
	if is_invincible or is_dashing or is_dead:
		return
		
	super.on_hurt(attack)
	
	if is_multiplayer_authority():
		if !is_dead and !("base_damage" in attack and attack.base_damage <= 0):
			start_invincibility.rpc()

@rpc("authority", "call_local", "reliable")
func deal_damage(attack_path, damage, element_string, infliction_time, create_new):
	var not_dead_yet = !is_dead
	
	if is_dead:
		return
	
	super.deal_damage(attack_path, damage, element_string, infliction_time, create_new)

	if is_multiplayer_authority():
		if is_dead and not_dead_yet:
			toggle_dead.rpc(true)

@rpc("authority", "call_local", "reliable")
func toggle_dead(b):
	if b: 
		animation_player.play("die");
		collision_shape.set_deferred("disabled", true);
		revival_time = 0
		remove_from_group("player")
		dead.emit(self)
	else:
		is_dead = false
		collision_shape.disabled = false;
		revival_time = 0
		add_to_group("player")
		start_invincibility()
		animation_player.play("idle")
		is_dashing = false
		is_casting = false
		preparing_cast_slot = -1
		health = 250
		health_updated.emit(health)
		revived.emit(self)
		
		var revive_effect = load("res://moving_entities/player/revive_effect.tscn").instantiate()
		revive_effect.global_position = global_position
		add_sibling(revive_effect)

@rpc("authority", "call_local", "reliable")
func start_invincibility():
	is_invincible = true
	invincibility_animation.play("flashing")
	invincibility_timer.stop()
	invincibility_timer.start()

#endregion

func _on_invincibility_timer_timeout():
	is_invincible = false
	invincibility_animation.play("RESET")
	invincibility_timer.stop()

func is_near_pickup():
	return spell_pickup_detector_node.closest_pickup != null


func _on_revival_zone_body_entered(body):
	if body != self and body is Player and !body.is_dead and !body in friends_nearby:
		friends_nearby.append(body)


func _on_revival_zone_body_exited(body):
	if body != self and body is Player and body in friends_nearby:
		friends_nearby.erase(body)


func _on_dash_trail_timer_timeout():
	if is_dashing:
		var after_image : Node2D = Node2D.new()
		after_image.y_sort_enabled = true
		after_image.global_position = global_position
		after_image.modulate = data.main_color
		after_image.modulate.a = 0.5
		add_sibling(after_image)
		
		var sprites = sprites_flip.duplicate()
		after_image.add_child(sprites)
		
		await get_tree().create_timer(0.1).timeout
		
		after_image.queue_free()

func _on_health_updated(_health):
	if health <= 250:
		flashing_animation.play("low_health_flash")
	else:
		flashing_animation.stop(false)

func _on_killed_entity(entity: Entity):
	if is_multiplayer_authority() and data:
		#data.money += entity.monetary_value;
		#data.total_money += entity.monetary_value
		#data.kills += 1
		add_kill.rpc(entity.monetary_value)
		print(data.money)

func _on_dealt_damage(_entity: Entity, damage : int):
	if is_multiplayer_authority() and data:
		#sdata.damage += damage 
		add_damage.rpc(damage)
	pass

@rpc("any_peer", "call_local", "reliable")
func add_damage(damage : int):
	data.damage += damage 

@rpc("any_peer", "call_local", "reliable")
func add_kill(value : int):
	data.money += value
	data.total_money += value
	data.kills += 1

@rpc("any_peer", "call_local", "reliable")
func add_pickup():
	data.pickups_obtained += 1
	
@rpc("any_peer", "call_local", "reliable")
func add_reaction():
	data.reactions_created += 1  

func _on_spell_ready(slot: int):
	var notif: PlayerNotif = player_notif_scene.instantiate()
	add_child(notif)
	notif.position = notif_spawn_pos.position
	notif.set_spell_ready(data.spells[slot])
	notif.start_tween()
