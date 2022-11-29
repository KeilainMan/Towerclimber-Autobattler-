extends Node
class_name Levelconstructor


var tilemaps:Array = [
	load("res://Levels/Levelresources/Testtilemaps/Tilemap_1.tres"),
	load("res://Levels/Levelresources/Testtilemaps/Tilemap_2.tres"),
	load("res://Levels/Levelresources/Testtilemaps/Tilemap_3.tres")
]

var player_positions:Array = [
	load("res://Levels/Levelresources/PlayerPositions/player_positions_001.tscn"),
	load("res://Levels/Levelresources/PlayerPositions/player_positions_002.tscn"),
	load("res://Levels/Levelresources/PlayerPositions/player_positions_003.tscn")
	
	
]

var enemys:Array = [
	load("res://Levels/Levelresources/Enemyspositions/Enemys_1.tscn"),
	load("res://Levels/Levelresources/Enemyspositions/Enemys_2.tscn"),
	load("res://Levels/Levelresources/Enemyspositions/Enemys_3.tscn"),
]


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


func get_tilemap():
	tilemaps.shuffle()
	return tilemaps[0]

func get_player_positions():
	player_positions.shuffle()
	return player_positions[0]
	
func get_enemys_and_enemy_positions():
	enemys.shuffle()
	return enemys[0]
