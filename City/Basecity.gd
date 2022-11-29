extends Node2D


#Nodevariablen
onready var guild_scene = get_node("GuildLayer/Guild")
onready var city_interface_scene = get_node("Cityinterfacelayer/Cityinterface")

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_OpenGuild_Btn_pressed():
	print("Open Guild")
	guild_scene.show()
