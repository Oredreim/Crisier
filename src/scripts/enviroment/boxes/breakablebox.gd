extends Box

func _ready():
	change_health(50)

func change_health(new_health):
	health = new_health
