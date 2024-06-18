extends CanvasLayer

@onready var animation_player = $AnimationPlayer
func _ready():
	animation_player.play("camera_anim")


func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://src/scenes/ui/main.tscn")


func _on_settings_pressed():
	pass # Replace with function body.


func _on_quit_game_pressed():
	get_tree().quit()
