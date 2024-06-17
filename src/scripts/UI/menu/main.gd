extends Node


@onready var main_menu = $Menu/MainMenu
@onready var address_entry = $Menu/MainMenu/MarginContainer/VBoxContainer/Address_entry

const player = preload("res://src/scenes/character/character.tscn") 

const PORT = 9999
var enet_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


func _on_host_button_pressed():
	main_menu.hide()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	
	add_player(multiplayer.get_unique_id())

func _on_join_button_pressed():
	main_menu.hide()
	
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer


func add_player(peer_id):
	var _player = player.instantiate()
	_player.name = str(peer_id)
	add_child(_player)
