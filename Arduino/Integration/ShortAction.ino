#include "Constants.h"
#include "KickSort.h"

void rotateRightShort(float arc) {
//  Serial.println("rotateRightShort");
  float offset = 0.5;
//  float offset = 1;
  float travel_ticks = distToTick(abs(arc * offset));
//  Serial.print("travel_ticks: ");
//  Serial.println(travel_ticks);
  E1_ticks = 0;
  E2_ticks = 0;
  E1_ticks_moved = 0;
  E2_ticks_moved = 0;

  M1_speed = -1 * 200;
  M2_speed = 193;
  md.setSpeeds(M1_speed, M2_speed);

  while (E1_ticks_moved < travel_ticks && E2_ticks_moved < travel_ticks) {
//    Serial.print("E1_ticks_moved: ");
//    Serial.println(E1_ticks_moved);
//    Serial.print("E2_ticks_moved: ");
//    Serial.println(E2_ticks_moved);
  }

  md.setSpeeds(0, 0);
  md.setBrakes(400, 400);
}

void rotateLeftShort(float arc) {
//  Serial.println("rotateLeftShort");
  float offset = 0.5;
//  float offset = 1;
  float travel_ticks = distToTick(abs(arc * offset));
//  Serial.print("travel_ticks: ");
//  Serial.println(travel_ticks);
  E1_ticks = 0;
  E2_ticks = 0;
  E1_ticks_moved = 0;
  E2_ticks_moved = 0;

  M1_speed = 200;
  M2_speed = -1 * 215;
  md.setSpeeds(M1_speed, M2_speed);

  while (E1_ticks_moved < travel_ticks && E2_ticks_moved < travel_ticks) {
//    Serial.print("E1_ticks_moved: ");
//    Serial.println(E1_ticks_moved);
//    Serial.print("E2_ticks_moved: ");
//    Serial.println(E2_ticks_moved);
  }

  md.setSpeeds(0, 0);
  md.setBrakes(400, 400);
}
/**
 * Move forward or backward
 * Forward: 'F', Backwards: 'B'
 */
void moveShort(char dir, float dist) {
  float offset = 0.5;
  float travel_ticks = distToTick(dist * offset);
  E1_ticks = 0;
  E2_ticks = 0;
  E1_ticks_moved = 0;
  E2_ticks_moved = 0;

  short M1_mul, M2_mul;
  if (dir == 'F') {
    M1_mul = 1; M2_mul = 1;
  } else if (dir == 'B') {
    M1_mul = -1; M2_mul = -1;
  } else {
    return;
  }
  M1_speed = M1_mul * 350;
  M2_speed = M2_mul * 345;
  md.setSpeeds(M1_speed, M2_speed);

  while (E1_ticks_moved < travel_ticks && E2_ticks_moved < travel_ticks);

  md.setSpeeds(0, 0);
  md.setBrakes(400, 400);
}
