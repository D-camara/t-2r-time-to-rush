# Camera Reference

Read this file when the task is about follow cameras, isometric cameras, zoom, bounds, screen-to-world projection, or RTS-style panning.

## Choose the Smallest Camera Rig

Common rigs:

- `Marker3D` or pivot plus `Camera3D` for a simple locked top-down rig
- pivot plus `SpringArm3D` plus `Camera3D` for collision-aware follow cameras
- world anchor plus detached pan logic for RTS cameras

Keep the rig self-contained and avoid hardcoded assumptions about the player scene path.

## Top-Down Follow

- Follow the target on XZ.
- Smooth only when the game benefits from it.
- Keep Y height stable unless zoom or terrain framing requires dynamic height.
- Clamp offsets or world bounds in one place.

## Isometric Cameras

- Lock pitch and yaw to the desired view angle.
- Frame gameplay using consistent world orientation.
- Be careful when translating input from camera-relative space into world-space movement.

## RTS-Style Cameras

- Separate edge pan, drag pan, and keyboard pan into independent intent sources.
- Apply zoom after pan calculations so bounds stay consistent.
- Clamp the final camera anchor, not the raw input deltas.

## Zoom

- Prefer changing the spring arm length, camera distance, or orthographic size depending on the rig.
- Define min and max zoom as exported properties.
- Keep zoom smoothing optional and modest.

## Bounds

- Clamp the camera anchor against play-area bounds.
- If the level is irregular, use dedicated limit volumes or authored bounds data.
- Avoid spreading bounds logic across the player and camera scripts.

## Mouse Projection

When mouse aiming or ground selection depends on the camera:

- cast from `project_ray_origin()`
- use `project_ray_normal()`
- intersect a floor plane or intended collision layer

Keep the camera's job limited to projection or framing; do not hide combat rules inside the camera script.

## Common Pitfalls

- Tying the camera to a fixed parent structure.
- Over-smoothing until controls feel delayed.
- Applying map bounds before zoom offsets are resolved.
- Mixing camera-relative and world-relative movement rules without being explicit.
