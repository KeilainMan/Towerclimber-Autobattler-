extends Node2D
class_name Levelbase

#GENERELL VARIABLES

#Nodepaths
onready var selectioninterface: Node = get_node("CanvasLayer/Selectioninterface")
onready var enemy_node: Node = null
onready var tiles: Node = null
onready var units_node: Node = get_node("Units")


#Packed Scenes
var errorsymbol: PackedScene = preload("res://effects/Errorsymbol/Errorsymbol.tscn")
var player_lost_screen: PackedScene = preload("res://UIs/PlayerLooseScreen.tscn")


#PREPARATION PHASE VARIABLES

var preparation_phase: bool = true #signals if its preparation phase or not

#Grid variables
var tile_positions: Array = [] #positions of all tiles
var tile_instances: Array = [] #instances of all tiles
var fielded_tiles: Array = [] #positions of all tiles with a unit fielded

#Unit placing variables
var a_unit_is_selected_for_placement: bool = false #if a unit is selected for potential placement its true
var currently_selected_unit_for_placement #Objectreferenz to the selected unit

#BATTLE PHASE VARIABLES

#Enemys
var all_enemys: Array = [] #instances of all enemys of this level

#Player team
var player_team: Array

#signals
signal game_over() #gets emitted if a unit dies and its team is empty


#PREPARATION PHASE FUNCTIONS
func _ready() -> void:
	#signals
	Signals.connect("wants_to_place_a_unit", self, "_on_wanting_to_place_a_unit")
	Signals.connect("I_am_hovered", self, "_on_tile_hovered")
	Signals.connect("I_was_selected_for_an_action", self, "_on_tile_is_selected_for_an_action")
	Signals.connect("I_died", self, "_on_unit_died")
	Signals.connect("already_died_please_remove", self, "_on_unit_died_and_wants_to_be_removed")
	Signals.connect("level_instanced", self, "_on_level_instanced")
	connect("game_over", self, "on_game_over")


func instance_level_number_x(level: int) -> void:
	var newly_build_level = LevelConstructorOrganizer.initiate_level_construction(level)
	var new_level = newly_build_level.instance()
	add_child(new_level)
	move_child(new_level, 0)



func _on_level_instanced():
	print("instanced")
	_move_enemy_nodes_into_the_right_place()
	_gather_all_information()


func _move_enemy_nodes_into_the_right_place() -> void:
	var enemy_node: Node = get_node("TileMap").get_node("Enemys")
	for child in enemy_node.get_children():
		print(child, " ", enemy_node)
		enemy_node.remove_child(child)
		units_node.add_child(child)
		child.set_owner(units_node)
	enemy_node.queue_free()


func _gather_all_information():
	_gather_all_tile_information()
	_gather_all_enemy_information()


func _gather_all_tile_information() -> void:
	tiles = get_node("TileMap").get_node("Tiles")
	for child in tiles.get_children():
		tile_instances.append(child)
		tile_positions.append(child.position)


func _gather_all_enemy_information() -> void:
	for child in units_node.get_children():
		all_enemys.append(child)
		child.set_turn_info("ENEMY")


	#connected to a signal of the selectioninterface
func _on_wanting_to_place_a_unit(unit_scene: PackedScene) -> void:
	instance_a_unit_for_visualisation(unit_scene)


	#gets a visual copy of the chosen unit to place on the grid
func instance_a_unit_for_visualisation(unit_scene: PackedScene) -> void:
	a_unit_is_selected_for_placement = true
	var new_unit = unit_scene.instance()
	currently_selected_unit_for_placement = new_unit
	new_unit.position = get_global_mouse_position()
	new_unit.scale *= Vector2(3,3)
	new_unit.set_spawn_environment(1)
	units_node.add_child(new_unit)


	#connects to a individual tile scene, positions chosen unit on a grid tile
func _on_tile_hovered(tileposition: Vector2) -> void:
	if a_unit_is_selected_for_placement:
		currently_selected_unit_for_placement.position = tileposition


	#connects to a individual tile scene, that is clicked upon
	#readys the set unit for the game
func _on_tile_is_selected_for_an_action(tileposition: Vector2) -> void:
	if a_unit_is_selected_for_placement:
		if tile_is_free(tileposition):
			add_unit_to_team()
			currently_selected_unit_for_placement.set_unit_to_tile(tileposition)
#			currently_selected_unit_for_placement.set_turn_info(turn)
			organize_fielded_tiles(tileposition)
			Signals.emit_signal("Player_fielded_a_unit", currently_selected_unit_for_placement)
			currently_selected_unit_for_placement = null
			a_unit_is_selected_for_placement = false
		else: 
			instance_error_symbol(tileposition)


	# Checks if the selected tile for a new unit is already occupied with another unit
func tile_is_free(tile_position: Vector2) -> bool:
	for tilepos in fielded_tiles:
		if tile_position == tilepos:
			return false
	return true


	# adds the tiles to a array of all tiles that are fielded with a unit, when a unit is succesfully placed
func organize_fielded_tiles(new_unit_position: Vector2) -> void:
		fielded_tiles.append(new_unit_position)


	# tiles that are not valid for a new unit show a error symbol
