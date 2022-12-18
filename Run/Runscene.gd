extends Node2D


onready var levelbase: PackedScene = preload("res://Levels/Levelbase.tscn")

# levelpart booleans
var levelbg_part: bool = false
var playerpos_part: bool = false
var enemys_part: bool = false


func _ready() -> void:
	setup_run_manager()
	execute_levelroutine()


func setup_run_manager() -> void:
	RunManager.run_initialization()


func execute_levelroutine() -> void:
	var new_level: int = RunManager.get_level()
	instance_a_levelbase(new_level)


func instance_a_levelbase(level: int) -> void:
	var new_levelbase: Node = levelbase.instance()
	add_child(new_levelbase)
	new_levelbase.instance_level_number_x(level)

