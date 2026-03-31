extends Area3D

@export var stun_duration: float = 2.0

# Sinal opcional para feedback externo (UI, som etc.)
signal trapped(actor)

func _ready() -> void:
	monitoring = true
	connect("body_entered", _on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.has_method("apply_trap_stun"):
		return
	body.apply_trap_stun(stun_duration)
	trapped.emit(body)
	# opcional: travar visualmente a armadilha
	$AnimationPlayer.play("Close") if has_node("AnimationPlayer") else null
	# desativar nova captura até rearmar
	monitoring = false
