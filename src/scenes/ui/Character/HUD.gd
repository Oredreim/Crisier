extends CanvasLayer

@onready var current_weapon_label = $VBoxContainer/HBoxContainer/CurrentWeapon
@onready var current_ammo_label = $VBoxContainer/HBoxContainer2/CurrentAmmo
@onready var current_weapon_stack = $VBoxContainer/HBoxContainer3/WeaponStack


func _on_weapons_manager_update_ammo(_ammo):
	current_ammo_label.set_text(str(_ammo[0])+" / "+str(_ammo[1]))


func _on_weapons_manager_update_weapon_stack(_weapon_stack):
	current_weapon_stack.set_text("")
	for i in _weapon_stack:
		current_weapon_stack.text += "\n"+i


func _on_weapons_manager_weapon_changed(_weapon_name):
	current_weapon_label.set_text(_weapon_name)
