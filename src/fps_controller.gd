extends CharacterBody3D

@export var hp_max: int = 100 : set = set_hp_max
@export var hp: int = hp_max : set = set_hp

signal hp_max_changed(new_hp_max)
signal hp_changed(new_hp)
signal died

@export var look_sensitivity : float = 0.006
@export var jump_velocity := 6.0
@export var auto_bhop := true

# Ground movement settings
@export var walk_speed := 7.0
@export var sprint_speed := 8.5
@export var ground_accel := 14.0
@export var ground_decel := 10.0
@export var ground_friction := 6.0

# Air movement settings
@export var air_cap := .85
@export var air_accel := 800.0
@export var air_move_speed := 500.0

# Water movement settings
@export var swim_up_speed := 10.0

# Wall sliding fix
@export var wall_slide_threshold := 0.2

# Camera tilt modifier
@export var tilt_mod :=0.03

var wish_dir := Vector3.ZERO
var was_on_floor := false
var cam_aligned_wish_dir := Vector3.ZERO

func get_move_speed() -> float:
	return sprint_speed if Input.is_action_pressed("sprint") else walk_speed

func _ready():
	for child in %WorldModel.find_children("*", "VisualInstance3D"):
		child.set_layer_mask_value(1, false)
		child.set_layer_mask_value(2, true)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * look_sensitivity)
			%Camera3D.rotate_x(-event.relative.y * look_sensitivity)
			%Camera3D.rotation.x = clamp(%Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))
			# Reset unwanted rotations that can cause camera flipping
			%Camera3D.rotation.y = 0
			# Z rotation will be managed in _physics_process

func _physics_process(delta):
	var input_dir = Input.get_vector("left", "right", "up", "down").normalized()
	wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0., input_dir.y)
	cam_aligned_wish_dir = %Camera3D.global_transform.basis * Vector3(input_dir.x, 0., input_dir.y)

	# Check if we were on the floor last frame
	was_on_floor = is_on_floor()

	if not _handle_water_physics(delta):
		if is_on_floor():
			if Input.is_action_just_pressed("jump") or (auto_bhop and Input.is_action_pressed("jump")):
				self.velocity.y = jump_velocity
			_handle_ground_physics(delta)
		else:
			_handle_air_physics(delta)

	# Always use MOTION_MODE_GROUNDED
	self.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED

	# Apply wall sliding when hitting walls
	if is_on_wall() and !is_on_floor():
		var wall_normal = get_wall_normal()
		handle_wall_slide(wall_normal, delta)

	# Apply camera tilt based on movement direction
	#var target_tilt = 0.0
	#var tilt_multiplier = 1.0
	
	# Looking down can cause instability, so reduce tilt in that case
	#var look_down_factor = max(0.0, 1.0 - abs(%Camera3D.rotation.x) / (PI/2))
	
	#if input_dir.x > 0:
		#target_tilt = -5
	#elif input_dir.x < 0:
	#	target_tilt = 5
	
	# Reduce tilt intensity in the air to prevent flipping issues
	#if !is_on_floor():
		#tilt_multiplier = 0.7 * look_down_factor
	
	# Apply tilt with appropriate intensity
	#var effective_tilt_mod = tilt_mod * tilt_multiplier
	#$%Camera3D.rotation.z = lerp_angle($%Camera3D.rotation.z, deg_to_rad(target_tilt), effective_tilt_mod)
	
	# Clamp rotation to prevent extreme angles that can cause flipping
	#$%Camera3D.rotation.z = clamp($%Camera3D.rotation.z, deg_to_rad(-5), deg_to_rad(5))

	move_and_slide()

func handle_wall_slide(wall_normal: Vector3, delta: float) -> void:
	# Project velocity onto the wall's plane to allow sliding
	var slide_velocity = velocity - (velocity.dot(wall_normal) * wall_normal)

	# Reduce vertical velocity slightly to simulate friction against the wall
	if velocity.y < 0:
		velocity.y *= 0.9

	# Apply the slide velocity with a small reduction to prevent sticking
	velocity = slide_velocity * (1.0 - wall_slide_threshold)

func _handle_water_physics(delta) -> bool:
	if get_tree().get_nodes_in_group("water").all(func(area): return !area.overlaps_body(self)):
		return false

	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * 0.3 * delta

	self.velocity += cam_aligned_wish_dir * get_move_speed() * delta

	if Input.is_action_pressed("jump"):
		self.velocity.y += swim_up_speed * delta

	self.velocity = self.velocity.lerp(Vector3.ZERO, 1.5 * delta)

	return true

func _handle_air_physics(delta) -> void:
	self.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta

	# Source/quake like air movement recipe
	var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)
	var capped_speed = min((air_move_speed * wish_dir).length(), air_cap)
	var add_speed_till_cap = capped_speed - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = air_accel * air_move_speed * delta
		accel_speed = min(accel_speed, add_speed_till_cap)
		self.velocity += accel_speed * wish_dir

func _handle_ground_physics(delta) -> void:
	var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)
	var add_speed_till_cap = get_move_speed() - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = ground_accel * delta * get_move_speed()
		accel_speed = min(accel_speed, add_speed_till_cap)
		self.velocity += accel_speed * wish_dir

	# Apply friction
	var control = max(self.velocity.length(), ground_decel)
	var drop = control * ground_friction * delta
	var new_speed = max(self.velocity.length() - drop, 0.0)
	if self.velocity.length() > 0:
		new_speed /= self.velocity.length()
	self.velocity *= new_speed

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
	velocity += hitbox.get_knockback()
