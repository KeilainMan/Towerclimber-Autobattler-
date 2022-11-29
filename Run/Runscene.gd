extends Node2D


onready var level = preload("res://Levels/Levelbase.tscn")



func _ready():
	setup_run_manager()
	var new_level = level.instance()
	add_child(new_level)

func setup_run_manager():
	RunManager.run_initialization()
