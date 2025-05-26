extends Node3D
@onready var animation_player = %AnimationPlayer

signal weapon_changed
signal update_ammo
signal update_weapon_stack

var current_weapon = null
var weapon_stack = [] # Array of weapons currently held
var weapon_indicator = 0
var next_weapon: String
var weapon_list = {}

@export var _weapon_resources: Array[Weapon_Resource]
@export var start_weapons: Array[String]

func _ready():
	initialize(start_weapons) # enter the state machine

func _input(event):
	if event.is_action_pressed("weapon_up"):
		weapon_indicator = min(weapon_indicator+1, weapon_stack.size()-1)
		exit(weapon_stack[weapon_indicator])
	if event.is_action_pressed("weapon_down"):
		weapon_indicator = max(weapon_indicator-1,0)
		exit(weapon_stack[weapon_indicator])
	if event.is_action_pressed("shoot"):
		shoot()
	if event.is_action_pressed("reload"):
		reload()
	

func initialize(_start_weapons: Array):
	# Create a dictionary to refer to our weapons
	for weapon in _weapon_resources:
		weapon_list[weapon.weapon_name] = weapon
	
	for i in _start_weapons:
		weapon_stack.push_back(i) # add start weapons
	
	current_weapon = weapon_list[weapon_stack[0]] # set first weapon in stack to current
	emit_signal("update_weapon_stack", weapon_stack)
	enter()

func enter():
	# call when first "entering" into a weapon
	animation_player.queue(current_weapon.activate_anim)
	emit_signal("weapon_changed", current_weapon.weapon_name)
	emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])

func exit(_next_weapon: String):
	# in order to change weapons, first call exit
	if _next_weapon != current_weapon.weapon_name:
		if animation_player.get_current_animation() != current_weapon.deactivate_anim:
			animation_player.play(current_weapon.deactivate_anim)
			next_weapon = _next_weapon

func change_weapon(weapon_name: String):
	var weapon_index = weapon_stack.find(weapon_name)
	if weapon_index != -1:
		current_weapon = weapon_list[weapon_name]
		next_weapon = ""
		enter()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == current_weapon.deactivate_anim:
		change_weapon(next_weapon)
	
	if anim_name == current_weapon.shoot_anim && current_weapon.auto_fire == true:
		if Input.is_action_pressed("shoot"):
			shoot()

func shoot():
	if current_weapon.current_ammo != 0 and !animation_player.is_playing():
		animation_player.play(current_weapon.shoot_anim)
		current_weapon.current_ammo -= 1
		emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])
	else:
		animation_player.play(current_weapon.no_ammo_anim)

func reload():
	if current_weapon.current_ammo == current_weapon.magazine:
		return
	elif !animation_player.is_playing():
		if current_weapon.reserve_ammo != 0:
			animation_player.play(current_weapon.reload_anim)
			var reload_amount = min(current_weapon.magazine - current_weapon.current_ammo, current_weapon.magazine, current_weapon.reserve_ammo)
			current_weapon.current_ammo = current_weapon.current_ammo + reload_amount
			current_weapon.reserve_ammo = current_weapon.reserve_ammo - reload_amount
			emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])
		else:
			animation_player.play(current_weapon.no_ammo_anim)
