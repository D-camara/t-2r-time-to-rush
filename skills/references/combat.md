# Combat Reference

Read this file when the task involves attacks, damage, hit detection, cooldowns, knockback, weapons, or combat refactors.

## Separate Responsibilities

Keep these responsibilities distinct:

- intent: player input or AI decision
- execution: start attack, spawn hitbox, play windup or recovery
- hit detection: overlap or ray hit collection
- damage application: health, armor, invulnerability, death
- feedback: sound, particles, hit flash, camera shake

## Reusable Combat Shape

Use a shared damage contract when both players and enemies can receive damage:

- `apply_damage(hit: HitData)` or similar on damageable actors
- a hitbox that carries attack data
- a hurtbox or body area that forwards valid hits

Store tunable stats in `Resource` files when multiple attacks or enemies need designer-friendly iteration.

## Duplicate Hit Protection

Prevent one swing from dealing damage multiple times unless multi-hit is intended.
Common options:

- keep a set of targets already hit for the active attack instance
- disable the hitbox after the first valid impact
- use per-target cooldown windows for damage-over-time behavior

## Melee

- Turn hitboxes on only during active frames.
- Keep windup, active, and recovery readable in code.
- Use animation events only when the project already depends on them cleanly.

## Ranged

- Separate projectile launch from projectile behavior.
- Decide early whether projectiles use physics bodies, areas, or hitscan queries.
- Keep collision layers and masks explicit.

## Cooldowns and Recovery

- Model cooldowns with timers or timestamp checks.
- Keep attack lockout separate from visual-only animation playback.
- Do not let HUD cooldown widgets become the source of truth.

## Knockback and Hit Reactions

- Apply knockback through the victim's movement system, not by teleporting.
- Keep reaction windows explicit so AI and players can respect them.
- Consider invulnerability windows when rapid overlapping hits are possible.

## Common Pitfalls

- Spawning permanent hitboxes and forgetting to clear them.
- Mixing weapon data, UI updates, and health logic in one script.
- Using collision callbacks without a clear rule for who owns damage resolution.
- Letting both the attacker and victim subtract health, causing double damage bugs.
