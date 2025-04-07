extends Node3D

@export var active: bool = false

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

func shoot():
	if !$AnimationPlayer.is_playing():
		$AnimationPlayer.play("Shoot")
		pellet1 = bullet.instantiate()
		pellet1.position = $pelletspawn1.global_position
		pellet1.transform.basis = $pelletspawn1.global_transform.basis
		get_tree().root.add_child(pellet1)
		
		pellet2 = bullet.instantiate()
		pellet2.position = $pelletspawn2.global_position
		pellet2.transform.basis = $pelletspawn2.global_transform.basis
		get_tree().root.add_child(pellet2)
		
		pellet3 = bullet.instantiate()
		pellet3.position = $pelletspawn3.global_position
		pellet3.transform.basis = $pelletspawn3.global_transform.basis
		get_tree().root.add_child(pellet3)
		
		pellet4 = bullet.instantiate()
		pellet4.position = $pelletspawn4.global_position
		pellet4.transform.basis = $pelletspawn4.global_transform.basis
		get_tree().root.add_child(pellet4)
		
		pellet5 = bullet.instantiate()
		pellet5.position = $pelletspawn5.global_position
		pellet5.transform.basis = $pelletspawn5.global_transform.basis
		get_tree().root.add_child(pellet5)
		
		pellet6 = bullet.instantiate()
		pellet6.position = $pelletspawn6.global_position
		pellet6.transform.basis = $pelletspawn6.global_transform.basis
		get_tree().root.add_child(pellet6)
		
		pellet7 = bullet.instantiate()
		pellet7.position = $pelletspawn7.global_position
		pellet7.transform.basis = $pelletspawn7.global_transform.basis
		get_tree().root.add_child(pellet7)
		
		pellet8 = bullet.instantiate()
		pellet8.position = $pelletspawn8.global_position
		pellet8.transform.basis = $pelletspawn8.global_transform.basis
		get_tree().root.add_child(pellet8)
		
		pellet9 = bullet.instantiate()
		pellet9.position = $pelletspawn9.global_position
		pellet9.transform.basis = $pelletspawn9.global_transform.basis
		get_tree().root.add_child(pellet9)

func _physics_process(delta: float) -> void:
	if active == true:
		if Input.is_action_pressed("shoot"):
			shoot()
