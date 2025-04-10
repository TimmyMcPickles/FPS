extends Node3D

#bullets
var bullet = load("res://scenes/bullet_glock.tscn")
var instance

@onready var gun_anim = $AnimationPlayer
@onready var bullet_spawn = $RayCast3D

func _physics_process(delta: float) -> void:
	#shooting
	if Input.is_action_pressed("shoot"):
		if !gun_anim.is_playing():
			gun_anim.play("shoot")
			instance = bullet.instantiate()
			instance.position = bullet_spawn.global_position
			instance.transform.basis = bullet_spawn.global_transform.basis
			get_parent().add_child(instance)
