# Animation Reference

Read this file when the task is about AnimationTree, locomotion blending, attack one-shots, or syncing animation with gameplay state.

## Keep Animation as a Consumer of Gameplay State

Gameplay state should decide what the character is allowed to do.
Animation should represent or embellish that state, not replace it as the authority.

## Prefer the Right Tool

- Use `AnimationPlayer` to own imported clips and direct playback.
- Use `AnimationTree` for blend spaces, layered animation, one-shots, and animation state machines.

## Useful Parameters

Common AnimationTree parameters include:

- locomotion blend position from planar velocity
- attack one-shot request flags
- upper-body and lower-body state splits
- aim direction or turn amount

Keep parameter writes centralized so debugging stays manageable.

## Locomotion

- Derive blend inputs from gameplay velocity on the XZ plane.
- Filter tiny values so idle does not jitter.
- Keep visual smoothing modest if it hurts responsiveness.

## Attacks and Reactions

- Use gameplay code to start attacks and lock state.
- Let animation react through one-shots or state transitions.
- If animation events open hitboxes, keep a fallback cleanup path in code.

## Root Motion

Use root motion only when the project already depends on it and the team understands the tradeoffs.
For most top-down projects, controller-driven movement is simpler and easier to tune.

## Common Pitfalls

- Letting animation state become the real gameplay state machine.
- Writing AnimationTree parameters from many unrelated scripts.
- Driving all hit timing exclusively from animation without code-level guards.
