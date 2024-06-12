extends CharacterBody3D

# call of the node MainCamera
@onready var MainCamera: Node = get_node("%MainCamera") # the % means that this is a unique node, can be access anywhere with %

#const SPEED: float = 5.0
#const JUMP_VELOCITY: float = 4.5

@export_category("Movement Parameters")
@export var jump_peak_time : float = .5
@export var jump_fall_time : float = .5
@export var jump_height : float = 2.0
@export var jump_distance : float = 4.0
var speed : float = 5.0
var jump_velocity : float = 5.0

# Camera variables 
var camera_rotation = Vector2(0,0)
var mouse_sensitivity: float = 0.001

# Get the gravity from the project settings to be synced with RigidBody nodes.
var jump_gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var fall_gravity : float = 5.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	calculate_movement_parameters()

# function for input management
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseMotion:
		var mouse_event = event.relative * mouse_sensitivity
		_cameralook(mouse_event)

# camera rotation
func _cameralook(Movement: Vector2):
	camera_rotation += Movement
	
	transform.basis = Basis()
	MainCamera.transform.basis = Basis()
	
	rotate_object_local(Vector3(0,1,0),-camera_rotation.x) # first rotate in Y
	MainCamera.rotate_object_local(Vector3(1,0,0), -camera_rotation.y) # then rotate in X
	camera_rotation.y = clamp(camera_rotation.y,-1.5,1.2)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		if velocity.y>0:
			velocity.y -= jump_gravity * delta
		else:
			velocity.y -= fall_gravity * delta
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func calculate_movement_parameters() -> void:
	jump_gravity = (2*jump_height)/pow(jump_peak_time,2)
	fall_gravity = (2*jump_height)/pow(jump_fall_time,2)
	jump_velocity = jump_gravity * jump_peak_time
	speed = jump_distance / (jump_peak_time+ jump_fall_time)
	
	
