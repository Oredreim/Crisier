extends CanvasLayer



func _on_return_button_pressed():
	get_tree().change_scene_to_file("res://src/scenes/ui/Menu/StartMenu/start_menu.tscn")

func _on_quit_game_pressed():
	get_tree().quit()

