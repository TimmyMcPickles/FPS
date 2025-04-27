@tool
extends Area3D

signal player_entered_water
signal player_exited_water

@export var swim_resistance := 0.8
@export var water_color := Color(0.2, 0.4, 0.8, 0.4)

var player_inside := false

func _ready():
    if not Engine.is_editor_hint():
        connect("body_entered", _on_body_entered)
        connect("body_exited", _on_body_exited)

        # Create water visual if not in editor
        _create_water_visual()

func _create_water_visual():
    var material = StandardMaterial3D.new()
    material.albedo_color = water_color
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.roughness = 0.1

    var mesh_instance = MeshInstance3D.new()
    var mesh = BoxMesh.new()
    mesh_instance.mesh = mesh
    mesh_instance.material_override = material

    # Get the size of the water area from the collision shape
    var shape = get_node_or_null("CollisionShape3D")
    if shape and shape.shape:
        if shape.shape is BoxShape3D:
            mesh.size = shape.shape.size
            mesh_instance.position = Vector3.ZERO

    add_child(mesh_instance)

func _on_body_entered(body):
    if body.is_in_group("player"):
        player_inside = true
        emit_signal("player_entered_water")

        # Tell the player they're in water
        if body.has_method("enter_water"):
            body.enter_water(self)

func _on_body_exited(body):
    if body.is_in_group("player"):
        player_inside = false
        emit_signal("player_exited_water")

        # Tell the player they're out of water
        if body.has_method("exit_water"):
            body.exit_water()
