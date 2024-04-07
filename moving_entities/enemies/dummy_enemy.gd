extends Entity
#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

@export var movement_speed: float = 100
@export var damage : int = 10

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
var nav_server_synced = false

#region Godot methods
func _ready():
	call_deferred("actor_setup")

func actor_setup():
	await get_tree().physics_frame
	nav_server_synced = true
	$NavUpdateTimer.start()
	set_target()

func set_target() -> bool:
	var p = get_tree().get_first_node_in_group("player")
	if p is Player:
		nav_agent.target_position = p.global_position
		return true
	return false

func _process(delta):
	super._process(delta)
		
func _physics_process(_delta):
	if nav_server_synced:
		#set_target()
		
		if !is_multiplayer_authority() or nav_agent.is_navigation_finished():
			return
		
		var current_agent_pos: Vector2 = global_position
		var next_path_pos: Vector2 = nav_agent.get_next_path_position()
		
		var intended_velocity = current_agent_pos.direction_to(next_path_pos) * movement_speed * frost_speed_scale
		nav_agent.set_velocity(intended_velocity)
	
	
#endregion

#region Signal methods
func _on_hurtbox_body_entered(body):
	on_hurt(body as Node2D)

func _on_hurtbox_area_entered(area):
	on_hurt(area as Node2D)

func _on_nav_update_timer_timeout():
	set_target()
	pass

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	if is_multiplayer_authority():
		velocity = safe_velocity
		move_and_slide()

func _on_zero_health():
	queue_free()
#endregion
