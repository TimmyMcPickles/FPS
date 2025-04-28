@tool
extends Area3D

func _ready():
    connect("body_entered", Callable(self, "_on_body_entered"))
    connect("body_exited", Callable(self, "_on_body_exited"))
    connect("area_entered", Callable(self, "_area_entered"))

func _on_body_entered(body):
    if body.is_in_group("player"):
        body.is_in_water = true
        # Optional: Play splash sound here
        # AudioStreamPlayer.play()

func _on_body_exited(body):
    if body.is_in_group("player"):
        body.is_in_water = false
        # Optional: Play exit water sound here
