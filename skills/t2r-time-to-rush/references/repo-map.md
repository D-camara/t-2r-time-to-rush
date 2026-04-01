# Mapa do Repositorio

Leia este arquivo quando a tarefa depender de localizar sistemas ou decidir quais arquivos sao canonicos.

## Arquivos Canonicos do Prototipo Atual

- `project.godot`
- `scenes/player/move.tscn`
- `scripts/game/round_manager.gd`
- `scripts/player/fugitive_player.gd`
- `scripts/player/police_player.gd`
- `scripts/camera/shared_camera.gd`
- `scripts/ui/round_hud.gd`
- `systems/input/input_manager.gd`

## Cena Principal Atual

`scenes/player/move.tscn` contem, entre outros:

- `PERSONAGEM`
- `CAMERA`
- `POLICIAL`
- `FUGITIVO_2`
- `HUD`
- `FUGITIVE_SPAWN`
- `FUGITIVE_2_SPAWN`
- `POLICE_SPAWN`
- `SAFETY_FLOOR`
- `GridMap`
- `MOVEIS`

Trate essa cena como o centro do prototipo jogavel atual.

## Responsabilidades

- `round_manager.gd`: estado da rodada, timer, vitoria, derrota, spawns, contagio
- `fugitive_player.gd`: movimento do fugitivo, stun, captura, infeccao, paleta visual
- `police_player.gd`: movimento do policial e input
- `shared_camera.gd`: enquadramento dinamico dos personagens
- `round_hud.gd`: timer, status e hint de controles
- `input_manager.gd`: leitura padrao de joypad

## Arquivos Legados ou Experimentais

Existem varios arquivos de teste e historico no repositorio, como:

- `scripts/player/personagem.gd`
- `scripts/player/player.gd`
- varios `teste.gd` em `scenes/`, `scripts/` e `systems/`

Eles podem ajudar a recuperar ideias antigas, mas nao devem virar referencia principal sem indicacao explicita do usuario.

## Skills no Projeto

Ja existe uma skill generica em `skills/SKILL.md`.
Use `skills/t2r-time-to-rush/` quando a tarefa for especificamente sobre este jogo e este repositorio.
