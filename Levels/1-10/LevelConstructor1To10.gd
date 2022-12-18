extends Node



var backgrounds_and_navigationpolys: Array = [
	load("res://Levels/1-10/TilemapsAndNavigationPolys/TileMapAndNavigationPoly_1/TileMapAndNavigationPoly_1.tscn"),
	load("res://Levels/1-10/TilemapsAndNavigationPolys/TileMapAndNavigationPoly_2/TileMapAndNavigationPoly_2.tscn"),
	load("res://Levels/1-10/TilemapsAndNavigationPolys/TileMapAndNavigationPoly_3/TileMapAndNavigationPoly_3.tscn")
]




func _ready():
	pass # Replace with function body.


func get_levelbackground_and_navigationpoly(level: int) -> PackedScene:
	backgrounds_and_navigationpolys.shuffle()
	return backgrounds_and_navigationpolys[0]
