#pragma once

/*
	1-bit color display/VMU resolution arcade cabinet with multiple game support
	Author: cykboy (https://github.com/cykoder) 2024
	NOTE: Only one arcade machine per map is supported
  game idea tetris: https://dreamcast.wiki/wiki/images/8/8b/VMU_Tetris_Screenshot.gif
  game idea: flappy bird https://www.thedreamcastjunkyard.co.uk/2016/03/flappy-bird-now-available-for-dreamcast.html
*/

#define ARCADE_GAME_COUNT 1

#define SCREEN_WIDTH 48
#define SCREEN_HEIGHT 32
#define SCREEN_PIXEL_COUNT 1536

// NOTE: must match whats in th model, and note quake engine inprecision
#define PIXEL_WIDTH 0.5
#define PIXEL_HEIGHT 0.5

// NOTE: 32 bits per float, but we can only manipulate the mantissa!
#define BITS_PER_FLOAT 23

// Array count is ceil(SCREEN_PIXEL_COUNT / BITS_PER_FLOAT)
#define SCREEN_ARRAY_COUNT 68
#define MAX_SCREEN_ENTITIES 1024

// Roughly 24FPS by default (1.0 / 24.0)
#define ARCADE_REFRESH_RATE 0.0416

// Proto definition for games to use the method
void setScreenPixel(int pixelX, int pixelY, int pixelState);

#include "./games/pung.qc"

void misc_arcade_think();
void misc_arcade_resetgame();

// Array to keep track of spawned pixel scanline entities
typedef float screendata_t;
screendata_t screenPixels[SCREEN_ARRAY_COUNT];
entity spawnedEntities[MAX_SCREEN_ENTITIES];
int spawnedEntityCount;
int arcadeCurrentGame;
int arcadeSelecedGame;

// Function to get a single binary pixel value from the packed array using pixel coordinates
float getScreenPixel(int pixelX, int pixelY) {
  int index = pixelY * SCREEN_WIDTH + pixelX;

  // Bounds check (ensure index is within the total number of pixels)
  if (index < 0 || index >= SCREEN_PIXEL_COUNT) {
    error("getScreenPixel out of bounds at ", ftos(index));
    return 0;
  }

  // Calculate which 32-bit integer contains this bit
  int packedIndex = index / BITS_PER_FLOAT; // Integer index in screenPixels array
  int bitPosition = index % BITS_PER_FLOAT; // Bit position within that integer

  // Extract the specific bit using bitwise AND and shift
  screendata_t packedValue = screenPixels[packedIndex];
  return ((int)packedValue >> bitPosition) & 1; // Return the bit as 0 or 1
}

// Function to set a single binary pixel value in the packed array using pixel coordinates
void setScreenPixel(int pixelX, int pixelY, int pixelState) {
  int index = pixelY * SCREEN_WIDTH + pixelX;

  // Bounds check (ensure index is within the total number of pixels)
  if (index < 0 || index >= SCREEN_PIXEL_COUNT) {
    error("setScreenPixel out of bounds at ", ftos(index));
    return; // Out of bounds, do nothing
  }

  // Calculate which 32-bit integer contains this bit
  int packedIndex = index / BITS_PER_FLOAT; // Integer index in screenPixels array
  int bitPosition = index % BITS_PER_FLOAT; // Bit position within that integer

  // Update the specific bit using bitwise operations
  screendata_t currentVal = screenPixels[packedIndex];
  if (pixelState == 1) {
    // Set the bit (OR with shifted 1)
    screenPixels[packedIndex] = (int)currentVal | (1 << bitPosition);
  } else { // TODO: restore below, but its unused atm
    // Clear the bit (AND with inverted shifted 1)
    screenPixels[packedIndex] = (int)currentVal & ~(1 << bitPosition);
  }
}

void clearScreen() {
  for (int i = 0; i < SCREEN_ARRAY_COUNT; i++) {
    screenPixels[i] = 0;
  }
}

