extends Node2D
class_name Levelbase

#GENERELL VARIABLES

#Nodepaths
onready var selectioninterface = get_node("CanvasLayer/Selectioninterface")
onready var enemy_node:Node = null
onready var tiles:Node = null


#Packed Scenes
var errorsymbol = preload("res://effects/Errorsymbol/Errorsymbol.tscn")
var player_lost_screen = preload("res://UIs/PlayerLooseScreen.tscn")


#PREPARATION PHASE VARIABLES

var preparation_phase = true #signals if its preparation phase or not

#Grid variables
var tile_positions:Array = [] #positions of all tiles
var tile_instances:Array = [] #instances of all tiles
var fielded_tiles:Array = [] #positions of all tiles with a unit fielded

#Unit placing variables
var a_unit_is_selected_for_placement = false #if a unit is selected for potential placement its true
var currently_selected_unit_for_placement #Objectreferenz to the selected unit
var currently_selected_unit_rel_tile_positions:Array = [] #relative positions a fielded unit takes up (relative to potential position)

#BATTLE PHASE VARIABLES

#Enemys
var all_enemys:Array = [] #instances of all enemys of this level

#Player team
var player_team:Array

#signals
signal game_over #gets emitted if a unit dies and its team is empty


#PREPARATION PHASE FUNCTIONS
func _ready():
	
	construct_level() #sets a random tilemap, possible spawn tiles, enemys, enemys constallations
	
	get_all_tile_information() #collects all tile data, e.g. position, instances
	get_all_enemy_information() #collects all enemy data, e.g. instances
	
	
	#signals
	Signals.connect("wants_to_place_a_unit", self, "_on_wanting_to_place_a_unit")
	Signals.connect("I_am_hovered", self, "_on_tile_hovered")
	Signals.connect("I_was_selected_for_an_action", self, "_on_tile_is_selected_for_an_action")
	Signals.connect("I_died", self, "_on_unit_died")
	connect("game_over", self, "on_game_over")
	
	
func construct_level():
	set_a_tilemap(LevelConstructor.get_tilemap())
	instance_player_positions(LevelConstructor.get_player_positions())
	instance_all_enemys_of_this_level(LevelConstructor.get_enemys_and_enemy_positions())
	
	
func set_a_tilemap(tilemap_res):
	print(tilemap_res)
	$TileMap.set_tileset(tilemap_res)
	
func instance_player_positions(player_positions_scene):
	var player_positions  = player_positions_scene.instance()
	add_child(player_positions)
	
func instance_all_enemys_of_this_level(enemys_scene):
	var new_enemys = enemys_scene.instance()
	add_child(new_enemys)
	

func get_all_tile_information():
	tiles = get_node("Tiles")
	for child in tiles.get_children():
		tile_instances.append(child)
		tile_positions.append(child.position)
	
	
func get_all_enemy_information():
	enemy_node = get_node("Enemys")
	for child in enemy_node.get_children():
		all_enemys.append(child)
		child.set_turn_info("ENEMY")

	#connected to a signal of the selectioninterface
func _on_wanting_to_place_a_unit(unit_scene):
	print(unit_scene)
	instance_a_unit_for_visualisation(unit_scene)
	
	#gets a visual copy of the chosen unit to place on the grid
func instance_a_unit_for_visualisation(unit_scene):
	a_unit_is_selected_for_placement = true
	var new_unit = unit_scene.instance()
	currently_selected_unit_for_placement = new_unit
	new_unit.position = get_global_mouse_position()
	new_unit.scale *= Vector2(3,3)
	new_unit.set_spawn_environment(1)
	add_child(new_unit)
	currently_selected_unit_rel_tile_positions = new_unit.relative_positions.duplicate()
	
	#connects to a individual tile scene, positions chosen unit on a grid tile
func _on_tile_hovered(tileposition):
	print(tileposition)
	if a_unit_is_selected_for_placement:
		currently_selected_unit_for_placement.position = tileposition
	
	#connects to a individual tile scene, that is clicked upon
	#readys the set unit for the game
func _on_tile_is_selected_for_an_action(tileposition):
	if a_unit_is_selected_for_placement:
		if tiles_are_free(currently_selected_unit_rel_tile_positions, tileposition):
			add_unit_to_team()
			currently_selected_unit_for_placement.set_unit_to_tile(tileposition)
#			currently_selected_unit_for_placement.set_turn_info(turn)
			organize_fielded_tiles(currently_selected_unit_rel_tile_positions, tileposition)
			Signals.emit_signal("Player_fielded_a_unit", currently_selected_unit_for_placement)
			currently_selected_unit_for_placement = null
			currently_selected_unit_rel_tile_positions.clear()
			a_unit_is_selected_for_placement = false
		else: 
			instance_error_symbol(currently_selected_unit_rel_tile_positions, tileposition)


	#checks if the tiles, that the selected unit would need are available
func tiles_are_free(unit_rel_positions, new_unit_position):
	var overlapping_tiles = check_for_overlapping_tiles(unit_rel_positions, new_unit_position)
	if overlapping_tiles.empty():
		return true
	return false
	
	#return the tiles that would overlap between tiles that would be needed for a new unit and are already fielded
func check_for_overlapping_tiles(unit_rel_positions, new_unit_position):
	var overlapping_tiles:Array = []
	var new_unit_definitive_tiles:Array = calc_definitive_positions(unit_rel_positions, new_unit_position)
	for unit_pos in new_unit_definitive_tiles:
		for tilepos in fielded_tiles:
			if unit_pos == tilepos:
				overlapping_tiles.append(unit_pos)
	return overlapping_tiles

	#adds the tiles to a array of all tiles that are fielded with a unit, when a unit is succesfully placed
