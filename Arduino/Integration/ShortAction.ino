#include "Constants.h"
#include "KickSort.h"

/**
 * Rotate short left or right
 * Left: 'L', Right: 'R'
 */
void rotateShort(char dir, float arc) {
  float offset = 0.8;
//  float offset = 1;
  float travel_ticks = distToTick(abs(arc * offset));
  E1_ticks = 0;
  E2_ticks = 0;
  long E1_ticks_moved = 0;
  long E2_ticks_moved = 0;

  short M1_mul, M2_mul;
  if (dir == 'L') {
    M1_mul = 1; M2_mul = -1;
  } else if (dir == 'R') {
    M1_mul = -1; M2_mul = 1;
  } else {
    return;
  }
  M1_speed = M1_mul * 400;
  M2_speed = M2_mul * 400;
  md.setSpeeds(M1_speed, M2_speed);

  while (E1_ticks_moved < travel_ticks && E2_ticks_moved < travel_ticks);

  md.setSpeeds(0, 0);
  md.setBrakes(400, 400);
}
/**
 * Move forward or backward
 * Forward: 'F', Backwards: 'B'
 */
void moveShort(char dir, float dist) {
  float travel_ticks = distToTick(dist);
  E1_ticks = 0;
  E2_ticks = 0;
  long E1_ticks_moved = 0;
  long E2_ticks_moved = 0;

  short M1_mul, M2_mul;
  if (dir == 'F') {
    M1_mul = 1; M2_mul = 1;
  } else if (dir == 'B') {
    M1_mul = -1; M2_mul = -1;
  } else {
    return;
  }
  M1_speed = M1_mul * Constants::SPEED;
  M2_speed = M2_mul * Constants::SPEED;
  md.setSpeeds(M1_speed, M2_speed);

  while (E1_ticks_moved < travel_ticks && E2_ticks_moved < travel_ticks);

  md.setSpeeds(0, 0);
  md.setBrakes(400, 400);
}
