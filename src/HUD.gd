extends CanvasLayer

@onready var current_weapon_label = $VBoxContainer/HBoxContainer/current_weapon
@onready var current_ammo_label = $VBoxContainer/HBoxContainer2/current_ammo
@onready var current_weapon_stack = $VBoxContainer/HBoxContainer3/weapon_stack



func _on_weapon_manager_update_ammo(ammo):
	current_ammo_label.set_text(str(ammo[0]) + " / " + str(ammo[1]))


func _on_weapon_manager_update_weapon_stack(weapon_stack):
	current_weapon_stack.set_text("")
	for i in weapon_stack:
		current_weapon_stack.text += "\n" + i


func _on_weapon_manager_weapon_changed(weapon_name):
	current_weapon_label.set_text(weapon_name)
