extends TileMap
class_name LevelBackgroundBase

# Basisklasse für den Levelbackground bestehend aus einem Tilemap Node und 
# einem NavigationsPolygon Node, dieses Skript organisiert, welche Spielerpositionen
# und Gegner im Level auf jeder einzelnen Tilemap spawnen können.

# Übergangsarray der die PackagedScenes läd, welche die Spielerpositionen enthalten
# soll ersetzt werden durch einen automatischen Path, der zu einem Ordner führt, 
# der die Szenen gespeichert hat
var playerpositions_of_this_level: Array = [] setget _set_playerpositions_of_this_level
# Übergangsarray der die PackagedScenes läd, welche die Enemys enthalten
# soll ersetzt werden durch einen automatischen Path, der zu einem Ordner führt, 
# der die Szenen gespeichert hat
var enemys_of_this_level: Array = [] setget _set_enemys_of_this_level

var child_count: int = 0

signal enemys_set
signal playerpositions_set


func _ready() -> void:
	randomize()
	connect("enemys_set", self, "_on_enemys_set")
	connect("playerpositions_set", self, "_on_playerpositions_set")
	connect("child_entered_tree", self, "_on_child_entered_tree")


func _set_enemys_of_this_level(enemys: Array) -> void:
	enemys_of_this_level = enemys
	emit_signal("enemys_set")


func _set_playerpositions_of_this_level(playerpositions: Array) -> void:
	playerpositions_of_this_level = playerpositions
	emit_signal("playerpositions_set")


func _on_playerpositions_set() -> void:
	instance_playerpositions()


func _on_enemys_set() -> void:
	instance_enemys()


func instance_playerpositions() -> void:
	playerpositions_of_this_level.shuffle()
	var new_playerpositions: Node = playerpositions_of_this_level[0].instance()
	call_deferred("add_child", new_playerpositions)
	Signals.emit_signal("levels_playerpositions_instanced", "PLAYERPOSITIONS")


func instance_enemys() -> void:
	enemys_of_this_level.shuffle()
	var new_enemys: Node = enemys_of_this_level[0].instance()
	call_deferred("add_child", new_enemys)
	Signals.emit_signal("levels_enemys_instanced", "ENEMYS")


func _on_child_entered_tree(childnode: Node) -> void:
	child_count += 1
	if child_count == 2:
		Signals.emit_signal("level_instanced")
