extends CharacterBody3D

const SPEED = 4.0
const ATTACK_RANGE = 1.8
const KNOCKBACK = 8.0
var state_machine
var stored_knockback: Vector3 = Vector3.ZERO

@export var hp_max: int = 100 : set = set_hp_max 
@export var hp: int = hp_max : set = set_hp 

signal hp_max_changed(new_hp_max) 
signal hp_changed(new_hp)
signal died

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
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED + stored_knockback
			stored_knockback *= 0.8
			look_at(Vector3(global_position.x + velocity.x, global_position.y, global_position.z + velocity.z), Vector3.UP)
			# I could use lerp to make turning smoother but I'm not gonna bother right now
		"punch":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			velocity += stored_knockback
			stored_knockback *= 0.8
	move_and_slide()

func _target_in_range() -> bool:
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func get_knockback():
	var knockback = global_position.direction_to(player.global_position) * KNOCKBACK
	return knockback

func set_hp_max(value):
	if value != hp_max:
		hp_max = max(1, value)
		emit_signal("hp_max_changed", hp_max)
		self.hp = hp

func set_hp(value):
	if value != hp:
		hp = clamp(value, 0, hp_max)
		emit_signal("hp_changed", hp) #emit signal 
		if hp == 0:
			emit_signal("died")

func receive_damage(damage_taken):
	self.hp -= damage_taken #use self.hp so that set_hp() gets called automatically when we adjust it

func die():
	queue_free()

func _on_hurtbox_area_entered(hitbox: Area3D) -> void:
	#receive_damage(hitbox.damage)
	print("I have been hurt!")
	stored_knockback += hitbox.get_knockback()

func _on_head_hurtbox_area_entered(hitbox: Area3D) -> void:
	#receive_damage(hitbox.damage * 2)
	print("I have been headshot!")
	stored_knockback += hitbox.get_knockback()