void initScreen() {
  spawnedEntityCount = 0;
  clearScreen();
}

// Purely for debug
void printScreenState() {
  // Loop through each row (y-coordinate)
  for (int y = 0; y < SCREEN_HEIGHT; y++) {
    // Loop through each column (x-coordinate)
    for (int x = 0; x < SCREEN_WIDTH; x++) {
      // Get the state of the pixel at (x, y)
      int state = getScreenPixel(x, SCREEN_HEIGHT - 1 - y);

      // Print the state (0 or 1) using dprint
      dprint(ftos(state)); // Convert float to string for printing
    }

    // Print a newline after each row for better readability
    dprint("\n");
  }
}

// Function to remove all previously spawned entities
void ClearScreenEntities() {
  // Loop through all spawned entities and remove them
  for (int i = 0; i < spawnedEntityCount; i++) {
    remove(spawnedEntities[i]);
    spawnedEntities[i] = __NULL__; // Clear the reference to the entity
  }

  // Reset the spawned entity count
  spawnedEntityCount = 0;
}

void GenerateOptimizedBrushes() {
  spawnedEntityCount = 0;

  // Iterate through each pixel in the screenPixels array
  for (int pixelY = 0; pixelY < SCREEN_HEIGHT; pixelY++) {
    for (int pixelX = 0; pixelX < SCREEN_WIDTH; pixelX++) {
      // Get the current state (1 for "on", 0 for "off")
      screendata_t pixelState = getScreenPixel(pixelX, pixelY);

      // Don't render black pixels
      if (pixelState == 0) {
        continue;
      }

      // Find the extent of contiguous pixels with the same state
      local float end_x = pixelX;
      while ((end_x + 1) < SCREEN_WIDTH) {
        if (getScreenPixel(end_x + 1, pixelY) == pixelState) {
          end_x++;
        } else {
          break; // Stop expanding if the next pixel is different or out of bounds
        }
      }

      // Create a model for this contiguous line
      vector worldOrigin = CREATE_VECTOR_DYNAMIC(0, pixelX * PIXEL_WIDTH, pixelY * PIXEL_HEIGHT);
      entity pixel;
      pixel = spawn();
      pixel.owner = self;
      setmodel(pixel, "progs/arcade_pixel.mdl");
      worldOrigin += self.origin;
      setorigin(pixel, worldOrigin);
      pixel.solid = SOLID_NOT;
      pixel.movetype = MOVETYPE_NONE; // No movement, static
      pixel.classname = "func_wall";
      pixel.angles = self.angles;

      pixel.skin = 0;
      if (pixelState != 0) {
        pixel.skin = 2;
      }

      local float pixelSize = (end_x - pixelX) + 1;
      pixel.frame = pixelSize - 1.0;

      // Add the new entity to the spawned entities array
      spawnedEntities[spawnedEntityCount] = pixel;
      spawnedEntityCount++;

      pixelX += pixelSize - 1;

      if (spawnedEntityCount >= MAX_SCREEN_ENTITIES) {
        return;
      }
    }
  }

  dprint("spawnedEntityCount ", ftos(spawnedEntityCount), "\n");
}

// NOTE: doesnt work to get impulses, but maybe we can bind/unbind the use and jump keys
void misc_arcade_bind_controls(entity currentUser) {
  // stuffcmd(currentUser, "bind w \"+forward; impulse 190\"\n");
  // stuffcmd(currentUser, "bind s \"+back; impulse 191\"\n");
  // stuffcmd(currentUser, "bind a \"+moveleft; impulse 192\"\n");
  // stuffcmd(currentUser, "bind d \"+moveright; impulse 193\"\n");
}

void misc_arcade_unbind_controls(entity currentUser) {
  // stuffcmd(currentUser, "bind w \"+forward\"\n");
  // stuffcmd(currentUser, "bind s \"+back\"\n");
  // stuffcmd(currentUser, "bind a \"+moveleft\"\n");
  // stuffcmd(currentUser, "bind d \"+moveright\"\n");
}

