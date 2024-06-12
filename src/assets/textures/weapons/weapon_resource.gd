extends Resource

class_name Weapon_Resource

# variables for the animations
@export var weapon_name : String
@export var activate_animation : String
@export var shoot_animation : String
@export var reload_animation : String
@export var deactivate_animation : String
@export var noamo_animation : String

# variables for ammo
@export var current_ammo : int
@export var reserve_ammo : int
@export var magazine_ammo : int
@export var max_ammo : int

@export var auto_fire : bool
@export var weapon_range : int
@export var damage : int


@export_flags("HitScan", "Projectile") var Type
@export var projectile_to_load : PackedScene
@export var projectile_velocity : int
