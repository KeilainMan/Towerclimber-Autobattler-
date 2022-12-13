extends LevelBackgroundBase


var playerpositions: Array = [
	preload("res://Levels/1-10/TilemapsAndNavigationPolys/TileMapAndNavigationPoly_1/PlayerPositions/player_positions_001.tscn"),
	preload("res://Levels/1-10/TilemapsAndNavigationPolys/TileMapAndNavigationPoly_1/PlayerPositions/player_positions_002.tscn"),
	preload("res://Levels/1-10/TilemapsAndNavigationPolys/TileMapAndNavigationPoly_1/PlayerPositions/player_positions_003.tscn")
	
]

# Übergangsarray der die PackagedScenes läd, welche die Enemys enthalten
# soll ersetzt werden durch einen automatischen Path, der zu einem Ordner führt, 
# der die Szenen gespeichert hat
var enemys: Array = [
	preload("res://Levels/1-10/TilemapsAndNavigationPolys/TileMapAndNavigationPoly_1/Enemys/Enemys_1.tscn"),
	preload("res://Levels/1-10/TilemapsAndNavigationPolys/TileMapAndNavigationPoly_1/Enemys/Enemys_2.tscn"),
	preload("res://Levels/1-10/TilemapsAndNavigationPolys/TileMapAndNavigationPoly_1/Enemys/Enemys_3.tscn"),
	preload("res://Levels/1-10/TilemapsAndNavigationPolys/TileMapAndNavigationPoly_1/Enemys/Enemys_4.tscn")
]


func _ready() -> void:
	randomize()
	_set_playerpositions_of_this_level(playerpositions)
	_set_enemys_of_this_level(enemys)


#
#func instance_playerpositions() -> void:
#	playerpositions.shuffle()
#	var new_playerpositions: Node = playerpositions[0].instance()
#	call_deferred("add_child", new_playerpositions)
#
#
#func instance_enemys() -> void:
#	enemys.shuffle()
#	var new_enemys: Node = enemys[0].instance()
#	call_deferred("add_child", new_enemys)
