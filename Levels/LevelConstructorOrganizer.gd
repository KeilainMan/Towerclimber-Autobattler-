extends Node

# Singleton
# Dieses Script organisiert welches Level geladen werden soll, dabei wird nur
# mit der Levelzahl signalisiert, welcher Levelhintergrund mit dazugehörigem 
# Navigationspolygon geladen wird. Jeder Levelhintergrund ist dann für das 
# Laden der passenden Spielfigurpositionen und entsprechenden Gegner zuständig

# Dieses Script delegiert dann in ein Unterscript, welche die Informationen zu
# den Levelhintergründen bereithält.

# an Array that contains PackedScenes that represent different tilemaps as root node,
# with their corresponding navigation polygons node
#var backgrounds_and_navigationpolys: Array = []

func _ready():
	randomize()


func initiate_level_construction(level: int) -> PackedScene:
	var found_tilemap = find_tilemap_according_to_level(level)
	return found_tilemap

func find_tilemap_according_to_level(level: int):
	if level > 0 && level <= 10:
		var new_Level_Background = LevelConstructor1To10.get_levelbackground_and_navigationpoly(level)
		return new_Level_Background
	elif level > 11 && level <= 20:
		var new_Level_Background = LevelConstructor11To20.get_levelbackground_and_navigationpoly(level)
		return new_Level_Background
	# ... bis level 100
