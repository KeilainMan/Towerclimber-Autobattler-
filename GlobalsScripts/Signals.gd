extends Node

signal level_instanced()# emitted if all three levelparts are instanced

signal wants_to_place_a_unit(unit) # from interfacebutton in level to gameboard
signal unit_choosen() # from interfacebutton in level to selectioninterface

signal I_am_hovered(position) # from a tile to the gameboard
signal I_was_selected_for_an_action(position) # from a tile to the gameboard

signal Player_fielded_a_unit(unit) # from gameboard to partybuffmanager
signal Player_deleted_a_unit(unit) # from gameboard to partybuffmanager
signal update_player_buff_hud(buffnumbers) # from gameboard to partybuffmanager

signal I_died(object) # from unitbase to gameboard
signal already_died_please_remove(object) #connects to the level and will remove 
		# the this child when it died
signal gold_changed(current_amount) #emitted from runmanager if the gold value changed
signal unit_purchased(unit_scene) #emitted, wenn eine Unit im Shop gekauft wird
signal gold_spend(amount_spend) #emitted, wenn gold ausgegeben wird

signal proceed_to_next_level() #emitted, wenn die Shop-Phase beendet ist
signal I_need_a_party_to_display() #emitted, when the Selectioninterface is ready and needs a party
