# Interaction Reference

Read this file when the task involves pickups, buttons, usable props, NPC triggers, prompts, or interactable selection.

## Use a Consistent Interaction Contract

Prefer a small API such as:

- `can_interact(actor) -> bool`
- `interact(actor) -> void`

This keeps player code, AI helpers, and world objects aligned.

## Choose Detection by Design

Use `Area3D` when:

- the player should enter a zone and interact
- multiple nearby candidates need prioritization

Use `RayCast3D` when:

- interaction is directional
- the player should focus a single object in front of them

Use explicit overlap or selection queries when:

- interaction depends on custom filters
- an RTS-style cursor chooses world objects

## Prompt Separation

Keep prompt logic separate from interaction execution.
The interactable should answer whether it can be used.
The player or UI layer should decide whether to show a prompt.

## Prioritization

If multiple interactables are available:

- pick the closest valid one
- or pick the one most aligned with facing direction
- or use explicit priority values

Be consistent across the project.

## Pickups and Consumables

- Apply the effect through a clear inventory or stat API.
- Remove or disable the pickup after successful collection.
- Guard against double collection in the same frame.

## Dialogue and Trigger Objects

- Keep dialogue flow outside the interactable if the system is reusable.
- Let the interactable fire a signal or call a domain service.
- Avoid burying UI construction inside level props.

## Common Pitfalls

- Hardcoding the player path inside every interactable.
- Letting prompts remain visible after the object becomes invalid.
- Mixing proximity checks, prompt rendering, and effect application into one script.
