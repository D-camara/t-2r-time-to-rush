Read AGENTS.md first and strictly follow it.

We must align the implementation with the presentation slides for T2R: Time to Rush.

T2R is a 3D top-down asymmetric chase-and-escape game, not a collection-based game.
The core presentation concept is:
- one police player chases
- robbers/fugitives must survive and escape until the timer ends
- if at least one fugitive is still free when the timer reaches zero, the fugitives win
- if all fugitives are captured before the timer ends, the police wins

The timer is the main implemented system and the core of the round.
HUD must prioritize:
- remaining time
- number of players/fugitives still active
- round status / important alerts

Planned systems like score and lives are secondary and should not be the current implementation priority.

First, inspect the existing Godot project and identify what is already usable for this presentation build.
Then create a practical MVP plan that stays fully consistent with the presentation concept.

Prioritize only:
1. stable player movement
2. top-down follow camera
3. round manager with countdown timer
4. simple capture system
5. win/lose conditions based on survival and capture
6. minimal HUD with time, active players, and round feedback
7. restart flow

Do not redesign the game around item collection.
Do not overengineer.
Reuse the current project structure as much as possible.

After the plan, start implementing step by step, beginning with the systems that are most important for a playable presentation demo.
For every code change:
- use GDScript
- explain where the script should be attached
- mention required nodes
- mention required input actions
- avoid breaking existing systems