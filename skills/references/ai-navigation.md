# AI and Navigation Reference

Read this file when the task involves enemy chase logic, patrols, attack range checks, navmeshes, or NavigationAgent3D usage.

## Pick the Simplest Navigation Model

Use direct steering or pursuit when:

- arenas are open
- obstacles are sparse
- enemies mostly chase the player in sight

Use `NavigationAgent3D` when:

- authored navmeshes exist
- paths must route around complex static geometry
- avoidance or longer-distance pathing is necessary

## Baseline Enemy Loop

Most enemies only need:

- acquire target
- move toward target
- stop at attack range
- attack or recover
- return to idle, patrol, or search state

Avoid oversized behavior trees when a small enum-driven state machine is enough.

## NavigationAgent3D Rules

- Set `target_position` from the parent enemy logic.
- In `_physics_process()`, call `get_next_path_position()` and derive a move direction from it.
- Recompute rotation and velocity in the parent controller, not inside the agent node.
- Avoid signal-driven path refresh loops that recursively trigger new path requests.

## Chase Pattern

```gdscript
if target:
    agent.target_position = target.global_position
    var next_point := agent.get_next_path_position()
    var move_dir := (next_point - global_position)
    move_dir.y = 0.0
    if move_dir.length() > 0.001:
        move_dir = move_dir.normalized()
```

Blend this with distance checks so the enemy stops when in attack range instead of orbiting forever.

## Patrols

- Use simple waypoint arrays for authored patrol routes.
- Reuse the same movement code used by chase whenever possible.
- Keep patrol state separate from perception state.

## Perception

- Use distance checks, cone checks, `Area3D`, or line-of-sight raycasts depending on cost and fidelity.
- Run expensive line-of-sight checks only when necessary.
- Cache or stagger broader searches if many enemies are active.

## Common Pitfalls

- Using navmesh pathfinding for trivial open-arena enemies.
- Reading agent output but never updating movement velocity from it.
- Repathing every frame for no gameplay reason.
- Forgetting to flatten Y when the game plays strictly on the XZ plane.
