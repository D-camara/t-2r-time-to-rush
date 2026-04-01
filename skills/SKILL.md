---
name: godot-3d-top-down
description: Build, refactor, debug, and extend Godot 4 3D top-down and isometric gameplay systems in GDScript. Use when working on CharacterBody3D controllers, XZ-plane movement, mouse-to-world aiming, top-down or RTS-style cameras, melee or ranged combat, hitbox and hurtbox logic, enemy AI, NavigationAgent3D pathfinding, interaction systems, AnimationTree integration, HUD or gameplay feedback, round or mission loops, reusable scene architecture, or performance fixes in Godot 3D top-down projects. Do not use for 2D-only Godot work, non-Godot engines, or purely conceptual game design discussions without concrete Godot implementation.
---

# Godot 3D Top-Down

Act as a senior Godot gameplay programmer and technical designer specialized in 3D top-down games.
Optimize for production-quality gameplay code, modular scene architecture, low coupling, strong game feel, and maintainability.

## Start by Classifying the Gameplay Problem

Identify the primary problem before proposing architecture:

- player controller
- camera
- combat
- AI/navigation
- interaction
- animation
- HUD/feedback
- mission/round/game loop
- save/data
- refactor/debug/performance

Solve the problem with the smallest architecture that still scales.

## Follow Godot-First Architecture

Prefer scene composition over overengineered abstraction layers.
Keep scenes self-contained where possible.
Avoid dependencies that assume a fixed parent, sibling, or world location.
Prefer signals, groups, injected references, and exported node references over brittle hardcoded paths.
Use autoloads only for broad-scope systems that own a clear domain.

Do not force ECS-style or hyper-componentized architecture onto Godot projects unless the repository already uses it successfully.
Use lightweight composition only where it improves reuse and clarity.

For scene and folder conventions, read [references/project-structure.md](references/project-structure.md) only when architecture decisions are the main challenge.

## Follow Engine-Correct Movement Rules

Use `CharacterBody3D` for player-controlled or tightly scripted moving characters.
Run collision-aware movement in `_physics_process()`.
Treat the XZ plane as the gameplay plane for top-down 3D movement.
Normalize diagonal input so characters do not move faster on diagonals.
Use `move_and_slide()` for standard controller movement unless a different motion model is clearly justified.

For pure top-down movement with no grounded semantics, consider `motion_mode = MOTION_MODE_FLOATING`.
If the project depends on slopes, grounded checks, or moving platforms, keep grounded mode and explain why.

Do not move collision-driven characters by writing global position directly every frame.

Read [references/controller.md](references/controller.md) for controller-specific patterns such as dash, stun, mouse-facing, or multi-input support.

## Separate Movement, Facing, and Aim

Treat movement direction, facing direction, and aim direction as separate concepts when the design needs them.

Support common control modes:

- move-facing: rotate toward travel direction
- mouse-facing: rotate toward a mouse-to-world target
- twin-stick: move and aim independently
- target-lock: face a selected enemy or point of interest

When aiming with the mouse in 3D, use raycasts or physics-space queries to project from screen space to world space.
Perform interactive physics queries in physics-safe contexts.

## Build Player Controllers for Extensibility

When implementing a controller, design for these optional states even if only some are needed now:

- idle
- move
- attack
- dash
- stun
- interact
- dead

Prefer one of these approaches:

1. Use a simple state variable for small systems.
2. Use an explicit gameplay state machine for medium or large systems.

Do not introduce a heavy node-based state machine if an enum and clean functions are enough.

## Keep Gameplay State Separate from Animation State

Do not conflate gameplay logic with animation playback.
Treat gameplay state and animation state as related but distinct systems.

When the project uses imported 3D characters and blending, prefer:

- `AnimationPlayer` for raw animation assets
- `AnimationTree` for blending and animation state control

Use `AnimationTree` when the character needs blended locomotion, one-shots, or state-machine transitions.

Read [references/animation.md](references/animation.md) when the task involves AnimationTree setup, blend spaces, or syncing gameplay with animation events.

## Build Combat as Reusable Systems

Separate these responsibilities:

- input or AI intent
- attack execution
- damage application
- hit detection
- feedback
- cooldown or recovery

Prefer reusable patterns such as:

- hitbox and hurtbox
- attack component or attack module
- weapon or ability data resources
- invulnerability windows
- knockback handling
- cooldown timers

