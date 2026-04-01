# Performance Reference

Read this file when the task is about frame spikes, too many enemies, expensive queries, pooling, or general 3D gameplay optimization.

## Profile First

Start with the built-in profiler or reproducible hotspots before rewriting systems.
Identify whether the cost is coming from scripts, physics, rendering, navigation, or scene churn.

## Common Gameplay Costs

Watch for:

- per-frame broad physics queries on many actors
- repeated path recalculation without need
- large numbers of active `Area3D` overlap checks
- spawning and freeing many short-lived nodes each second
- expensive `_process()` logic that belongs in `_physics_process()` or event-driven code

## Cheap Wins

- stagger expensive AI checks across frames
- cache repeated lookups
- pool frequently spawned projectiles or VFX when churn is high
- trim signal spam and redundant state transitions
- keep collision layers and masks narrow

## Navigation Costs

- do not repath every frame unless the target changes meaningfully
- avoid `NavigationAgent3D` for enemies that could steer directly
- keep navmesh usage scoped to spaces where it matters

## Visual and Scene Costs

- reduce unnecessary shadow casters and dynamic lights when profiling shows render cost
- keep top-down cameras from rendering unneeded distant content when possible
- avoid huge always-active scene trees for systems that can be culled or disabled

## Physics and Hit Detection

- prefer simple shapes over overly detailed collision where gameplay allows
- keep hitboxes active only during valid windows
- avoid stacking multiple detection systems for the same purpose

## Common Pitfalls

- optimizing architecture before finding the real hotspot
- rewriting clean systems into unreadable code for tiny gains
- ignoring object lifetime churn from temporary nodes and effects
