extends PathFollow3D

# Velocidade com que o carro se move pelo caminho.
# Ajuste este valor para deixar o carro mais rápido ou mais lento.
@export var velocidade = 11.0 

func _process(delta):
	# Aumenta o progresso do carro ao longo do tempo
	progress += velocidade * delta
