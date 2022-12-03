extends Node2D

#treeorganization
onready var gameboard 


var tilesize: Vector2 = Vector2(32*3,32*3) 
var selected: bool = false


signal I_was_selected_for_an_action
signal I_am_hovered

# Called when the node enters the scene tree for the first time.
func _ready():
	#gameboard = get_tree().get_root().get_node("Gameboard")
	$Selected.visible = false
	$blank.scale *= tilesize / $blank.texture.get_size()
	$Selected.scale *= tilesize / $Selected.texture.get_size()
	$Choice.rect_pivot_offset = $Choice.rect_size / 2
	$Choice.rect_scale *= tilesize / $blank.texture.get_size()

	
#	connect("I_was_selected_for_an_action", gameboard, "_on_tile_is_selected_for_an_action")
#	connect("I_am_hovered", gameboard, "_on_tile_hovered")


func _on_Choice_mouse_entered():
	selected = true
	$Selected.visible = true
	$AnimationPlayer.play("blinking")
	Signals.emit_signal("I_am_hovered", position)


func _on_Choice_mouse_exited():
	selected = false
	$Selected.visible = false
	$AnimationPlayer.stop()
	
	
func _input(event):
	if selected:
		if event.is_action_pressed("mouse_button_left"):
			Signals.emit_signal("I_was_selected_for_an_action", position)


func _on_Choice_pressed():
	pass # Replace with function body.