func instance_error_symbol(new_unit_position) -> void:
		var new_error_symbol = errorsymbol.instance()
		new_error_symbol.position = new_unit_position
		add_child(new_error_symbol)


# BATTLE PHASE FUNCTIONS

	# adds a placed unit into a player team array
func add_unit_to_team() -> void:
	player_team.append(currently_selected_unit_for_placement)


	# connects to the unit who died
func _on_unit_died(unit: Unitbase) -> void:
	delete_unit_from_team(unit, unit.team)
	check_if_level_is_over(unit.team)


	# checks if the level is over, if no units are remaining in any team
func check_if_level_is_over(unit_team: String) -> void:
	if unit_team == "PLAYER":
		if player_team.empty():
			emit_signal("game_over", "PLAYER")
	elif unit_team == "ENEMY":
		if all_enemys.empty():
			emit_signal("game_over", "ENEMY")


	# deletes a unit, that dies in battle from the corresponding team array
func delete_unit_from_team(unit: Unitbase, team: String) -> void:
	if team == "PLAYER":
		player_team.erase(unit)
	elif team == "ENEMY":
		all_enemys.erase(unit)


# BATTLE INITIALIZATION FUNCTIONS AND ONGOING BATTLE FUNCTIONS
func _on_StartGameButton_pressed() -> void:
	update_enemy_teams()
	activate_units()
	delete_all_tiles()
	print("Start")


	# sends all units the their corresponding enemys
func update_enemy_teams() -> void:
	for player_unit in player_team:
		player_unit.set_current_enemy_team(all_enemys)
	for enemy_unit in all_enemys:
		enemy_unit.set_current_enemy_team(player_team)


	# activates battleprocess in units
func activate_units() -> void:
	for player_unit in player_team:
		player_unit.start_battle_phase()
	for enemy_unit in all_enemys:
		enemy_unit.start_battle_phase()


	# clears all the tiles for visibilitie
func delete_all_tiles() -> void:
	for i in tiles.get_children():
		tiles.remove_child(i)
		i.queue_free()
	tile_positions.clear()


# GAME ENDING FUNCTIONS
	# if the battle is finished, this function organizes the finish
func on_game_over(looser: String) -> void:
	#disable_and_release_all_units()
	if looser == "PLAYER":
		spawn_player_lost_screen()
	elif looser == "ENEMY":
		pass


	# sets process of all units false and releases them (queues free)
#func disable_and_release_all_units() -> void:
#	if !player_team.empty():
#		for unit in player_team:
#			unit.set_state(UnitState.CELEBRATING)
#	if !all_enemys.empty():
#		for unit in all_enemys:
#			unit.set_state(UnitState.CELEBRATING)


	# instances a screen that shows, that the player lost, the players rewards and stats?
func spawn_player_lost_screen() -> void:
	var new_loose_screen = player_lost_screen.instance()
	$CanvasLayer.add_child(new_loose_screen)


# INPUTRELATED FUNCTIONS
	
	# if a unit shall not be selected
func deselect_selected_unit() -> void:
	a_unit_is_selected_for_placement = false
	currently_selected_unit_for_placement.queue_free()


	# if a fielded unit shall be removed, identifies the clicked unit
func identify_unit_clicked(tileposition: Vector2):
	var return_unit = null
	for unit in player_team:
		if unit.position == tileposition:
			return_unit = unit
			return return_unit
	return return_unit


	# identifies the clicked tile
func identify_tile_clicked(mousepos: Vector2) -> Vector2:
	var smallest: float = 100000
	var return_pos: Vector2 = Vector2()
	for tile in tile_positions:
		var diff = tile.distance_to(mousepos)
		if diff < smallest:
			smallest = diff
			return_pos = tile
	return return_pos


	# checks if a unit was meant to be clicked
func a_placed_unit_was_clicked(mousepos: Vector2) -> bool:
	var clicked_tile = identify_tile_clicked(mousepos)
	var clicked_unit = identify_unit_clicked(clicked_tile)
	if clicked_unit == null:
		return false
	else:
		return true


	# clicked fielded unit gets removed und fielded tiles restored
func delete_boarded_unit(unit: Unitbase) -> void:
	player_team.erase(unit)
	Signals.emit_signal("Player_deleted_a_unit", unit)
	readd_boarded_field(unit.position)
	unit.queue_free()


	# previously fielded tiles are restored
func readd_boarded_field(unit_position: Vector2) -> void:
	fielded_tiles.erase(unit_position)


func _on_unit_died_and_wants_to_be_removed(unit: Unitbase) -> void:
	print("child_count: ", get_child_count())
	for child in units_node.get_children():
		print(child, unit)
		if child == unit:
			print(child, "gets removed")
			units_node.remove_child(child)


func _input(event):
	if event.is_action_pressed("mouse_button_right"):
		if preparation_phase:
			if a_unit_is_selected_for_placement:
				deselect_selected_unit()
			elif a_placed_unit_was_clicked(event.position):
				var clicked_unit = identify_unit_clicked(identify_tile_clicked(event.position))
				delete_boarded_unit(clicked_unit)
