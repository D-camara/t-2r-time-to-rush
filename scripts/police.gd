extends Node3D

@onready var red = $RedLight
@onready var blue = $BlueLight

func _ready():
	flash()

func flash():
	while true:

		red.light_energy = 8
		blue.light_energy = 0

		await get_tree().create_timer(0.15).timeout

		red.light_energy = 0
		blue.light_energy = 8

		await get_tree().create_timer(0.15).timeout
