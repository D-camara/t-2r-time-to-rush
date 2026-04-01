# Prototipo Atual

Leia este arquivo quando a tarefa depender do estado real e implementado do jogo.

## Base Tecnica

- Engine: Godot 4.6
- Physics: Jolt Physics
- Cena principal atual: `res://scenes/player/move.tscn`
- Autoload atual: `res://systems/input/input_manager.gd`

## Loop Atual da Rodada

O loop atual e controlado por `scripts/game/round_manager.gd`.

Estados:

- `COUNTDOWN`
- `PLAYING`
- `FUGITIVE_WIN`
- `POLICE_WIN`

Valores atuais exportados:

- `round_duration = 45.0`
- `pre_round_countdown = 3.0`
- `capture_distance = 1.75`
- `danger_distance = 6.0`
- `low_time_threshold = 12.0`
- `fugitive_speed = 11.0`
- `fugitive_acceleration = 13.5`
- `police_speed = 11.9`
- `police_acceleration = 9.2`
- `infected_hunter_speed = 10.4`
- `infected_hunter_acceleration = 8.6`

## Regras Implementadas

- Existem 3 personagens ativos hoje: `PERSONAGEM`, `FUGITIVO_2` e `POLICIAL`.
- Os fugitivos vencem se ao menos um continuar livre ate o cronometro zerar.
- A policia vence se todos os fugitivos forem infectados antes do fim do tempo.
- Captura hoje nao remove o fugitivo da partida: ele vira um pegador infectado.
- Fugitivos infectados continuam jogaveis e passam a cacar o ultimo fugitivo livre.
- Ao final da rodada, o jogo espera `R` para recarregar a cena atual.

## Input Atual

Mapeamento atual mostrado pelo HUD:

- `WASD`: fugitivo 1
- `Controle 1`: policial
- `Controle 2`: fugitivo 2
- `R`: reiniciar rodada

Fallback de teclado do policial:

- setas direcionais via `police_left`, `police_right`, `police_foward`, `police_backwards`

`systems/input/input_manager.gd` le o analogico esquerdo do controle e aplica deadzone.

## Camera Atual

`scripts/camera/shared_camera.gd`:

- acompanha fugitivos e policial juntos
- calcula midpoint entre personagens
- aplica look-ahead pela velocidade media
- sobe a camera conforme a separacao aumenta
- suaviza posicao e foco

## HUD Atual

`scripts/ui/round_hud.gd` mostra:

- tempo restante
- quantidade de fugitivos livres
- estado textual da rodada
- dica de controles

Mensagens atuais enfatizam countdown, perigo, ultimos segundos, contagio e reinicio manual.

## Observacoes de Design Implicito

- O prototipo atual e um jogo de perseguicao local rapido e legivel.
- O contagio cria snowball e muda a leitura da rodada sem trocar de cena.
- O cronometro e a regra central do jogo hoje.
