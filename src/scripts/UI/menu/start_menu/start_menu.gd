extends CanvasLayer

class_name Main_Menu

@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("camera_anim")


func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://src/scenes/ui/Menu/multiplayer/multiplayer.tscn")


func _on_settings_pressed():
	get_tree().change_scene_to_file("res://src/scenes/ui/Menu/Settings/settings.tscn")


func _on_quit_game_pressed():
	get_tree().quit()
