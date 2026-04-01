# Controller Reference

Read this file when the task is primarily about player movement, facing, dash, stun, input handling, or mouse aiming.

## Core Rules

- Use `CharacterBody3D`.
- Move in `_physics_process(delta)`.
- Treat XZ as the gameplay plane.
- Normalize input before applying speed.
- Use `move_and_slide()` unless a custom controller model is required.

## Baseline Controller Shape

Keep the controller script responsible for:

- collecting intent
- computing planar velocity
- resolving state restrictions
- rotating the actor
- calling movement

Push weapon logic, HUD updates, and large interaction systems into separate collaborators.

## Movement Pattern

```gdscript
var input_vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
var move_dir := Vector3(input_vec.x, 0.0, input_vec.y)
if move_dir.length() > 1.0:
    move_dir = move_dir.normalized()

velocity.x = move_dir.x * move_speed
velocity.z = move_dir.z * move_speed
move_and_slide()
```

## Facing Modes

### Move-facing

Rotate toward planar velocity when the move vector is non-zero.
Best for simple arcade movement and melee-heavy prototypes.

### Mouse-facing

Project the mouse to world space and face the hit point.
Use a floor plane or world geometry that is stable for aiming.

### Twin-stick

Separate move input from aim input.
Do not let movement overwrite aim rotation.

### Target-lock

Resolve the target point first, then rotate the actor or a pivot toward it.

## Screen to World Aiming

- Prefer raycasts from the active camera into the world.
- Intersect against a floor plane or physics bodies intended for aim resolution.
- Keep aim resolution in physics-safe code when it influences gameplay.

## State Shape

Use a simple enum when the controller has a moderate number of exclusive states:

```gdscript
enum State { IDLE, MOVE, ATTACK, DASH, STUN, INTERACT, DEAD }
```

Gate movement, input, and rotation through state-specific helper functions instead of one giant `_physics_process()`.

## Dash and Stun

- Treat dash as a temporary movement override with a timer or remaining distance.
- Treat stun as a short lockout that suppresses normal intent.
- Keep recovery timing explicit.
- Avoid stacking hidden booleans when an enum plus timers is enough.

## Common Pitfalls

- Updating position directly instead of using the body motion API.
- Forgetting diagonal normalization.
- Mixing mouse aim, interaction selection, and shooting logic in one unreadable block.
- Driving gameplay from animation completion without a fallback timeout or state guard.