func organize_fielded_tiles(unit_rel_positions, new_unit_position):
	var new_unit_definitive_tiles:Array = calc_definitive_positions(unit_rel_positions, new_unit_position)
	for unit_pos in new_unit_definitive_tiles:
		fielded_tiles.append(unit_pos)

	#calculates the positions a unit takes up based on its relative positions
func calc_definitive_positions(unit_rel_positions, new_unit_position):
	var definitiv_positions:Array = []
	for rel_pos in unit_rel_positions:
		var new_pos = new_unit_position + rel_pos
		definitiv_positions.append(new_pos)
	return definitiv_positions

	#tiles that are not valid for a new unit show a error symbol
func instance_error_symbol(needed_unit_positions, new_unit_position):
	var overlapping_tiles = check_for_overlapping_tiles(needed_unit_positions, new_unit_position)
	for pos in overlapping_tiles:
		var new_error_symbol = errorsymbol.instance()
		new_error_symbol.position = pos
		add_child(new_error_symbol)


#BATTLE PHASE FUNCTIONS

	#adds a placed unit into a player team array
func add_unit_to_team():
	player_team.append(currently_selected_unit_for_placement)

	#connects to the unit who died
func _on_unit_died(unit):
	delete_unit_from_team(unit, unit.team)
	check_if_level_is_over(unit.team)
	
	#checks if the level is over, if no units are remaining in any team
func check_if_level_is_over(unit_team):
	if unit_team == "PLAYER":
		if player_team.empty():
			emit_signal("game_over", "PLAYER")
	elif unit_team == "ENEMY":
		if all_enemys.empty():
			emit_signal("game_over", "ENEMY")
		
	#deletes a unit, that dies in battle from the corresponding team array
func delete_unit_from_team(unit, team):
	if team == "PLAYER":
		player_team.erase(unit)
		update_enemy_teams()
	elif team == "ENEMY":
		all_enemys.erase(unit)
		update_enemy_teams()
		
		
#BATTLE INITIALIZATION FUNCTIONS AND ONGOING BATTLE FUNCTIONS
func _on_StartGameButton_pressed():
	update_enemy_teams()
	activate_units()
	delete_all_tiles()
	print("Start")

	#sends all units the their corresponding enemys
func update_enemy_teams():
	for player_unit in player_team:
		player_unit.get_enemy_team(all_enemys)
	for enemy_unit in all_enemys:
		enemy_unit.get_enemy_team(player_team)

	#activates battleprocess in units
func activate_units():
	for player_unit in player_team:
		player_unit.start_battle_phase()
	for enemy_unit in all_enemys:
		enemy_unit.start_battle_phase()

	#clears all the tiles for visibilitie
func delete_all_tiles():
	for i in tiles.get_children():
		tiles.remove_child(i)
		i.queue_free()
	tile_positions.clear()
	
#GAME ENDING FUNCTIONS
	#if the battle is finished, this function organizes the finish
func on_game_over(looser):
	disable_and_release_all_units()
	if looser == "PLAYER":
		spawn_player_lost_screen()
	elif looser == "ENEMY":
		pass

	#sets process of all units false and releases them (queues free)
func disable_and_release_all_units():
	if !player_team.empty():
		for unit in player_team:
			unit.set_process(false)
			unit.queue_free()
	if !all_enemys.empty():
		for unit in all_enemys:
			unit.set_process(false)
			unit.queue_free()
			
	#instances a screen that shows, that the player lost, the players rewards and stats?
func spawn_player_lost_screen():
	var new_loose_screen = player_lost_screen.instance()
	$CanvasLayer.add_child(new_loose_screen)
	
#INPUTRELATED FUNCTIONS
	
	#if a unit shall not be selected
func deselect_selected_unit():
	a_unit_is_selected_for_placement = false
	currently_selected_unit_for_placement.queue_free()

	#if a fielded unit shall be removed, identifies the clicked unit
func identify_unit_clicked(tileposition):
	var return_unit = null
	for unit in player_team:
		if unit.position == tileposition:
			return_unit = unit
			return return_unit
	return return_unit

	
	#identifies the clicked tile
func identify_tile_clicked(mousepos):
	var smallest:float = 100000
	var return_pos = null
	for tile in tile_positions:
		var diff = tile.distance_to(mousepos)
		if diff < smallest:
			smallest = diff
			return_pos = tile
	return return_pos
	
	#checks if a unit was meant to be clicked
func a_placed_unit_was_clicked(mousepos):
	var clicked_tile = identify_tile_clicked(mousepos)
	var clicked_unit = identify_unit_clicked(clicked_tile)
	if clicked_unit == null:
		return false
	else:
		return true
		
	#clicked fielded unit gets removed und fielded tiles restored
func delete_boarded_unit(unit):
	player_team.erase(unit)
	readd_boarded_field(unit.relative_positions, unit.position)
	print(unit.relative_positions, unit.position)
	unit.queue_free()
	
	#previously fielded tiles are restored
func readd_boarded_field(unit_rel_positions, unit_position):
	var definitive_positions:Array = calc_definitive_positions(unit_rel_positions, unit_position)
	for pos in definitive_positions:
		var index = fielded_tiles.find(pos)
		fielded_tiles.remove(index)
	
	
func _input(event):
	if event.is_action_pressed("mouse_button_right"):
		if preparation_phase:
			if a_unit_is_selected_for_placement:
				deselect_selected_unit()
			elif a_placed_unit_was_clicked(event.position):
				var clicked_unit = identify_unit_clicked(identify_tile_clicked(event.position))
				delete_boarded_unit(clicked_unit)
