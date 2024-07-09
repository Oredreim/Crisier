extends Label

func _ready():
	visible = multiplayer.is_server()
