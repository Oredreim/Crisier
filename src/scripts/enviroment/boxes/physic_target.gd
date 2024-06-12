extends RigidBody3D

var health = 999

func hit_success(damage, _direction:= Vector3.ZERO, _position:= Vector3.ZERO):
	
	var hit_position = _position - get_global_transform().origin
	
	health -= damage
	print("Target Health = " + str(health))
	
	if health < 0:
		queue_free()

	if _direction != Vector3.ZERO:
		apply_impulse((_direction*damage),hit_position)
