extends Box

func _ready():
	change_health(50)

func change_health(new_health):
	health = new_health

func set_direction(_direction, _damage, _hit_position):
	pass
