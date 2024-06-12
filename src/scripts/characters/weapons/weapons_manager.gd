extends Node3D

signal weapon_changed
signal update_ammo
signal update_weapon_stack

@export var animation_player : AnimationPlayer
@onready var bullet_point = get_node("%Bullet_Point")

var debug_bullet = preload("res://src/scenes/enviroment/bullets/BulletDebug/bullet_debug.tscn")

var current_weapon : Weapon_Resource = null
var weapon_stack : Array = [] # An array of weapons currently held by the player
var weapon_indicator = 0
var next_weapon : String
var weapon_list : Dictionary = {}

@export var _weapon_resources : Array[Weapon_Resource]
@export var start_weapons : Array[String]

enum {NULL, HITSCAN, PROJECTILE}

var collision_exclusion = []


func _ready():
	Initialize(start_weapons) #enter the state machine


func _input(event):
	if event.is_action_pressed("weapon_1"):
		weapon_indicator = min(weapon_indicator+1, weapon_stack.size()-1)
		exit(weapon_stack[weapon_indicator])

	if event.is_action_pressed("weapon_2"):
		weapon_indicator = max(weapon_indicator-1, 0)
		exit(weapon_stack[weapon_indicator])
	
	if event.is_action_pressed("shoot"):
		shoot()
	if event.is_action_pressed("reload"):
		reload()

func Initialize(_start_weapons : Array):
	for weapon in _weapon_resources: # create a dictionary of the weapons we have created so we can refered to it
		weapon_list[weapon.weapon_name] = weapon
		
	for weapon_name in _start_weapons:
		weapon_stack.push_back(weapon_name) # add out start weapons
		
	current_weapon = weapon_list[weapon_stack[0]] # set the first weapon in the stack to the current
	emit_signal("update_weapon_stack", weapon_stack)
	enter()
	
func enter(): # call when first entering into a weapon
	animation_player.queue(current_weapon.activate_animation)
	emit_signal("weapon_changed", current_weapon.weapon_name) # we pass the name of the weapon we are currently using
	emit_signal("update_ammo",[current_weapon.current_ammo, current_weapon.reserve_ammo]) # we pass the ammo we are currently have


func exit(_next_weapon: String): # in order to change weapons first call exit
	if _next_weapon != current_weapon.weapon_name:
		if animation_player.get_current_animation() != current_weapon.deactivate_animation: # current_weapon animation depends on the weapons resources scripts
			animation_player.queue(current_weapon.deactivate_animation) # current_weapon animation depends on the weapons resources scripts
			next_weapon = _next_weapon


func change_weapon(weapon_name : String):
	current_weapon = weapon_list[weapon_name]
	next_weapon = ""
	enter()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == current_weapon.deactivate_animation:
		change_weapon(next_weapon)
		
	if anim_name == current_weapon.shoot_animation: # this suppose to do auto fire animation
		if current_weapon.auto_fire == true:
			if Input.is_action_pressed("shoot"):
				shoot()

func shoot():
	if current_weapon.current_ammo != 0:
		if !animation_player.is_playing(): # enforces the fire rate set by the animation
			animation_player.play(current_weapon.shoot_animation)
			current_weapon.current_ammo -= 1
			emit_signal("update_ammo",[current_weapon.current_ammo, current_weapon.reserve_ammo])
			var camera_collision = get_camera_colision()
			match current_weapon.Type:
				NULL:
					print ("weapon type not chosen")
				HITSCAN: # do hitscan
					hit_scan_collision(camera_collision) 
				PROJECTILE:
					launch_projectile(camera_collision)
	else:
		reload()

func reload():
	if current_weapon.current_ammo == current_weapon.magazine_ammo:
		return
	elif not animation_player.is_playing():
		if current_weapon.reserve_ammo != 0:
			animation_player.play(current_weapon.reload_animation)
			var reload_amount = current_weapon.reserve_ammo - current_weapon.current_ammo 
			current_weapon.current_ammo = current_weapon.current_ammo + reload_amount
			emit_signal("update_ammo",[current_weapon.current_ammo, current_weapon.reserve_ammo])
		else:
			animation_player.play(current_weapon.noamo_animation)

func get_camera_colision() -> Vector3:
	var camera = get_viewport().get_camera_3d()
	var viewport = get_viewport().get_size()
	
	var ray_origin = camera.project_ray_origin(viewport/2)
	var ray_end = ray_origin + camera.project_ray_normal(viewport/2) * current_weapon.weapon_range
	
	var new_intersection = PhysicsRayQueryParameters3D.create(ray_origin,ray_end)
	new_intersection.set_exclude(collision_exclusion)
	var intersection = get_world_3d().direct_space_state.intersect_ray(new_intersection)
	
	if not intersection.is_empty():
		var col_point = intersection.position
		return col_point
	else:
		return ray_end


func hit_scan_collision(collision_point):
	var bullet_direction = (collision_point - bullet_point.get_global_transform().origin).normalized()
	var new_interection = PhysicsRayQueryParameters3D.create(bullet_point.get_global_transform().origin,collision_point+bullet_direction*2)
	
	var bullet_collision = get_world_3d().direct_space_state.intersect_ray(new_interection)
	
	if bullet_collision:
		var hit_indicator = debug_bullet.instantiate()
		var world = get_tree().get_root().get_child(0)
		world.add_child(hit_indicator)
		hit_indicator.global_translate(bullet_collision.position)
		hit_scan_damage(bullet_collision.collider, bullet_direction, bullet_collision.position)

func hit_scan_damage(collider, direction, _position):
	if collider.is_in_group("Target") and collider.has_method("hit_success"):
		collider.hit_success(current_weapon.damage, direction, _position)

func launch_projectile(point : Vector3):
	var direction = (point - bullet_point.get_global_transform().origin).normalized()
	var projectile = current_weapon.projectile_to_load.instantiate()
	
	var projectile_rid = projectile.get_rid()
	collision_exclusion.push_front(projectile_rid)
	projectile.tree_exited.connect(remove_exclusion.bind(projectile.get_rid()))
	
	bullet_point.add_child(projectile)
	projectile.damage = current_weapon.damage
	projectile.set_linear_velocity(direction * current_weapon.projectile_velocity)


func remove_exclusion(projectile_rid):
	collision_exclusion.erase(projectile_rid)