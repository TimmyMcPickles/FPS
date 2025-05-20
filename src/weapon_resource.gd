extends Resource

class_name Weapon_Resource

@export var weapon_name: String
@export var activate_anim: String
@export var deactivate_anim:  String
@export var shoot_anim:  String
@export var reload_anim: String
@export var no_ammo_anim:String

@export var current_ammo: int
@export var reserve_ammo: int
@export var magazine: int
@export var max_ammo: int

@export var auto_fire: bool
@export var spread_shot: bool
@export var kickback: bool #gun knocking user back
@export var knockback: bool #gun knocking target back
