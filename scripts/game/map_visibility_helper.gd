extends Node3D

@export var disable_map_shadows: bool = true

func _ready() -> void:
	_prepare_map_readability(self)

func _prepare_map_readability(node: Node) -> void:
	for child: Node in node.get_children():
		if child is GeometryInstance3D:
			var geometry: GeometryInstance3D = child
			if disable_map_shadows:
				geometry.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

		_prepare_map_readability(child)
