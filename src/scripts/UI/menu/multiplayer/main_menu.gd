extends Control


@export_file("*.tscn") var server_scene
@export_file("*.tscn") var client_scene


@onready var client_button = $Client_button
@onready var server_button = $Server_button

func _ready():
	server_button.grab_focus()

func _on_client_button_pressed():
	get_tree().change_scene_to_file(client_scene)


func _on_server_button_pressed():
	get_tree().change_scene_to_file(server_scene)
