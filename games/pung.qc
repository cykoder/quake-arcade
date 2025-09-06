#include "cyksig.h"
#include "../asciichars.qc"

#define PUNG_TITLE_TIMER_SIG 15
#define PUNG_TITLE_TIMER_BOTTOM 30
#define PUNG_TITLE_TIMER_TOTAL 60
#define PUNG_REFRESH_RATE 0.05
#define PUNG_MAX_LIVES 2

void cykgame_pung_draw_game_over();

float pungPaddlePosition; // todo: could merge into Z of pungBallPos?
vector pungBallVelocity;
vector pungBallPos;

int pungGameState;
int titleTimer;

void cykgame_pung_draw_name(int originY) {
  int originX = 7;
  drawCykCharP(originX, originY);
  drawCykCharU(originX + 9, originY);
  drawCykCharN(originX + 9 + 9, originY);
  drawCykCharG(originX + 9 + 9 + 9, originY);
}

void cykgame_pung_reset() {
  pungGameState = 0;
  titleTimer = 0;
  pungPaddlePosition = 20;
  pungBallPos.x = 24;
  pungBallPos.y = 4;
  pungBallVelocity.x = 0;
  pungBallVelocity.y = 0;
}

void cykgame_pung_draw_title() {
  drawCykCharA(20, 22);
  if (titleTimer > PUNG_TITLE_TIMER_SIG) {
    drawCykSignature(1, 11);
  }
  if (titleTimer > PUNG_TITLE_TIMER_BOTTOM) {
    drawCykCharG(7, 3);
    drawCykCharA(16, 3);
    drawCykCharM(25, 3);
    drawCykCharE(34, 3);
  }

  titleTimer = titleTimer + 1;
  if (titleTimer > PUNG_TITLE_TIMER_TOTAL) {
    cykgame_pung_reset();
    titleTimer = 999;
    pungGameState = 1;
  }
}

void cykgame_pung_run(float isADown) {
  if (pungGameState == 0) {
    cykgame_pung_draw_title();
    return;
  } else if (pungGameState >= PUNG_MAX_LIVES + 1) {
    cykgame_pung_draw_game_over();
    return;
  }

  // Draw ball
  float ballX = floor(pungBallPos.x);
  float ballY = floor(pungBallPos.y);

  // TODO: decide if 1px ball is big enough
  setScreenPixel(ballX, ballY, 1);
  setScreenPixel(ballX - 1, ballY, 1);
  setScreenPixel(ballX - 1, ballY + 1, 1);
  setScreenPixel(ballX, ballY + 1, 1);

  // Draw paddle
  setScreenPixel(pungPaddlePosition + 0, 0, 1);
  setScreenPixel(pungPaddlePosition + 1, 0, 1);
  setScreenPixel(pungPaddlePosition + 2, 0, 1);
  setScreenPixel(pungPaddlePosition + 3, 0, 1);
  setScreenPixel(pungPaddlePosition + 4, 0, 1);
  setScreenPixel(pungPaddlePosition + 5, 0, 1);
  setScreenPixel(pungPaddlePosition + 6, 0, 1);
  setScreenPixel(pungPaddlePosition + 7, 0, 1);
  setScreenPixel(pungPaddlePosition + 0, 1, 1);
  setScreenPixel(pungPaddlePosition + 1, 1, 1);
  setScreenPixel(pungPaddlePosition + 2, 1, 1);
  setScreenPixel(pungPaddlePosition + 3, 1, 1);
  setScreenPixel(pungPaddlePosition + 4, 1, 1);
  setScreenPixel(pungPaddlePosition + 5, 1, 1);
  setScreenPixel(pungPaddlePosition + 6, 1, 1);
  setScreenPixel(pungPaddlePosition + 7, 1, 1);

  // Game logic, after draw so we see updates happen first
  if (pungBallVelocity) { // Playing state
    pungBallVelocity.z -= ARCADE_REFRESH_RATE;

    // Update ball at certain rate to prevent jerkyness
    if (pungBallVelocity.z > 0) {
      return;
    }

    pungBallVelocity.z = PUNG_REFRESH_RATE;
    pungBallPos.x = pungBallPos.x + pungBallVelocity.x;
    pungBallPos.y = pungBallPos.y + pungBallVelocity.y;

    if (pungBallPos.y >= 30) {
      pungBallPos.y = 30;
      // increase speed every time it hits the top
      pungBallVelocity.y = pungBallVelocity.y * -1.025;
      pungBallVelocity.x = pungBallVelocity.x * 1.025;
      if (floor(pungBallVelocity.x) == 0) {
        pungBallVelocity.x = 1.0;
      }
    }

    // paddle collision
    if (pungBallPos.y <= 2) {
      pungBallVelocity.y *= -1.0;
      pungBallPos.y = 3;
    } else if (pungBallPos.y <= 0) { // lose current game
      int lastGameState = pungGameState;
      cykgame_pung_reset();
      titleTimer = 999;
      pungGameState = lastGameState + 1;
    }

    if (pungBallPos.x >= 47) {
      pungBallPos.x = 47;
      pungBallVelocity.x *= -1.0;
    } else if (pungBallPos.x <= 1) {
      pungBallPos.x = 1;
      pungBallVelocity.x *= -1.0;
    }
  } else if (isADown) { // Press play to start
    pungBallVelocity.x = 1;
    pungBallVelocity.y = 1;
    pungBallVelocity.z = 0;
  }
}

