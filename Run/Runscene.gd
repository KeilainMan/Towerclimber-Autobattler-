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
	if !current_level == null:
		current_level.queue_free()


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
	Signals.emit_signal("gold_changed", current_gold)


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
