@tool
extends GridMap

@export var floor_height: float = 0.5
@export var wall_height: float = 0.5
@export var rebuild_now: bool = false:
	set(value):
		if value:
			rebuild_now = false
			rebuild_collisions()

func rebuild_collisions() -> void:
	for child in get_children():
		if child.name.begins_with("AUTO_"):
			child.queue_free()

	for cell in get_used_cells():
		var item = get_cell_item(cell)

		var body := StaticBody3D.new()
		body.name = "AUTO_%s_%s_%s" % [cell.x, cell.y, cell.z]

		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()

		if item == 0:
			box.size = Vector3(1, wall_height, 0.2)
			body.position = map_to_local(cell)
			body.position.y += wall_height * 0.5

		elif item == 1:
			box.size = Vector3(1, floor_height, 1)
			body.position = map_to_local(cell)
			body.position.y += floor_height * 0.5

		else:
			continue

		shape.shape = box
		body.add_child(shape)
		add_child(body)
