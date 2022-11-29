extends Node



signal wants_to_place_a_unit(unit) #from interfacebutton in level to gameboard

signal I_am_hovered(position) #from a tile to the gameboard
signal I_was_selected_for_an_action(position) #from a tile to the gameboard

signal Player_fielded_a_unit(unit) #from gameboard to partybuffmanager
signal update_player_buff_hud(buffnumbers)

signal I_died(object) #from unitbase to gameboard
