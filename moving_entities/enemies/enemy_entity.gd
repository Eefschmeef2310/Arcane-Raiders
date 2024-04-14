extends Entity
class_name EnemyEntity
#class_name
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
#Signals

#Enums

#Constants

@export_group("Enemy Stats")
@export var movement_speed: float = 500
@export var damage: int = 100

@export_group("Required Nodes")
@export var nav_agent: NavigationAgent2D
@export var nav_update_timer : Timer
@export var state_machine : StateMachine

var nav_server_synced = false
#endregion

#region Godot methods
func _ready():
	call_deferred("actor_setup")
	health = max_health
	nav_agent.velocity_computed.connect(_on_navigation_agent_2d_velocity_computed)
	nav_update_timer.timeout.connect(_on_nav_update_timer_timeout)

func actor_setup():
	await get_tree().physics_frame
	nav_server_synced = true
	nav_update_timer.start()
	nav_agent.max_speed = movement_speed
	state_machine.start_state_machine(nav_agent)

func _physics_process(delta):
	#move_and_slide()
	if nav_server_synced:
		if nav_agent.is_navigation_finished():
			return
		
		var current_agent_pos: Vector2 = global_position
		var next_path_pos: Vector2 = nav_agent.get_next_path_position()
		var intended_velocity = current_agent_pos.direction_to(next_path_pos) * movement_speed * frost_speed_scale
		nav_agent.set_velocity(intended_velocity)
#endregion

#region Signal methods
func _on_nav_update_timer_timeout():
	state_machine.update_position()

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()
	
func _on_hurtbox_body_entered(body):
	on_hurt(body as Node2D)

func _on_hurtbox_area_entered(area):
	on_hurt(area as Node2D)
	
func _on_zero_health():
	queue_free()
#endregion


#region Other methods (please try to separate and organise!)

#endregion
