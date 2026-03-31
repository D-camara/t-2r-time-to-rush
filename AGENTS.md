# AGENTS.md

## Project Overview

This repository contains the game **Time to Rush (T2R)**, developed in **Godot**.

The game is a **3D top-down action game** with a fast-paced gameplay loop and a strong theme inspired by **casino heist / robbery / money escape** aesthetics.

The current priority is to implement polished and presentation-ready systems quickly, while keeping the code clean, modular, and easy to explain during an academic presentation.

---

## Main Goal

Help implement and improve gameplay systems for a 3D top-down game in Godot, with code that is:
- functional
- clean
- easy to maintain
- easy to explain in a presentation/demo
- visually and mechanically polished enough for short-term delivery

---

## Core Game Concept

- The player controls a character in a **3D top-down environment**
- The gameplay is fast and objective-driven
- The theme is related to **heist, robbery, casino, money collection, escape, urgency**
- The player may need to:
  - move through the map
  - collect loot or money
  - avoid danger, traps, or enemies
  - survive or finish objectives within a limited time

---

## Genre and Technical Direction

- Engine: **Godot**
- Perspective: **3D Top-Down**
- Programming language: **GDScript**
- Focus: gameplay programming and rapid iteration

---

## Implementation Priorities

Prioritize the following systems whenever relevant:

1. **Player controller**
   - smooth 3D top-down movement
   - responsive input
   - clean camera-relative or world-relative movement if needed

2. **Camera system**
   - stable top-down follow camera
   - readable framing
   - simple and reliable implementation

3. **HUD**
   - timer
   - score / collected loot
   - player status if needed

4. **Core gameplay systems**
   - item collection
   - objective tracking
   - win / lose conditions
   - restart flow

5. **Game feel / polish**
   - readability
   - code organization
   - simple effects if useful
   - avoid overengineering

---

## Win / Lose Rules

Possible victory conditions:
- collect all required items
- reach a target score
- survive until the timer ends
- escape after collecting the objective

Possible lose conditions:
- timer reaches zero
- player is caught
- player loses all health if a health system exists

When implementing systems, keep these rules flexible and easy to adjust.

---

## Coding Guidelines

- Use **GDScript**
- Prefer **clear and modular code**
- Keep functions small and readable
- Use descriptive variable and function names
- Avoid unnecessary complexity
- Reuse existing project structure instead of rewriting everything
- Do not break existing scenes unless necessary
- When changing code, explain:
  1. what changed
  2. why it changed
  3. where the code should be attached in Godot

---

## Godot-Specific Expectations

- Respect the current node hierarchy before suggesting changes
- Prefer solutions that fit naturally into Godot scenes and nodes
- When creating scripts, specify:
  - target node type
  - expected scene placement
  - required exported variables
  - required input actions
- If an input action is needed, explicitly mention it

---

## Collaboration Context

This is a team project. Some parts may already be implemented by other teammates.

Before rewriting or replacing systems:
- inspect the current files
- explain how the existing structure works
- extend the current implementation whenever possible

Do not assume the project is empty.

---

## Response Style

When helping with implementation:
- first analyze the current code
- then propose the cleanest practical solution
- then generate code
- then explain exactly how to plug it into the project

Prefer direct, production-ready help over generic theory.

---

## Important Constraint

The project has a short-term presentation deadline.
Prioritize:
- features that work
- clarity
- presentation quality
- short-term reliability

Avoid large refactors unless absolutely necessary.