void arcade_use() {
  if (!self.enemy && other && other.flags & FL_ONGROUND) {
    // TODO: check is grouded
    dprint("arcade_use start\n");
    SUB_UseTargets();

    self.think = misc_arcade_think;
    self.nextthink = time + 0.1;
    self.enemy = other;
    self.dest = other.origin; // Store the current position of the activator
    arcadeCurrentGame = 0;
    arcadeSelecedGame = 1;
    misc_arcade_bind_controls(other);
  }
};

void arcade_misc_draw_select_screen() {
  cykgame_pung_draw_name(12);

  if (arcadeSelecedGame > 1) {
    drawCykCharUP(20, 23);
  }
  if (arcadeSelecedGame < ARCADE_GAME_COUNT) {
    drawCykCharDOWN(20, 2);
  }
}

void misc_arcade_exit() {
  misc_arcade_resetgame();

  entity currentUser = self.enemy;
  if (currentUser && currentUser.flags & FL_CLIENT) {
    currentUser.pausetime = time;
    // currentUser.deadflag = 0;
    misc_arcade_unbind_controls(currentUser);
  }

  self.enemy = __NULL__;
}

void misc_arcade_resetgame() {
  switch (arcadeCurrentGame) {
  case 1: // cyk pung
    cykgame_pung_reset();
    break;
  }

  arcadeSelecedGame = 1;
}

void misc_arcade_update(float isPlayerJumping) {
  switch (arcadeCurrentGame) {
  case 1: // cyk pung
    cykgame_pung_run(isPlayerJumping);
    break;

  default: // game select
    arcade_misc_draw_select_screen();

    if (isPlayerJumping) {
      misc_arcade_resetgame();
      arcadeCurrentGame = arcadeSelecedGame;
    }

    // TODO: game select increment with movement keys
    break;
  }
}

void misc_arcade_think() {
  float isPlayerFiring = self.enemy.button0;
  float isPlayerJumping = self.enemy.button2;

  clearScreen();
  ClearScreenEntities();

  if (!self.enemy || isPlayerFiring) { // temp jump to exit? or can jump be like A button?
    misc_arcade_exit();
    return;
  }

  if (self.enemy.impulse) {
    dprint("ye impulse ", ftos(self.enemy.impulse), "\n");
    self.enemy.impulse = 0;
  }

  dprint(vtos(self.enemy.velocity), "\n");

  // TODO: pin player to current pos
  // how to get directional movement?
  //   maybe we can use pos vector or if velocity is set?
  //   might have to use velocity to pin them, so do it before

  // self.enemy.movetype = MOVETYPE_NONE;
  self.enemy.pausetime = time + 100;
  // self.enemy.deadflag = DEAD_DYING;
  self.enemy.button0 = 0;
  self.enemy.button2 = 0;

  // run dat ting
  misc_arcade_update(isPlayerJumping);
  GenerateOptimizedBrushes();

  self.nextthink = time + ARCADE_REFRESH_RATE;
};

/*QUAKED misc_arcade (0 .5 .8) (-11 -11 -11) (11 11 11)
A sweet ass arcade machine, made by cykboy
*/
void misc_arcade() {
  dprint("misc_arcade spawn\n");
  if (!SUB_InitEntity())
    return;

  precache_model("progs/arcade_cabinet.mdl");
  setmodel(self, "progs/arcade_cabinet.mdl");

  self.touch = arcade_use;
  self.solid = SOLID_BBOX;
  self.movetype = MOVETYPE_NONE;

  float arcadeSize = 11.0f;
  vector vmin, vmax;
  vmin.x = -arcadeSize;
  vmin.y = -arcadeSize;
  vmin.z = 0;
  vmax.x = arcadeSize;
  vmax.y = arcadeSize;
  vmax.z = 40;
  setsize(self, vmin, vmax);

  initScreen();
};
