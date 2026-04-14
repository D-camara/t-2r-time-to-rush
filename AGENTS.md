# T2R Agent Guidance

## Preferred skills

- Use `t2r-time-to-rush` for project-specific context, canon, design intent, roadmap boundaries, and source-of-truth decisions.
- Use `t2r-godot-3d-top-down` for Godot 4 implementation decisions, gameplay architecture, controller logic, camera, HUD, round flow, refactors, debugging, and performance work in this repository.
- In most gameplay tasks for this repository, combine `t2r-time-to-rush` with `t2r-godot-3d-top-down`.

## When to use each skill

- Use `t2r-time-to-rush` when the task depends on what is already implemented in T2R, what is only documented, what belongs to roadmap, or which files are canonical.
- Use `t2r-godot-3d-top-down` when the task is mainly about how to implement something correctly in Godot.
- Use both when the task touches current T2R gameplay systems such as player movement, round loop, camera, HUD, input, balance, or refactors.

## Canonical files

Unless the user points elsewhere, treat these as the primary sources for the current playable prototype:

- `project.godot`
- `scenes/player/move.tscn`
- `scripts/game/round_manager.gd`
- `scripts/player/fugitive_player.gd`
- `scripts/player/police_player.gd`
- `scripts/camera/shared_camera.gd`
- `scripts/ui/round_hud.gd`
- `systems/input/input_manager.gd`

Treat files such as `teste.gd`, `player.gd`, `personagem.gd`, and other drafts as non-canonical unless the task explicitly targets them.

## Source of truth

When sources conflict, use this order:

1. Current code and scenes in the repository
2. `Projeto.docx` and the skill references derived from it, as planned design
3. Slides and PDFs, as pitch, tone, lore, and future vision

Do not silently merge conflicting sources.
Call out important divergences when they matter to the task.
Do not change current gameplay to match the design docs unless the user explicitly asks for that change.

## Project intent

Preserve these T2R goals unless the user asks otherwise:

- short, readable local asymmetric chase matches
- constant timer pressure
- clear role readability between fugitive, police, and infected chaser
- shared camera and HUD that improve readability instead of fighting it
- cyber-heist, neon-noir, urgency-driven identity

## Scope control

Do not silently add roadmap features that are mentioned in docs or pitch but are not clearly implemented yet, including:

- fourth player
- score system
- ranking
- limited lives
- closed class system
- item systems not already present
- police teleport as a gameplay feature
- automatic recall or restart loops

Treat these as future design unless the user explicitly requests implementation.

## Engineering rules

- Prefer small, testable, localized changes over broad refactors.
- Preserve existing responsibility boundaries between round manager, players, camera, HUD, and input manager.
- Keep tuning values exposed when balancing benefits from iteration.
- Avoid new globals or autoload-style systems unless the change clearly requires them.
- Prefer improving the current playable prototype over expanding scope.
