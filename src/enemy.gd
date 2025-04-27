extends CharacterBody3D

const SPEED = 4.0
const ATTACK_RANGE = 1.8
var state_machine


@onready var player = get_tree().get_first_node_in_group("player") 
@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@onready var punch = $Character_Base/AnimationPlayer.get_animation("punch")

func _ready() -> void:
	state_machine = anim_tree.get("parameters/playback")

func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO
	
	if _target_in_range():
		punch.loop_mode = Animation.LOOP_LINEAR
	else:
		punch.loop_mode = Animation.LOOP_NONE
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	
	anim_tree.set("parameters/conditions/run", !_target_in_range())
	
	match state_machine.get_current_node():
		"walk":
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			look_at(Vector3(global_position.x + velocity.x, global_position.y, global_position.z + velocity.z), Vector3.UP)
		"punch":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	move_and_slide()

func _target_in_range() -> bool:
	return global_position.distance_to(player.global_position) < ATTACK_RANGE
