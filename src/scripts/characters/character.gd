extends CharacterBody3D

# call of the node MainCamera
@onready var MainCamera: Node = get_node("%MainCamera") # the % means that this is a unique node, can be access anywhere with %
@onready var animation_player = $Visuals/default/Animations
@onready var visuals = $Visuals
@onready var camera_mount = $SpringArm3D/camera_mount

@export_category("Movement Parameters")
@export var jump_peak_time : float = 0.5
@export var jump_fall_time : float = 0.5
@export var jump_height : float = 2.0
@export var jump_distance : float = 4.0
@export var coyote_time : float = 0.2 # the variable that helps to jump in the air after leaving a platform 
@export var jump_buffer_timer : float = 0.1

@onready var coyote_timer : Timer = $Coyote_Timer # the timer that helps to jump in the air after leaving a platform 

var walking_speed : float = 3.0
var running_speed : float = 7.0
var sprinting_speed : float = 12.0

var sprinting : bool = false
var walking : bool = false

var is_locked : bool = false

var speed : float = 5.0
var jump_velocity : float = 5.0
var jump_available : bool = true
var jump_buffer : bool = false # its the variable that helps to do bunny hop (the ability to jump before touching the floor)

# Camera variables 
var camera_rotation : Vector2 = Vector2(0,0)
var mouse_sensitivity: float = 0.001

@export var sens_horizontal : float = 0.1
@export var sens_vertical : float = 0.1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var jump_gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var fall_gravity : float = 5.0

# Set by the authority, synchronized on spawn.
@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$Weapon_synchronizer.set_multiplayer_authority(id)


# Player synchronized input.
@onready var input = $SpringArm3D/camera_mount/Weapons_Manager


func _ready():
	# Set the camera as current if we are this player.
	if player == multiplayer.get_unique_id():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		calculate_movement_parameters()
		MainCamera.current = true
# function for input management

func _input(event):
	# Set the camera as current if we are this player.
	if player == multiplayer.get_unique_id():
		if event.is_action_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x*sens_horizontal))
			camera_mount.rotate_x(deg_to_rad(-event.relative.y*sens_vertical))
			visuals.rotate_y(deg_to_rad(event.relative.x*sens_horizontal))
			#var mouse_event = event.relative * mouse_sensitivity
			#_cameralook(mouse_event)

# camera rotation
func _cameralook(Movement: Vector2):
	camera_rotation += Movement
	
	transform.basis = Basis()
	MainCamera.transform.basis = Basis()
	
	rotate_object_local(Vector3(0,1,0),-camera_rotation.x) # first rotate in Y
	MainCamera.rotate_object_local(Vector3(1,0,0), -camera_rotation.y) # then rotate in X
	camera_rotation.y = clamp(camera_rotation.y,-1.5,1.2)

func _physics_process(delta):
	# Set the camera as current if we are this player.
	if player == multiplayer.get_unique_id():
		if !animation_player.is_playing():
			is_locked = false
		if Input.is_action_just_pressed("knock_down"):
			if animation_player.current_animation != "knock_down2":
				animation_player.play("knock_down2")
				is_locked = true
		if Input.is_action_pressed("sprint"):
			speed = sprinting_speed
			sprinting = true
		else:
			speed = running_speed
			sprinting = false
		# Add the gravity.
		if not is_on_floor():
			if jump_available:
				if coyote_timer.is_stopped():
					coyote_timer.start(coyote_time)
				#get_tree().create_timer(coyote_time).timeout.connect(coyote_timeout)
				
			if velocity.y>0:
				velocity.y -= jump_gravity * delta
			else:
				velocity.y -= fall_gravity * delta
		else:
			jump_available = true
			coyote_timer.stop()
			if jump_buffer:
				jump()
				jump_buffer = false
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept"):
			if jump_available:
				jump()
			else:
				jump_buffer = true
				get_tree().create_timer(jump_buffer_timer).timeout.connect(on_jump_buffer_timeout)
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("left", "right", "foward", "backward")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		var direction_spring_arm = direction.rotated(Vector3.UP, $SpringArm3D.rotation.y)
		if direction:
			if !is_locked:
				if sprinting:
					if animation_player.current_animation != "sprinting":
						animation_player.play("sprinting")
				else:
					if animation_player.current_animation != "running":
						animation_player.play("running")
				visuals.look_at(position + direction)
			
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			if !is_locked:
				if animation_player.current_animation != "idle":
					animation_player.play("idle")
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)

		if !is_locked:
			move_and_slide()

func calculate_movement_parameters() -> void:
	jump_gravity = (2*jump_height)/pow(jump_peak_time,2)
	fall_gravity = (2*jump_height)/pow(jump_fall_time,2)
	jump_velocity = jump_gravity * jump_peak_time
	speed = jump_distance / (jump_peak_time+ jump_fall_time)


func coyote_timeout():
	jump_available = false


func jump() -> void:
	velocity.y = jump_velocity
	jump_available = false


func on_jump_buffer_timeout() -> void:
	jump_buffer = false
