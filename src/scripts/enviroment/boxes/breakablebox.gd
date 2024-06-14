extends Box

func _ready():
	change_health(50)

func change_health(new_health):
	health = new_health

func set_direction(_direction, damage, hit_position):
	# Intentionally left blank or add any alternative behavior here
	pass
