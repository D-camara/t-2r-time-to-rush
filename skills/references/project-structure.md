# Project Structure Reference

Read this file when the task is mostly architectural: scene ownership, reusable resources, signals, groups, or how to place new systems in the repository.

## Prefer Coherent Scene Ownership

Keep each scene responsible for its own local behavior.
Avoid fragile assumptions about exact parent or sibling paths.
Use exported `NodePath` values, exported typed references, signals, or dependency injection at setup time.

## Good Structural Patterns

Two patterns work well for Godot gameplay projects:

- feature co-location: scene, script, and local resources live together
- domain grouping: controllers, combat, UI, and data each have clear top-level folders

Either is fine if the repository is already consistent.

## Resources for Tunable Data

Use custom `Resource` types for reusable and inspector-friendly data:

- stats
- weapons
- abilities
- waves
- missions
- item definitions

Keep behavior in scripts and tuning in resources when the distinction improves reuse.

## Signals and Groups

Use signals for local decoupling and specific reactions.
Use groups for broad coordination or discovery.
Do not create groups just to avoid passing a clear reference.

## Shared Systems

Use autoloads sparingly for systems with true global scope, such as:

- save profile ownership
- audio bus level coordination
- match or session orchestration

Do not promote a script to autoload just because two scenes need to talk.

## Script Size

Split scripts when they hold unrelated responsibilities, not merely because they became longer.
A controller plus a small health section may still be okay in a prototype.
A controller plus HUD plus quest logic plus camera management is not.

## Common Pitfalls

- Mirroring engine nodes with unnecessary wrapper scripts.
- Creating brittle cross-scene dependencies.
- Mixing incompatible folder conventions in the same feature.
- Hiding crucial dependencies inside `_ready()` lookups that silently fail.
