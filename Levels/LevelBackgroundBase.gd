extends TileMap
class_name LevelBackgroundBase

# Basisklasse für den Levelbackground bestehend aus einem Tilemap Node und 
# einem NavigationsPolygon Node, dieses Skript organisiert, welche Spielerpositionen
# und Gegner im Level auf jeder einzelnen Tilemap spawnen können.

# Übergangsarray der die PackagedScenes läd, welche die Spielerpositionen enthalten
# soll ersetzt werden durch einen automatischen Path, der zu einem Ordner führt, 
# der die Szenen gespeichert hat
var playerpositions: Array
# Übergangsarray der die PackagedScenes läd, welche die Enemys enthalten
# soll ersetzt werden durch einen automatischen Path, der zu einem Ordner führt, 
# der die Szenen gespeichert hat
var enemys: Array

func _ready() -> void:
	randomize()
	instance_playerpositions()
	instance_enemys()


func instance_playerpositions() -> void:
	playerpositions.shuffle()
	var new_playerpositions: Node = playerpositions[0].instance()
	get_parent().add_child(new_playerpositions)


func instance_enemys() -> void:
	enemys.shuffle()
	var new_enemys: Node = enemys[0].instance()
	get_parent().add_child(new_enemys)
