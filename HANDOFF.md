# Falling Sand — Chemistry Sim (handoff)

## Path
`index.html` in this repo (single self-contained HTML) (single self-contained HTML).

## What it is
Cellular-automaton sandbox / chemistry simulator with **25 tools**: 24 elements + a
**👤 Person** spawner that drops brainless little stick-people who wander, fall, get
trapped, drown, burn, and die.

## Elements (each a distinct, easy-to-tell-apart color)
Sand(gold), Water(vivid blue), Stone(flat gray), Wood(brown), Plant(green), Seed(tan),
Ice(pale cyan), Cement(bluish-gray), Salt(white), Oil(dark brown), Gunpowder(charcoal),
Nitro(amber), Gas(yellow), Fire(orange-red), Spark(electric cyan), Lava(molten red),
Acid(electric green), Metal(silver), Glass(pale blue), Obsidian(purple-black),
Smoke(gray), Steam(pale blue-white), Fog(soft white), Ash(warm gray) + Concrete(product).
Each element has ONE locked-hue base color (only brightness jitters per cell) so they're
instantly identifiable.

## Chemistry — 35+ reactions (verified)
**Heat/fire:** wood/oil/plant burn; gunpowder/nitro/gas explode; fire doused by water/acid/fog->steam; ice melts near fire.
**Lava:** +water->stone+steam, +ice->obsidian+steam, +sand->glass, +salt->glass, +acid->obsidian (quench), +gunpowder/nitro->explode, +wood/oil/plant->burn; lava cools to STONE over ~400-580 frames, quick-chills to obsidian near cold.
**Water:** extinguish fire; dissolve salt; neutralize acid; +cement->CONCRETE (absorbs water); +seed->plant; +smoke disperses.
**Acid:** dissolves wood/plant/salt fast, stone & metal slowly, obsidian very slowly, GLASS not at all; neutralized by water.
**Spark:** conducts through METAL wire & WATER (travels cell-by-cell, restores the conductor); detonates gunpowder/nitro/gas; ignites wood/oil/plant.
**Gas/steam/fog:** gas rises & explodes on fire/spark; steam & fog condense to water.
**Plant/seed:** seed+water->plant; plant grows up only with water.

## Persons (👤 tool)
- Brainless random walkers: pick a direction, walk, randomly turn, bounce off walls,
  fall off ledges. No pathfinding -> they get stuck in holes, trapped under falling
  sand (suffocate), drown in water, burn in fire/lava, dissolve in acid, get knocked
  around by explosions, and die leaving ash.
- Each has: pixel position/velocity, health bar, air (drowning), walk animation,
  random shirt color. Drop one or many anywhere (drag to paint multiples; capped ~80).
- Drawn as animated stick figures (head, torso, swinging arms/legs, drowning bubbles).

## Key implementation notes
- Original architecture restored: `frame()` = `update(); promote();` (double-buffer swap
  is the last step so committed state lands in `cur`). Explosions push blastEvents and
  peopleReact applies knockback/damage.
- Heat system: fire/lava radiate into 8-neighborhood (air + solids found via cur-then-next);
  drives ice-melt, ambient ignition.
- Spark conduction in a separate conductPass() after the particle loop (so conductors
  already in `next` are found); `was[]` remembers displaced conductors to restore them.

## Verified
- Deterministic battery: all core reactions pass (fire-douse, ice-melt, lava->glass/
  obsidian/cooling, gunpowder/gas/nitro explode, spark wire + intact, acid dissolve/
  glass-resist, steam+fog condense, salt dissolve, plant gating). Focused direct tests
  confirm cement+water->concrete, lava+acid->obsidian, person fly/walk/drown/burn/die.
- Headless Brave play-test: 25 tools, 720x560 canvas, drew stone+lava+water+fire +
  6 people, loop responsive 8s+ (no crash); screenshot: 1122 colors, stick figures visible.

## Run
Open index.html in any browser (file:// works). Classic combos: metal-wire + spark +
  gunpowder at the far end = wire-triggered explosion; lava on ice = obsidian;
  cement then water = concrete; drop a person on lava.


## Bridge Builder mode (added 2026-08-05)

Turns the sandbox into a build-test-blow-up physics toy.

**New materials:** WOOD_BEAM (deep brown, moderate) / STEEL_BEAM (steel-blue, strong).
Both are static solid beams that bear load.

**New controls (bottom bar):**
- `Bridge` — clears + builds a starter test rig: stone floor, twin stone pillars,
  a 2-layer wooden deck between them, and a metal hopper rail above.
- `Test Load` — pours a stream of sand weights onto the deck center.

**Stress model:** each beam cell supports the column of material resting above it
(columnLoadOn = sum densities up the unsupported column). Load strains the beam
visually green->amber->red (sagTable, stress-tinted in render). On exceed-capacity
the beam snaps into falling DEBRIS, opening a gap the load pours through = collapse
(bridgePass runs each sim step after promote).

**Blow it up:** explosions damage beams via damageBeamsNear (wood 55% / steel 18%
chance within blast radius), patched onto explode at init.

**Verified headless (Node):** no-load bridge does NOT snap; pour collapses deck
(pour -> 1815 sand, partial collapse) and heavy stone slab -> 21 debris;
explosions reduce beams; stressed render doesn't crash. JS syntax clean.
Backup of pre-bridge file: index.html.bak-bridge.


## Polish round 2 (from freegle QA review, master-built 2026-08-05)

Bugs fixed per freegle's read-only review:
- DEBRIS no longer shields load (columnLoadOn stops only at beams) - debris now contributes its own weight, so collapse cascades properly (debris 8->16 cells).
- snapBeam/damageBeamsNear write only cur (not next) - no more frozen cells / phantom debris blocking the double-buffer contract.
- Acid resistance: WOOD_BEAM dissolves slowly (0.1), STEEL_BEAM very resistant (0.02).

Gameplay (master decisions):
- WOOD_BEAM is now FLAMMABLE (ignites/burns like wood); steel resists acid.
- SUPPORT MODEL (the real game): each beam flood-fill checked for anchored path to solid ground (computeSupport). Unsupported floating beams have ~15% capacity and collapse under any real load - you must build a supported bridge. Verified: floating beam 30->3 collapses, ground-supported deck holds 30/30.
- COLLAPSE MONEY-SHOT: on first snap the sim slows to 1/4 speed with a bright flash + screen shake at the break (collapseFx). Makes the collapse readable.

All headless tests green (9 checks incl. support + collapse + explosion damage).
