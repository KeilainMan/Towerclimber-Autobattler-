extends Node2D

#boardvariablen
var viewport_size:Vector2
var tile:PackedScene = preload("res://Gameboard/boardtile_new.tscn")
var tilesize:Vector2 = Vector2(32*4,32*4) 
var h_tilenumber = 10
var v_tilenumber = 7
var tile_positions:Array = []
var tiles:Array = [] #instanzen aller boardteile
var fielded_tiles:Array = [] #position aller schon belegten tiles

#effectpaths
var errorsymbol = preload("res://effects/Errorsymbol/Errorsymbol.tscn")


#organisationsvariablen
onready var selectioninterface = get_node("CanvasLayer/Selectioninterface")

#process triggervariablen
var a_unit_is_selected_for_placement = false

#gamevariablen
var currently_selected_unit_for_placement
var currently_selected_unit_rel_tile_positions:Array = []
var turn = "RED"
var red_team:Array
var blue_team:Array


func _ready():
	spawn_board()
	
	get_tree().root.connect("size_changed", self, "window_size_changed")
	selectioninterface.connect("wants_to_place_a_unit", self, "_on_wanting_to_place_a_unit")
	

func window_size_changed():
	spawn_board()
	
func spawn_board():
	delete_all_tiles()

	var viewport_x_2 = get_viewport().size.x/2
	var viewport_y_2 = get_viewport().size.y/2
#	var new_tilesize = get_tilesize(viewport_x_2, viewport_y_2)
	var x_spawn = viewport_x_2-tilesize.x*(h_tilenumber/2)
	var y_spawn = viewport_y_2-tilesize.y*(v_tilenumber/2)
	for i in v_tilenumber:
		var y_pos = y_spawn +tilesize.y * i
		for j in h_tilenumber:
			var x_pos = x_spawn + tilesize.x *j
			var tilepos = Vector2(x_pos,y_pos)
			tile_positions.append(tilepos)
			
	summon_board_tiles()


func delete_all_tiles():
	for i in $tiles.get_children():
		$tiles.remove_child(i)
		i.queue_free()
	tile_positions.clear()
	
	
func get_tilesize(viewport_x_2, viewport_y_2):
	var x_tilesize = ((viewport_x_2*2*6)/7)/h_tilenumber
	var y_tilesize = ((viewport_y_2*2*6)/7)/v_tilenumber
	return Vector2(x_tilesize, y_tilesize)
	
	
func summon_board_tiles():
	for pos in tile_positions:
		var board_tile = tile.instance()
		board_tile.position = pos
#		board_tile.scale *= (new_tilesize/board_tile.size)-Vector2(0.2,0.2)
		tiles.append(board_tile)
		$tiles.add_child(board_tile)



func _on_wanting_to_place_a_unit(unit_scene):
	instance_a_unit_for_visualisation(unit_scene)
	
	
func instance_a_unit_for_visualisation(unit_scene):
	a_unit_is_selected_for_placement = true
	var new_unit = unit_scene.instance()
	currently_selected_unit_for_placement = new_unit
	new_unit.position = get_global_mouse_position()
	new_unit.scale *= Vector2(3,3)
	add_child(new_unit)
	currently_selected_unit_rel_tile_positions = new_unit.relative_positions.duplicate()
	

func _on_tile_hovered(tileposition):
	if a_unit_is_selected_for_placement:
		currently_selected_unit_for_placement.position = tileposition
	
	
func _on_tile_is_selected_for_an_action(tileposition):
	if a_unit_is_selected_for_placement:
		if tiles_are_free(currently_selected_unit_rel_tile_positions, tileposition):
			add_unit_to_team()
			currently_selected_unit_for_placement.set_unit_to_tile(tileposition)
			currently_selected_unit_for_placement.set_turn_info(turn)
			organize_fielded_tiles(currently_selected_unit_rel_tile_positions, tileposition)
			currently_selected_unit_for_placement = null
			currently_selected_unit_rel_tile_positions.clear()
			a_unit_is_selected_for_placement = false
		else: 
			instance_error_symbol(currently_selected_unit_rel_tile_positions, tileposition)
			
	
func tiles_are_free(unit_rel_positions, new_unit_position):
	var overlapping_tiles = check_for_overlapping_tiles(unit_rel_positions, new_unit_position)
	if overlapping_tiles.empty():
		return true
	return false
	
	
