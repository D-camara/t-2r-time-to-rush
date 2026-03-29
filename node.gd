extends Node

func _ready():
	var controles = Input.get_connected_joypads()
	print("Controles conectados:", controles)
	print("Quantidade:", controles.size())