void cykgame_pung_draw_game_over() {
  int oX = 0;
  int oY = 0;
  setScreenPixel(oX + 4, oY + 29, 1);
  setScreenPixel(oX + 5, oY + 29, 1);
  setScreenPixel(oX + 6, oY + 29, 1);
  setScreenPixel(oX + 7, oY + 29, 1);
  setScreenPixel(oX + 8, oY + 29, 1);
  setScreenPixel(oX + 9, oY + 29, 1);
  setScreenPixel(oX + 10, oY + 29, 1);
  setScreenPixel(oX + 15, oY + 29, 1);
  setScreenPixel(oX + 16, oY + 29, 1);
  setScreenPixel(oX + 17, oY + 29, 1);
  setScreenPixel(oX + 18, oY + 29, 1);
  setScreenPixel(oX + 19, oY + 29, 1);
  setScreenPixel(oX + 20, oY + 29, 1);
  setScreenPixel(oX + 21, oY + 29, 1);
  setScreenPixel(oX + 25, oY + 29, 1);
  setScreenPixel(oX + 26, oY + 29, 1);
  setScreenPixel(oX + 32, oY + 29, 1);
  setScreenPixel(oX + 33, oY + 29, 1);
  setScreenPixel(oX + 36, oY + 29, 1);
  setScreenPixel(oX + 37, oY + 29, 1);
  setScreenPixel(oX + 38, oY + 29, 1);
  setScreenPixel(oX + 39, oY + 29, 1);
  setScreenPixel(oX + 40, oY + 29, 1);
  setScreenPixel(oX + 41, oY + 29, 1);
  setScreenPixel(oX + 42, oY + 29, 1);
  setScreenPixel(oX + 43, oY + 29, 1);
  setScreenPixel(oX + 44, oY + 29, 1);
  setScreenPixel(oX + 3, oY + 28, 1);
  setScreenPixel(oX + 4, oY + 28, 1);
  setScreenPixel(oX + 5, oY + 28, 1);
  setScreenPixel(oX + 6, oY + 28, 1);
  setScreenPixel(oX + 7, oY + 28, 1);
  setScreenPixel(oX + 8, oY + 28, 1);
  setScreenPixel(oX + 9, oY + 28, 1);
  setScreenPixel(oX + 10, oY + 28, 1);
  setScreenPixel(oX + 11, oY + 28, 1);
  setScreenPixel(oX + 14, oY + 28, 1);
  setScreenPixel(oX + 15, oY + 28, 1);
  setScreenPixel(oX + 16, oY + 28, 1);
  setScreenPixel(oX + 17, oY + 28, 1);
  setScreenPixel(oX + 18, oY + 28, 1);
  setScreenPixel(oX + 19, oY + 28, 1);
  setScreenPixel(oX + 20, oY + 28, 1);
  setScreenPixel(oX + 21, oY + 28, 1);
  setScreenPixel(oX + 22, oY + 28, 1);
  setScreenPixel(oX + 25, oY + 28, 1);
  setScreenPixel(oX + 26, oY + 28, 1);
  setScreenPixel(oX + 32, oY + 28, 1);
  setScreenPixel(oX + 33, oY + 28, 1);
  setScreenPixel(oX + 36, oY + 28, 1);
  setScreenPixel(oX + 37, oY + 28, 1);
  setScreenPixel(oX + 38, oY + 28, 1);
  setScreenPixel(oX + 39, oY + 28, 1);
  setScreenPixel(oX + 40, oY + 28, 1);
  setScreenPixel(oX + 41, oY + 28, 1);
  setScreenPixel(oX + 42, oY + 28, 1);
  setScreenPixel(oX + 43, oY + 28, 1);
  setScreenPixel(oX + 44, oY + 28, 1);
  setScreenPixel(oX + 3, oY + 27, 1);
  setScreenPixel(oX + 4, oY + 27, 1);
  setScreenPixel(oX + 10, oY + 27, 1);
  setScreenPixel(oX + 11, oY + 27, 1);
  setScreenPixel(oX + 14, oY + 27, 1);
  setScreenPixel(oX + 15, oY + 27, 1);
  setScreenPixel(oX + 21, oY + 27, 1);
  setScreenPixel(oX + 22, oY + 27, 1);
  setScreenPixel(oX + 25, oY + 27, 1);
  setScreenPixel(oX + 26, oY + 27, 1);
  setScreenPixel(oX + 27, oY + 27, 1);
  setScreenPixel(oX + 31, oY + 27, 1);
  setScreenPixel(oX + 32, oY + 27, 1);
  setScreenPixel(oX + 33, oY + 27, 1);
  setScreenPixel(oX + 36, oY + 27, 1);
  setScreenPixel(oX + 37, oY + 27, 1);
  setScreenPixel(oX + 3, oY + 26, 1);
  setScreenPixel(oX + 4, oY + 26, 1);
  setScreenPixel(oX + 14, oY + 26, 1);
  setScreenPixel(oX + 15, oY + 26, 1);
  setScreenPixel(oX + 21, oY + 26, 1);
  setScreenPixel(oX + 22, oY + 26, 1);
  setScreenPixel(oX + 25, oY + 26, 1);
  setScreenPixel(oX + 26, oY + 26, 1);
  setScreenPixel(oX + 27, oY + 26, 1);
  setScreenPixel(oX + 28, oY + 26, 1);
  setScreenPixel(oX + 30, oY + 26, 1);
  setScreenPixel(oX + 31, oY + 26, 1);
  setScreenPixel(oX + 32, oY + 26, 1);
  setScreenPixel(oX + 33, oY + 26, 1);
  setScreenPixel(oX + 36, oY + 26, 1);
  setScreenPixel(oX + 37, oY + 26, 1);
  setScreenPixel(oX + 3, oY + 25, 1);
  setScreenPixel(oX + 4, oY + 25, 1);
  setScreenPixel(oX + 14, oY + 25, 1);
  setScreenPixel(oX + 15, oY + 25, 1);
  setScreenPixel(oX + 21, oY + 25, 1);
  setScreenPixel(oX + 22, oY + 25, 1);
  setScreenPixel(oX + 25, oY + 25, 1);
  setScreenPixel(oX + 26, oY + 25, 1);
  setScreenPixel(oX + 28, oY + 25, 1);
  setScreenPixel(oX + 29, oY + 25, 1);
  setScreenPixel(oX + 30, oY + 25, 1);
  setScreenPixel(oX + 32, oY + 25, 1);
  setScreenPixel(oX + 33, oY + 25, 1);
  setScreenPixel(oX + 36, oY + 25, 1);
  setScreenPixel(oX + 37, oY + 25, 1);
  setScreenPixel(oX + 3, oY + 24, 1);
  setScreenPixel(oX + 4, oY + 24, 1);
  setScreenPixel(oX + 8, oY + 24, 1);
  setScreenPixel(oX + 9, oY + 24, 1);
  setScreenPixel(oX + 10, oY + 24, 1);
  setScreenPixel(oX + 11, oY + 24, 1);
  setScreenPixel(oX + 14, oY + 24, 1);
  setScreenPixel(oX + 15, oY + 24, 1);
  setScreenPixel(oX + 16, oY + 24, 1);
  setScreenPixel(oX + 17, oY + 24, 1);
  setScreenPixel(oX + 18, oY + 24, 1);
  setScreenPixel(oX + 19, oY + 24, 1);
  setScreenPixel(oX + 20, oY + 24, 1);
  setScreenPixel(oX + 21, oY + 24, 1);
  setScreenPixel(oX + 22, oY + 24, 1);
  setScreenPixel(oX + 25, oY + 24, 1);
  setScreenPixel(oX + 26, oY + 24, 1);
  setScreenPixel(oX + 29, oY + 24, 1);
  setScreenPixel(oX + 32, oY + 24, 1);
  setScreenPixel(oX + 33, oY + 24, 1);
  setScreenPixel(oX + 36, oY + 24, 1);
  setScreenPixel(oX + 37, oY + 24, 1);
  setScreenPixel(oX + 38, oY + 24, 1);
  setScreenPixel(oX + 39, oY + 24, 1);
  setScreenPixel(oX + 40, oY + 24, 1);
  setScreenPixel(oX + 41, oY + 24, 1);
  setScreenPixel(oX + 42, oY + 24, 1);
  setScreenPixel(oX + 43, oY + 24, 1);
  setScreenPixel(oX + 3, oY + 23, 1);
  setScreenPixel(oX + 4, oY + 23, 1);
  setScreenPixel(oX + 8, oY + 23, 1);
  setScreenPixel(oX + 9, oY + 23, 1);
  setScreenPixel(oX + 10, oY + 23, 1);
  setScreenPixel(oX + 11, oY + 23, 1);
  setScreenPixel(oX + 14, oY + 23, 1);
  setScreenPixel(oX + 15, oY + 23, 1);
  setScreenPixel(oX + 16, oY + 23, 1);
  setScreenPixel(oX + 17, oY + 23, 1);
  setScreenPixel(oX + 18, oY + 23, 1);
  setScreenPixel(oX + 19, oY + 23, 1);
  setScreenPixel(oX + 20, oY + 23, 1);
  setScreenPixel(oX + 21, oY + 23, 1);
  setScreenPixel(oX + 22, oY + 23, 1);
  setScreenPixel(oX + 25, oY + 23, 1);
  setScreenPixel(oX + 26, oY + 23, 1);
  setScreenPixel(oX + 32, oY + 23, 1);
  setScreenPixel(oX + 33, oY + 23, 1);
  setScreenPixel(oX + 36, oY + 23, 1);
  setScreenPixel(oX + 37, oY + 23, 1);
  setScreenPixel(oX + 38, oY + 23, 1);
  setScreenPixel(oX + 39, oY + 23, 1);
  setScreenPixel(oX + 40, oY + 23, 1);
  setScreenPixel(oX + 41, oY + 23, 1);
  setScreenPixel(oX + 42, oY + 23, 1);
  setScreenPixel(oX + 43, oY + 23, 1);
  setScreenPixel(oX + 3, oY + 22, 1);
  setScreenPixel(oX + 4, oY + 22, 1);
  setScreenPixel(oX + 10, oY + 22, 1);
  setScreenPixel(oX + 11, oY + 22, 1);
  setScreenPixel(oX + 14, oY + 22, 1);
  setScreenPixel(oX + 15, oY + 22, 1);
  setScreenPixel(oX + 21, oY + 22, 1);
  setScreenPixel(oX + 22, oY + 22, 1);
  setScreenPixel(oX + 25, oY + 22, 1);
  setScreenPixel(oX + 26, oY + 22, 1);
  setScreenPixel(oX + 32, oY + 22, 1);
  setScreenPixel(oX + 33, oY + 22, 1);
  setScreenPixel(oX + 36, oY + 22, 1);
  setScreenPixel(oX + 37, oY + 22, 1);
  setScreenPixel(oX + 3, oY + 21, 1);
  setScreenPixel(oX + 4, oY + 21, 1);
  setScreenPixel(oX + 10, oY + 21, 1);
  setScreenPixel(oX + 11, oY + 21, 1);
  setScreenPixel(oX + 14, oY + 21, 1);
  setScreenPixel(oX + 15, oY + 21, 1);
  setScreenPixel(oX + 21, oY + 21, 1);
  setScreenPixel(oX + 22, oY + 21, 1);
  setScreenPixel(oX + 25, oY + 21, 1);
  setScreenPixel(oX + 26, oY + 21, 1);
  setScreenPixel(oX + 32, oY + 21, 1);
  setScreenPixel(oX + 33, oY + 21, 1);
  setScreenPixel(oX + 36, oY + 21, 1);
  setScreenPixel(oX + 37, oY + 21, 1);
  setScreenPixel(oX + 3, oY + 20, 1);
  setScreenPixel(oX + 4, oY + 20, 1);
  setScreenPixel(oX + 10, oY + 20, 1);
  setScreenPixel(oX + 11, oY + 20, 1);
  setScreenPixel(oX + 14, oY + 20, 1);
  setScreenPixel(oX + 15, oY + 20, 1);
  setScreenPixel(oX + 21, oY + 20, 1);
  setScreenPixel(oX + 22, oY + 20, 1);
  setScreenPixel(oX + 25, oY + 20, 1);
  setScreenPixel(oX + 26, oY + 20, 1);
  setScreenPixel(oX + 32, oY + 20, 1);
  setScreenPixel(oX + 33, oY + 20, 1);
  setScreenPixel(oX + 36, oY + 20, 1);
  setScreenPixel(oX + 37, oY + 20, 1);
  setScreenPixel(oX + 3, oY + 19, 1);
  setScreenPixel(oX + 4, oY + 19, 1);
  setScreenPixel(oX + 5, oY + 19, 1);
  setScreenPixel(oX + 6, oY + 19, 1);
  setScreenPixel(oX + 7, oY + 19, 1);
  setScreenPixel(oX + 8, oY + 19, 1);
  setScreenPixel(oX + 9, oY + 19, 1);
  setScreenPixel(oX + 10, oY + 19, 1);
  setScreenPixel(oX + 11, oY + 19, 1);
  setScreenPixel(oX + 14, oY + 19, 1);
  setScreenPixel(oX + 15, oY + 19, 1);
  setScreenPixel(oX + 21, oY + 19, 1);
  setScreenPixel(oX + 22, oY + 19, 1);
  setScreenPixel(oX + 25, oY + 19, 1);
  setScreenPixel(oX + 26, oY + 19, 1);
  setScreenPixel(oX + 32, oY + 19, 1);
  setScreenPixel(oX + 33, oY + 19, 1);
  setScreenPixel(oX + 36, oY + 19, 1);
  setScreenPixel(oX + 37, oY + 19, 1);
  setScreenPixel(oX + 38, oY + 19, 1);
  setScreenPixel(oX + 39, oY + 19, 1);
  setScreenPixel(oX + 40, oY + 19, 1);
  setScreenPixel(oX + 41, oY + 19, 1);
  setScreenPixel(oX + 42, oY + 19, 1);
  setScreenPixel(oX + 43, oY + 19, 1);
  setScreenPixel(oX + 44, oY + 19, 1);
  setScreenPixel(oX + 4, oY + 18, 1);
  setScreenPixel(oX + 5, oY + 18, 1);
  setScreenPixel(oX + 6, oY + 18, 1);
  setScreenPixel(oX + 7, oY + 18, 1);
  setScreenPixel(oX + 8, oY + 18, 1);
  setScreenPixel(oX + 9, oY + 18, 1);
  setScreenPixel(oX + 10, oY + 18, 1);
  setScreenPixel(oX + 11, oY + 18, 1);
  setScreenPixel(oX + 14, oY + 18, 1);
  setScreenPixel(oX + 15, oY + 18, 1);
  setScreenPixel(oX + 21, oY + 18, 1);
  setScreenPixel(oX + 22, oY + 18, 1);
  setScreenPixel(oX + 25, oY + 18, 1);
  setScreenPixel(oX + 26, oY + 18, 1);
  setScreenPixel(oX + 32, oY + 18, 1);
  setScreenPixel(oX + 33, oY + 18, 1);
  setScreenPixel(oX + 36, oY + 18, 1);
  setScreenPixel(oX + 37, oY + 18, 1);
  setScreenPixel(oX + 38, oY + 18, 1);
  setScreenPixel(oX + 39, oY + 18, 1);
  setScreenPixel(oX + 40, oY + 18, 1);
  setScreenPixel(oX + 41, oY + 18, 1);
  setScreenPixel(oX + 42, oY + 18, 1);
  setScreenPixel(oX + 43, oY + 18, 1);
  setScreenPixel(oX + 44, oY + 18, 1);
  setScreenPixel(oX + 4, oY + 13, 1);
  setScreenPixel(oX + 5, oY + 13, 1);
  setScreenPixel(oX + 6, oY + 13, 1);
  setScreenPixel(oX + 7, oY + 13, 1);
  setScreenPixel(oX + 8, oY + 13, 1);
  setScreenPixel(oX + 9, oY + 13, 1);
  setScreenPixel(oX + 10, oY + 13, 1);
  setScreenPixel(oX + 14, oY + 13, 1);
  setScreenPixel(oX + 15, oY + 13, 1);
  setScreenPixel(oX + 21, oY + 13, 1);
  setScreenPixel(oX + 22, oY + 13, 1);
  setScreenPixel(oX + 25, oY + 13, 1);
  setScreenPixel(oX + 26, oY + 13, 1);
  setScreenPixel(oX + 27, oY + 13, 1);
  setScreenPixel(oX + 28, oY + 13, 1);
  setScreenPixel(oX + 29, oY + 13, 1);
  setScreenPixel(oX + 30, oY + 13, 1);
  setScreenPixel(oX + 31, oY + 13, 1);
  setScreenPixel(oX + 32, oY + 13, 1);
  setScreenPixel(oX + 33, oY + 13, 1);
  setScreenPixel(oX + 36, oY + 13, 1);
  setScreenPixel(oX + 37, oY + 13, 1);
  setScreenPixel(oX + 38, oY + 13, 1);
  setScreenPixel(oX + 39, oY + 13, 1);
  setScreenPixel(oX + 40, oY + 13, 1);
  setScreenPixel(oX + 41, oY + 13, 1);
  setScreenPixel(oX + 42, oY + 13, 1);
  setScreenPixel(oX + 43, oY + 13, 1);
  setScreenPixel(oX + 3, oY + 12, 1);
  setScreenPixel(oX + 4, oY + 12, 1);
  setScreenPixel(oX + 5, oY + 12, 1);
  setScreenPixel(oX + 6, oY + 12, 1);
  setScreenPixel(oX + 7, oY + 12, 1);
  setScreenPixel(oX + 8, oY + 12, 1);
  setScreenPixel(oX + 9, oY + 12, 1);
  setScreenPixel(oX + 10, oY + 12, 1);
  setScreenPixel(oX + 11, oY + 12, 1);
  setScreenPixel(oX + 14, oY + 12, 1);
  setScreenPixel(oX + 15, oY + 12, 1);
  setScreenPixel(oX + 21, oY + 12, 1);
  setScreenPixel(oX + 22, oY + 12, 1);
  setScreenPixel(oX + 25, oY + 12, 1);
  setScreenPixel(oX + 26, oY + 12, 1);
  setScreenPixel(oX + 27, oY + 12, 1);
  setScreenPixel(oX + 28, oY + 12, 1);
  setScreenPixel(oX + 29, oY + 12, 1);
  setScreenPixel(oX + 30, oY + 12, 1);
  setScreenPixel(oX + 31, oY + 12, 1);
  setScreenPixel(oX + 32, oY + 12, 1);
  setScreenPixel(oX + 33, oY + 12, 1);
  setScreenPixel(oX + 36, oY + 12, 1);
  setScreenPixel(oX + 37, oY + 12, 1);
  setScreenPixel(oX + 38, oY + 12, 1);
  setScreenPixel(oX + 39, oY + 12, 1);
  setScreenPixel(oX + 40, oY + 12, 1);
  setScreenPixel(oX + 41, oY + 12, 1);
  setScreenPixel(oX + 42, oY + 12, 1);
  setScreenPixel(oX + 43, oY + 12, 1);
  setScreenPixel(oX + 44, oY + 12, 1);
  setScreenPixel(oX + 3, oY + 11, 1);
  setScreenPixel(oX + 4, oY + 11, 1);
  setScreenPixel(oX + 10, oY + 11, 1);
  setScreenPixel(oX + 11, oY + 11, 1);
  setScreenPixel(oX + 14, oY + 11, 1);
  setScreenPixel(oX + 15, oY + 11, 1);
  setScreenPixel(oX + 21, oY + 11, 1);
  setScreenPixel(oX + 22, oY + 11, 1);
  setScreenPixel(oX + 25, oY + 11, 1);
  setScreenPixel(oX + 26, oY + 11, 1);
  setScreenPixel(oX + 36, oY + 11, 1);
  setScreenPixel(oX + 37, oY + 11, 1);
  setScreenPixel(oX + 43, oY + 11, 1);
  setScreenPixel(oX + 44, oY + 11, 1);
  setScreenPixel(oX + 3, oY + 10, 1);
  setScreenPixel(oX + 4, oY + 10, 1);
  setScreenPixel(oX + 10, oY + 10, 1);
  setScreenPixel(oX + 11, oY + 10, 1);
  setScreenPixel(oX + 14, oY + 10, 1);
  setScreenPixel(oX + 15, oY + 10, 1);
  setScreenPixel(oX + 21, oY + 10, 1);
  setScreenPixel(oX + 22, oY + 10, 1);
  setScreenPixel(oX + 25, oY + 10, 1);
  setScreenPixel(oX + 26, oY + 10, 1);
  setScreenPixel(oX + 36, oY + 10, 1);
  setScreenPixel(oX + 37, oY + 10, 1);
  setScreenPixel(oX + 43, oY + 10, 1);
  setScreenPixel(oX + 44, oY + 10, 1);
  setScreenPixel(oX + 3, oY + 9, 1);
  setScreenPixel(oX + 4, oY + 9, 1);
  setScreenPixel(oX + 10, oY + 9, 1);
  setScreenPixel(oX + 11, oY + 9, 1);
  setScreenPixel(oX + 14, oY + 9, 1);
  setScreenPixel(oX + 15, oY + 9, 1);
  setScreenPixel(oX + 21, oY + 9, 1);
  setScreenPixel(oX + 22, oY + 9, 1);
  setScreenPixel(oX + 25, oY + 9, 1);
  setScreenPixel(oX + 26, oY + 9, 1);
  setScreenPixel(oX + 36, oY + 9, 1);
  setScreenPixel(oX + 37, oY + 9, 1);
  setScreenPixel(oX + 43, oY + 9, 1);
  setScreenPixel(oX + 44, oY + 9, 1);
  setScreenPixel(oX + 3, oY + 8, 1);
  setScreenPixel(oX + 4, oY + 8, 1);
  setScreenPixel(oX + 10, oY + 8, 1);
  setScreenPixel(oX + 11, oY + 8, 1);
  setScreenPixel(oX + 14, oY + 8, 1);
  setScreenPixel(oX + 15, oY + 8, 1);
  setScreenPixel(oX + 21, oY + 8, 1);
  setScreenPixel(oX + 22, oY + 8, 1);
  setScreenPixel(oX + 25, oY + 8, 1);
  setScreenPixel(oX + 26, oY + 8, 1);
  setScreenPixel(oX + 27, oY + 8, 1);
  setScreenPixel(oX + 28, oY + 8, 1);
  setScreenPixel(oX + 29, oY + 8, 1);
  setScreenPixel(oX + 30, oY + 8, 1);
  setScreenPixel(oX + 31, oY + 8, 1);
  setScreenPixel(oX + 32, oY + 8, 1);
  setScreenPixel(oX + 36, oY + 8, 1);
  setScreenPixel(oX + 37, oY + 8, 1);
  setScreenPixel(oX + 38, oY + 8, 1);
  setScreenPixel(oX + 39, oY + 8, 1);
  setScreenPixel(oX + 40, oY + 8, 1);
  setScreenPixel(oX + 41, oY + 8, 1);
  setScreenPixel(oX + 42, oY + 8, 1);
  setScreenPixel(oX + 43, oY + 8, 1);
  setScreenPixel(oX + 3, oY + 7, 1);
  setScreenPixel(oX + 4, oY + 7, 1);
  setScreenPixel(oX + 10, oY + 7, 1);
  setScreenPixel(oX + 11, oY + 7, 1);
  setScreenPixel(oX + 14, oY + 7, 1);
  setScreenPixel(oX + 15, oY + 7, 1);
  setScreenPixel(oX + 21, oY + 7, 1);
  setScreenPixel(oX + 22, oY + 7, 1);
  setScreenPixel(oX + 25, oY + 7, 1);
  setScreenPixel(oX + 26, oY + 7, 1);
  setScreenPixel(oX + 27, oY + 7, 1);
  setScreenPixel(oX + 28, oY + 7, 1);
  setScreenPixel(oX + 29, oY + 7, 1);
  setScreenPixel(oX + 30, oY + 7, 1);
  setScreenPixel(oX + 31, oY + 7, 1);
  setScreenPixel(oX + 32, oY + 7, 1);
  setScreenPixel(oX + 36, oY + 7, 1);
  setScreenPixel(oX + 37, oY + 7, 1);
  setScreenPixel(oX + 38, oY + 7, 1);
  setScreenPixel(oX + 39, oY + 7, 1);
  setScreenPixel(oX + 40, oY + 7, 1);
  setScreenPixel(oX + 41, oY + 7, 1);
  setScreenPixel(oX + 42, oY + 7, 1);
  setScreenPixel(oX + 43, oY + 7, 1);
  setScreenPixel(oX + 3, oY + 6, 1);
  setScreenPixel(oX + 4, oY + 6, 1);
  setScreenPixel(oX + 10, oY + 6, 1);
  setScreenPixel(oX + 11, oY + 6, 1);
  setScreenPixel(oX + 14, oY + 6, 1);
  setScreenPixel(oX + 15, oY + 6, 1);
  setScreenPixel(oX + 21, oY + 6, 1);
  setScreenPixel(oX + 22, oY + 6, 1);
  setScreenPixel(oX + 25, oY + 6, 1);
  setScreenPixel(oX + 26, oY + 6, 1);
  setScreenPixel(oX + 36, oY + 6, 1);
  setScreenPixel(oX + 37, oY + 6, 1);
  setScreenPixel(oX + 42, oY + 6, 1);
  setScreenPixel(oX + 43, oY + 6, 1);
  setScreenPixel(oX + 44, oY + 6, 1);
  setScreenPixel(oX + 3, oY + 5, 1);
  setScreenPixel(oX + 4, oY + 5, 1);
  setScreenPixel(oX + 10, oY + 5, 1);
  setScreenPixel(oX + 11, oY + 5, 1);
  setScreenPixel(oX + 14, oY + 5, 1);
  setScreenPixel(oX + 15, oY + 5, 1);
  setScreenPixel(oX + 16, oY + 5, 1);
  setScreenPixel(oX + 20, oY + 5, 1);
  setScreenPixel(oX + 21, oY + 5, 1);
  setScreenPixel(oX + 22, oY + 5, 1);
  setScreenPixel(oX + 25, oY + 5, 1);
  setScreenPixel(oX + 26, oY + 5, 1);
  setScreenPixel(oX + 36, oY + 5, 1);
  setScreenPixel(oX + 37, oY + 5, 1);
  setScreenPixel(oX + 43, oY + 5, 1);
  setScreenPixel(oX + 44, oY + 5, 1);
  setScreenPixel(oX + 3, oY + 4, 1);
  setScreenPixel(oX + 4, oY + 4, 1);
  setScreenPixel(oX + 10, oY + 4, 1);
  setScreenPixel(oX + 11, oY + 4, 1);
  setScreenPixel(oX + 15, oY + 4, 1);
  setScreenPixel(oX + 16, oY + 4, 1);
  setScreenPixel(oX + 17, oY + 4, 1);
  setScreenPixel(oX + 19, oY + 4, 1);
  setScreenPixel(oX + 20, oY + 4, 1);
  setScreenPixel(oX + 21, oY + 4, 1);
  setScreenPixel(oX + 25, oY + 4, 1);
  setScreenPixel(oX + 26, oY + 4, 1);
  setScreenPixel(oX + 36, oY + 4, 1);
  setScreenPixel(oX + 37, oY + 4, 1);
  setScreenPixel(oX + 43, oY + 4, 1);
  setScreenPixel(oX + 44, oY + 4, 1);
  setScreenPixel(oX + 3, oY + 3, 1);
  setScreenPixel(oX + 4, oY + 3, 1);
  setScreenPixel(oX + 5, oY + 3, 1);
  setScreenPixel(oX + 6, oY + 3, 1);
  setScreenPixel(oX + 7, oY + 3, 1);
  setScreenPixel(oX + 8, oY + 3, 1);
  setScreenPixel(oX + 9, oY + 3, 1);
  setScreenPixel(oX + 10, oY + 3, 1);
  setScreenPixel(oX + 11, oY + 3, 1);
  setScreenPixel(oX + 16, oY + 3, 1);
  setScreenPixel(oX + 17, oY + 3, 1);
  setScreenPixel(oX + 18, oY + 3, 1);
  setScreenPixel(oX + 19, oY + 3, 1);
  setScreenPixel(oX + 20, oY + 3, 1);
  setScreenPixel(oX + 25, oY + 3, 1);
  setScreenPixel(oX + 26, oY + 3, 1);
  setScreenPixel(oX + 27, oY + 3, 1);
  setScreenPixel(oX + 28, oY + 3, 1);
  setScreenPixel(oX + 29, oY + 3, 1);
  setScreenPixel(oX + 30, oY + 3, 1);
  setScreenPixel(oX + 31, oY + 3, 1);
  setScreenPixel(oX + 32, oY + 3, 1);
  setScreenPixel(oX + 33, oY + 3, 1);
  setScreenPixel(oX + 36, oY + 3, 1);
  setScreenPixel(oX + 37, oY + 3, 1);
  setScreenPixel(oX + 43, oY + 3, 1);
  setScreenPixel(oX + 44, oY + 3, 1);
  setScreenPixel(oX + 4, oY + 2, 1);
  setScreenPixel(oX + 5, oY + 2, 1);
  setScreenPixel(oX + 6, oY + 2, 1);
  setScreenPixel(oX + 7, oY + 2, 1);
  setScreenPixel(oX + 8, oY + 2, 1);
  setScreenPixel(oX + 9, oY + 2, 1);
  setScreenPixel(oX + 10, oY + 2, 1);
  setScreenPixel(oX + 17, oY + 2, 1);
  setScreenPixel(oX + 18, oY + 2, 1);
  setScreenPixel(oX + 19, oY + 2, 1);
  setScreenPixel(oX + 25, oY + 2, 1);
  setScreenPixel(oX + 26, oY + 2, 1);
  setScreenPixel(oX + 27, oY + 2, 1);
  setScreenPixel(oX + 28, oY + 2, 1);
  setScreenPixel(oX + 29, oY + 2, 1);
  setScreenPixel(oX + 30, oY + 2, 1);
  setScreenPixel(oX + 31, oY + 2, 1);
  setScreenPixel(oX + 32, oY + 2, 1);
  setScreenPixel(oX + 33, oY + 2, 1);
  setScreenPixel(oX + 36, oY + 2, 1);
  setScreenPixel(oX + 37, oY + 2, 1);
  setScreenPixel(oX + 43, oY + 2, 1);
  setScreenPixel(oX + 44, oY + 2, 1);
}