func check_for_overlapping_tiles(unit_rel_positions, new_unit_position):
	var overlapping_tiles:Array = []
	var new_unit_definitive_tiles:Array = calc_definitive_positions(unit_rel_positions, new_unit_position, turn)
	for unit_pos in new_unit_definitive_tiles:
		for tilepos in fielded_tiles:
			if unit_pos == tilepos:
				overlapping_tiles.append(unit_pos)
	return overlapping_tiles


func organize_fielded_tiles(unit_rel_positions, new_unit_position):
	var new_unit_definitive_tiles:Array = calc_definitive_positions(unit_rel_positions, new_unit_position, turn)
	for unit_pos in new_unit_definitive_tiles:
		fielded_tiles.append(unit_pos)


func calc_definitive_positions(unit_rel_positions, new_unit_position, turn):
	var definitiv_positions:Array = []
	for rel_pos in unit_rel_positions:
		var new_pos = new_unit_position + rel_pos
		definitiv_positions.append(new_pos)
	return definitiv_positions


func instance_error_symbol(needed_unit_positions, new_unit_position):
	var overlapping_tiles = check_for_overlapping_tiles(needed_unit_positions, new_unit_position)
	for pos in overlapping_tiles:
		var new_error_symbol = errorsymbol.instance()
		new_error_symbol.position = pos
		add_child(new_error_symbol)
		
	
func add_unit_to_team():
	if turn == "RED":
		red_team.append(currently_selected_unit_for_placement)
	elif turn == "BLUE":
		blue_team.append(currently_selected_unit_for_placement)
		

func _on_unit_died(unit):
	delete_unit_from_team(unit, unit.team)
		

func delete_unit_from_team(unit, team):
	if team == "RED":
		red_team.erase(unit)
		update_enemy_teams()
	elif team == "BLUE":
		blue_team.erase(unit)
		update_enemy_teams()


func _on_ChangeTurnBotton_pressed():
	if turn == "RED":
		turn = "BLUE"
	

func _on_StartGameButton_pressed():
	update_enemy_teams()
	activate_units()
	delete_all_tiles()
	print("Start")


func update_enemy_teams():
	for red_unit in red_team:
		red_unit.get_enemy_team(blue_team)
	for blue_unit in blue_team:
		blue_unit.get_enemy_team(red_team)


func activate_units():
	for red_unit in red_team:
		red_unit.set_process(true)
	for blue_unit in blue_team:
		blue_unit.set_process(true)


func deselect_selected_unit():
	a_unit_is_selected_for_placement = false
	currently_selected_unit_for_placement.queue_free()


func identify_unit_clicked(tileposition, turn):
	var return_unit = null
	var team:Array = get_team(turn)
	for unit in team:
		if unit.position == tileposition:
			return_unit = unit
			return return_unit
	return return_unit
	
	
func get_team(turn):
	var team:Array
	if turn == "RED":
		team = red_team
	elif turn == "BLUE":
		team = blue_team
	return team
	
	
func identify_tile_clicked(mousepos):
	var smallest:float = 100000
	var return_pos = null
	for tile in tile_positions:
		var diff = tile.distance_to(mousepos)
		if diff < smallest:
			smallest = diff
			return_pos = tile
	return return_pos
	
	
func a_placed_unit_was_clicked(mousepos, turn):
	var clicked_tile = identify_tile_clicked(mousepos)
	var clicked_unit = identify_unit_clicked(clicked_tile, turn)
	if clicked_unit == null:
		return false
	else:
		return true
		

func delete_boarded_unit(unit, turn):
	if turn == "RED":
		red_team.erase(unit)
	elif turn == "BLUE":
		blue_team.erase(unit)
	readd_boarded_field(unit.relative_positions, unit.position)
	print(unit.relative_positions, unit.position)
	unit.queue_free()
	

func readd_boarded_field(unit_rel_positions, unit_position):
	var definitive_positions:Array = calc_definitive_positions(unit_rel_positions, unit_position)
	for pos in definitive_positions:
		var index = fielded_tiles.find(pos)
		fielded_tiles.remove(index)
	
	
func _input(event):
	if event.is_action_pressed("mouse_button_right"):
		if a_unit_is_selected_for_placement:
			deselect_selected_unit()
		elif a_placed_unit_was_clicked(event.position, turn):
			var clicked_unit = identify_unit_clicked(identify_tile_clicked(event.position), turn)
			delete_boarded_unit(clicked_unit, turn)

