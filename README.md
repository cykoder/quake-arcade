# Quake Arcade Cabinet Mod

A fully working **arcade cabinet entity** for Quake, written in QuakeC.  
It simulates a **1-bit display** (Dreamcast VMU–style resolution) and supports multiple games running inside the Quake world.

---

## Features

- **Arcade cabinet entity** (`misc_arcade`) that players can interact with in-game.
- VMU-inspired **1-bit, 48x32 pixel display** (1536 pixels total).
- Pixels are drawn as tiny in-world entities (`progs/arcade_pixel.mdl`), optimized into scanlines for performance.
- Runs at ~24 FPS (`ARCADE_REFRESH_RATE`).
- Games implemented in pure QuakeC — no engine modifications required.
- Selection menu for choosing between multiple mini-games.

Currently implemented:
- 🟢 **Pung** (simple Pong clone).

Planned / ideas:
- 🟡 **Tetris** (inspired by VMU version)  
  ![Tetris VMU](https://dreamcast.wiki/wiki/images/8/8b/VMU_Tetris_Screenshot.gif)  
- 🟡 **Flappy Bird** (Dreamcast port inspiration)  
  [Dreamcast Flappy Bird](https://www.thedreamcastjunkyard.co.uk/2016/03/flappy-bird-now-available-for-dreamcast.html)

---

## Technical Details

- **Resolution:** `48x32` (1-bit, packed into floats).  
- **Pixel Packing:** Uses the float mantissa (`23 bits`) to pack pixels into `screenPixels[68]`.  
- **Brush Generation:** Pixels are merged into horizontal spans before spawning to reduce entity count.  
- **Entity Limit:** Up to `1024` pixel entities per screen.  
- **Input:** Player `use` activates the cabinet. `jump` works as an action button. Planned movement binding for navigation.  
- **Exit:** Fire button or leaving the cabinet.

---

## Usage

1. Add the QuakeC code to your mod’s source tree.
2. Add the required models to `progs/`:
   - `progs/arcade_cabinet.mdl` → the physical arcade machine.
   - `progs/arcade_pixel.mdl` → a flat pixel sprite/brush for screen rendering.
3. Recompile your mod.
4. Place the cabinet in your map using the entity:

   ```quakec
   /*QUAKED misc_arcade (0 .5 .8) (-11 -11 -11) (11 11 11)
   A sweet ass arcade machine, made by cykboy
   */
