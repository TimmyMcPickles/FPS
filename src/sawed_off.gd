extends Node3D

@export var active: bool = false
@export var heldByPlayer: bool = false

@onready var pelletspawn = $pelletspawn
@onready var anim = $AnimationPlayer
@onready var player = get_tree().get_first_node_in_group("player")

var max_ammo: int = 99
var ammo: int = max_ammo: set = set_ammo
var max_loaded: int = 2
var loaded: int = 2: set = set_loaded

var KICK = 10

var bullet = load("res://scenes/bullet_glock.tscn")
var pellet1
var pellet2
var pellet3
var pellet4
var pellet5
var pellet6
var pellet7
var pellet8
var pellet9

func set_ammo(value: int):
	if value != ammo:
		ammo = clamp(value, 0, max_ammo)

func set_loaded(value: int):
	if value != loaded:
		loaded = clamp(value, 0, max_loaded)

func _physics_process(delta: float) -> void:
	if active == true:
		if Input.is_action_pressed("shoot"):
			if loaded > 0:
				shoot()
			elif ammo > 0:
				reload()
			else:
				print("click")

func shoot():
	if !anim.is_playing() and loaded > 0:
		anim.play("Shoot")
		knockback()
		self.loaded -= 1
		print(loaded, " shells loaded")
		
		pellet1 = bullet.instantiate()
		pellet1.position = pelletspawn.global_position
		pellet1.transform.basis = pelletspawn.global_transform.basis
		get_tree().root.add_child(pellet1)
		
		pellet2 = bullet.instantiate()
		pellet2.position = pelletspawn.global_position
		pellet2.transform.basis = pelletspawn.global_transform.basis
		pellet2.rotation.x += randf_range(-0.05, 0.05)
		pellet2.rotation.y += randf_range(-0.05, 0.05)
		get_tree().root.add_child(pellet2)
		
		pellet3 = bullet.instantiate()
		pellet3.position = pelletspawn.global_position
		pellet3.transform.basis = pelletspawn.global_transform.basis
		pellet3.rotation.x += randf_range(-0.05, 0.05)
		pellet3.rotation.y += randf_range(-0.05, 0.05)
		get_tree().root.add_child(pellet3)
		
		pellet4 = bullet.instantiate()
		pellet4.position = pelletspawn.global_position
		pellet4.transform.basis = pelletspawn.global_transform.basis
		pellet4.rotation.x += randf_range(-0.05, 0.05)
		pellet4.rotation.y += randf_range(-0.05, 0.05)
		get_tree().root.add_child(pellet4)
		
		pellet5 = bullet.instantiate()
		pellet5.position = pelletspawn.global_position
		pellet5.transform.basis = pelletspawn.global_transform.basis
		pellet5.rotation.x += randf_range(-0.05, 0.05)
		pellet5.rotation.y += randf_range(-0.05, 0.05)
		get_tree().root.add_child(pellet5)
		
		pellet6 = bullet.instantiate()
		pellet6.position = pelletspawn.global_position
		pellet6.transform.basis = pelletspawn.global_transform.basis
		pellet6.rotation.x += randf_range(-0.05, 0.05)
		pellet6.rotation.y += randf_range(-0.05, 0.05)
		get_tree().root.add_child(pellet6)
		
		pellet7 = bullet.instantiate()
		pellet7.position = pelletspawn.global_position
		pellet7.transform.basis = pelletspawn.global_transform.basis
		pellet7.rotation.x += randf_range(-0.05, 0.05)
		pellet7.rotation.y += randf_range(-0.05, 0.05)
		get_tree().root.add_child(pellet7)
		
		pellet8 = bullet.instantiate()
		pellet8.position = pelletspawn.global_position
		pellet8.transform.basis = pelletspawn.global_transform.basis
		pellet8.rotation.x += randf_range(-0.05, 0.05)
		pellet8.rotation.y += randf_range(-0.05, 0.05)
		get_tree().root.add_child(pellet8)
		
		pellet9 = bullet.instantiate()
		pellet9.position = pelletspawn.global_position
		pellet9.transform.basis = pelletspawn.global_transform.basis
		pellet9.rotation.x += randf_range(-0.05, 0.05)
		pellet9.rotation.y += randf_range(-0.05, 0.05)
		get_tree().root.add_child(pellet9)

func reload():
	if !anim.is_playing():
		anim.play("Reload")
		if ammo >= max_loaded:
			self.ammo -= max_loaded
			self. loaded += max_loaded
		else:
			self.ammo -= ammo
			self.loaded += ammo
		print(loaded, " shells loaded")
		print(ammo, " reserve ammo remaining")

func knockback() -> void:
	if heldByPlayer == true:
		player.velocity +=   global_transform.basis * Vector3(0, 0, KICK)
		#print(player.get_child(2).name)
