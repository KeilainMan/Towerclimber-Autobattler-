extends Node


onready var scp: Script = preload("res://Units/StatusEffects/Stun.gd")

func _ready():
	var new_script= scp.new(1.5)
	print(new_script)
	add_child(new_script)
