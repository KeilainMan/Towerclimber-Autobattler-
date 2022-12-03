extends Node2D


#Nodevariablen
onready var guild_scene: Node = get_node("GuildLayer/Guild")
onready var city_interface_scene: Node = get_node("Cityinterfacelayer/Cityinterface")

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_OpenGuild_Btn_pressed() -> void:
	guild_scene.show()
