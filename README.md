[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/-jWdCFXs)
## Project 00
### NeXTCS
### Period: 
## Thinker0: Sufia Nanenco
## Thinker1: Maisha Alam
---

This project will be completed in phases. The first phase will be to work on this document. Use github-flavoured markdown. (For more markdown help [click here](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) or [here](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax) )

All projects will require the following:
- Researching new forces to implement.
- Method for each new force, returning a `PVector`  -- similar to `getGravity` and `getSpring` (using whatever parameters are necessary).
- A distinct demonstration for each individual force (including gravity and the spring force).
- A visual menu at the top providing information about which simulation is currently active and indicating whether movement is on or off.
- The ability to toggle movement on/off
- The ability to toggle bouncing on/off
- The user should be able to switch _between_ simluations using the number keys as follows:
  - `1`: Gravity
  - `2`: Spring Force
  - `3`: Drag
  - `4`: Custom Force
  - `5`: Combination


## Phase 0: Force Selection, Analysis & Plan
---------- 

#### Custom Force: NAME OF YOUR FORCE

### Custom Force Formula
Fk​ = μk​*Fn
Fk = kinetic friction
μk = coefficient of kinetic friction
Fn = normal force acting on the object​

### Custom Force Breakdown
- What information that is already present in the `Orb` or `OrbNode` classes does this force use?
  - Gravity, spring, drag if applicable [Fn is reliant on these forces b/c of F = ma and Fnet = 0 (if 0 acceleration which we will have)

- Does this force require any new constants, if so what are they and what values will you try initially?
  - μk, is dependent on the type of material the ground is.
  - <img width="582" height="560" alt="image" src="https://github.com/user-attachments/assets/3aa17d19-18bc-4324-9915-f17faab8b821" />
  In the image above, we will only use 'WOOD ON WOOD' [μk = 0.2], 'GLASS ON GLASS' [0.4], 'ICE ON ICE' [0.03]

- Does this force require any new information to be added to the `Orb` class? If so, what is it and what data type will you use?
  - Requires each Orb to be made of a specific material. We will use a BOOLEAN value to determine its material and apply the appropriate coefficient.

- Does this force interact with other `Orbs`, or is it applied based on the environment?
  - This force is applied based on the environment (the ground).

- In order to calculate this force, do you need to perform extra intermediary calculations? If so, what?
  - Need to calculate the normal force (Fn) that is acting on the object. So for example, if we run a simulation with 'GRAVITY' toggled true and the orb is moving left and right on the floor, in order to calculate Fn, we need Fnet which requires Fg.
- Need to track if the Orb and the ground are in contact in order for sliding forces to be applied (collison)
- set an equakity check w raidus
--- 

### Simulation 1: Gravity
Describe how you will attempt to simulate orbital motion.
- Fcentripetal = mv^2 / r
  - r = distance between centers of two orbs
  - m = mass of the orb
  - v = speed of the orb
--- 

### Simulation 2: Spring
Describe what your spring simulation will look like. Explain how it will be setup, and how it should behave while running.
-Need a constant describing the spring constant(k) of the spring
-Need a constant describing the length of the spring
-need a function that will draw the spring attached to the orbs
-need the distance between the two centers of the orbs
--- 

### Simulation 3: Drag
Describe what your drag simulation will look like. Explain how it will be setup, and how it should behave while running.

YOUR ANSWER HERE

--- 

### Simulation 4: Custom force
Describe what your Custom force simulation will look like. Explain how it will be setup, and how it should behave while running.

YOUR ANSWER HERE

--- 

### Simulation 5: Combination
Describe what your combination simulation will look like. Explain how it will be setup, and how it should behave while running.

YOUR ANSWER HERE

