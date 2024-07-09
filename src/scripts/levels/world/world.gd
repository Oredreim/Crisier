extends Node

@onready var asteroid_spawner = $Spawners/Ball
@onready var player_spawner = $Spawners/Players


func _ready():
	if not multiplayer.is_server():  # If the multiplayer is not a server
		var server_connection = multiplayer.multiplayer_peer.get_peer(1) # create the conection for the server first peer for the server (1)
		var latency = server_connection.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME) / (1000 * 2)
		await get_tree().create_timer(latency).timeout
		rpc_id(1, "sync_world")
		rpc_id(1, "create_character")

	else:
		for i in 30:
			asteroid_spawner.spawn()


@rpc("any_peer", "call_remote")
func create_character():
	var player_id = multiplayer.get_remote_sender_id()
	var character = preload("res://src/scenes/character/character.tscn").instantiate()
	character.name = str(player_id)
	$Players.add_child(character)
	character.rpc("setup_multiplayer", player_id)


@rpc("any_peer", "call_local")
func sync_world():
	var player_id = multiplayer.get_remote_sender_id()
	get_tree().call_group("Sync", "set_visibility_for", player_id, true)


func _on_players_multiplayer_spawner_spawned(node):
	node.rpc("setup_multiplayer", int(str(node.name)))

