extends Node2D

onready var shop: PackedScene = preload("res://Shop/ShopBase.tscn")
onready var party_manager: Node = get_node("PartyManager")
onready var levelbase: PackedScene = preload("res://Levels/Levelbase.tscn")

var current_run_party: Array = []
var current_level: Node
var current_shop: Node


var current_gold: int = 1 setget set_gold, get_gold
var level: int = 0 setget , get_level

func _ready() -> void:
	_instance_shop()
	set_gold(3)

	Signals.connect("proceed_to_next_level", self, "_on_proceed_to_next_level")
	Signals.connect("gold_spend", self, "_on_gold_spend")
	Signals.connect("after_level_proceedings_finished", self, "_on_after_level_proceedings_finished")


func _instance_shop() -> void:
	var new_shop = shop.instance()
	$ShopLayer.add_child(new_shop)
	current_shop = new_shop
	

func _on_proceed_to_next_level() -> void:
	_increase_level()
	_update_current_party()
	_free_current_level()
	_free_current_shop()
	execute_levelroutine()


func _update_current_party() -> void:
	current_run_party.clear()
	current_run_party = party_manager.get_current_party_scenes()


func _free_current_level() -> void:
	print(current_level)
	if !current_level == null:
		remove_child(current_level)


func _free_current_shop() -> void:
	current_shop.queue_free()


func execute_levelroutine() -> void:
	var new_level: int = get_level()
	instance_a_levelbase(new_level)


func instance_a_levelbase(level_number: int) -> void:
	var new_levelbase: Node = levelbase.instance()
	add_child(new_levelbase)
	new_levelbase.instance_level_number_x(level_number)
	current_level = new_levelbase


func _increase_level() -> void:
	if level < 100:
		level += 1
	else:
		return


func increase_gold(amount: int) -> void:
	current_gold += amount
	print(current_gold, amount)
	Signals.emit_signal("gold_changed", current_gold)


func _on_after_level_proceedings_finished(game_end_screen) -> void:
	print("level finished")
	var last_level: int = get_level()
	_free_game_end_screen(game_end_screen)
	_instance_shop()
	_reward_player(last_level)
	
	


func _reward_player(level_number: int) -> void:
	var gold_reward: int = _calculate_gold_reward(level_number)
	increase_gold(gold_reward)


func _calculate_gold_reward(level_number: int) -> int:
	var gold_1: int = clamp(level_number, 3, 20)
	return gold_1


func _free_game_end_screen(game_end_screen) -> void:
	game_end_screen.queue_free()


func _on_gold_spend(amount: int) -> void:
	decrease_gold(amount)


func decrease_gold(amount: int) -> void:
	current_gold -= amount
	Signals.emit_signal("gold_changed", current_gold)


#################################################################
# SETTER GETTER
func get_level() -> int:
	return level


func set_gold(amount: int) -> void:
	current_gold = amount
	Signals.emit_signal("gold_changed", current_gold)


func get_gold() -> int:
	return current_gold
