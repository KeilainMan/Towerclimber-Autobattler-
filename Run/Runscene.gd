extends Node2D


onready var levelbase = preload("res://Levels/Levelbase.tscn")



func _ready():
	setup_run_manager()
	execute_levelroutine()
#	var new_level = level.instance()
#	add_child(new_level)

func setup_run_manager() -> void:
	RunManager.run_initialization()


func execute_levelroutine() -> void:
	var new_level: int = RunManager.get_level()
	instance_a_levelbase(new_level)


func instance_a_levelbase(level: int) -> void:
	var new_levelbase: Node = levelbase.instance()
	new_levelbase.instance_level_number_x(level)
	add_child(new_levelbase)
	
