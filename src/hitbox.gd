extends Area3D

@export var damage: int = 10

func get_knockback():
	return get_parent().get_knockback()