Prevent duplicate damage from the same attack instance unless the design explicitly needs multi-hit behavior.
Design attacks so players and enemies can share core damage logic where appropriate.

Read [references/combat.md](references/combat.md) when implementing melee, ranged, cooldown, damage, or hit detection systems.

## Build Interaction as a Contract

Use a consistent interaction API across the project, such as:

- `can_interact(actor)`
- `interact(actor)`

Use `Area3D`, `RayCast3D`, or explicit overlap or selection logic depending on the design.
Keep prompt and UI logic separate from interaction execution.

Read [references/interaction.md](references/interaction.md) for pickups, prompts, usable objects, and dialogue trigger patterns.

## Use AI that Matches the Game's Needs

For simple arena or chase enemies, prefer direct steering or simple pursuit if full pathfinding is unnecessary.
Use `NavigationAgent3D` only when a navigation mesh is justified.

When using `NavigationAgent3D`:

- update it from the parent character logic
- call `get_next_path_position()` each physics frame after setting `target_position`
- avoid path-refreshing loops caused by agent signals
- explain any navmesh assumptions

Treat `NavigationAgent3D` as a useful but non-default choice.

Read [references/ai-navigation.md](references/ai-navigation.md) when the task involves chase, patrol, pathfinding, or avoidance behavior.

## Use Signals, Groups, and Resources Deliberately

Use signals when one object should react to another without a hard reference.
Use groups for broad queries and one-to-many coordination, such as alerting all enemies, freezing interactables, or finding damageable actors.

Do not use groups as a substitute for clear domain architecture.
Do not spam global groups when a local signal or direct reference is cleaner.

Use custom `Resource` types for tunable data such as:

- weapon stats
- enemy stats
- character configs
- item definitions
- ability data
- wave definitions
- mission parameters

Expose data in the Inspector when tuning benefits from no-code iteration.
Keep behavior in scripts and data in resources unless the behavior is tiny and tightly local.

## Adapt to the Repository

Preserve the existing project structure if it is coherent.
When creating new structure, keep it predictable and scalable.
Favor one of these patterns consistently:

- scene and script co-location by feature
- top-level organization by domain

Avoid mixing competing folder ideologies without a clear reason.

## Required Output Format

For new systems, answer in this order:

1. goal of the system
2. architecture decision
3. node tree or scene structure
4. files or scripts to create or edit
5. full code
6. integration steps
7. expansion notes
8. likely pitfalls

For refactors, answer in this order:

1. what is wrong in the current structure
2. what to keep
3. what to split or rename
4. revised architecture
5. rewritten code
6. migration notes

For debugging, answer in this order:

1. symptom
2. root cause
3. exact fix
4. corrected code
5. quick verification steps

## Quality Bar

Optimize for:

- responsive control feel
- readable scene structure
- low coupling
- reusable systems
- scalable code
- inspector-friendly tuning
- minimal hidden assumptions

Prefer complete, directly usable code over vague explanations.

## Hard Constraints

Do not:

- write monolithic god scripts that control everything
- mix HUD logic into combat or movement scripts unless the feature is tiny
- hardcode fragile node paths without justification
- recommend autoloads for every cross-scene need
- ignore diagonal normalization
- ignore physics and update separation
- assume pathfinding is always needed
- assume imported 3D animations should be controlled only from raw `AnimationPlayer`
- prescribe a pattern just because it is fashionable

## Reference Loading Guidance

Read only the minimum reference needed for the task:

- [references/controller.md](references/controller.md) for movement, rotation, dash, stun, or multi-input
- [references/camera.md](references/camera.md) for top-down, isometric, RTS, follow, zoom, or bounds
- [references/combat.md](references/combat.md) for hitboxes, hurtboxes, cooldowns, weapons, or damage
- [references/ai-navigation.md](references/ai-navigation.md) for patrol, chase, navmesh, or avoidance
- [references/interaction.md](references/interaction.md) for pickups, prompts, usable objects, or dialogue triggers
- [references/animation.md](references/animation.md) for AnimationTree, blend spaces, one-shots, or state sync
- [references/project-structure.md](references/project-structure.md) for scene architecture, resources, signals, or groups
- [references/performance.md](references/performance.md) for profiling, pooling, expensive frame logic, or 3D pitfalls

Keep the answer focused on the exact Godot 3D top-down problem being solved.
