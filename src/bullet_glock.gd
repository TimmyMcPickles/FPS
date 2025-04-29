extends Node3D

@export var damage: int = 10
@export var knockback = 5.5

@onready var origin = global_position

const SPEED = 40

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D

func _physics_process(delta: float) -> void:
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	if ray.is_colliding():
		mesh.visible = false
		particles.emitting = true
		await get_tree().create_timer(1.0).timeout
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()

func get_knockback():
	return -1 * global_position.direction_to(origin) * knockback
