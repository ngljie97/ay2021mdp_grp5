#include "Constants.h"


float RPMtoSpeedM1(float rpm1){
  return 2.4906*rpm1 + 7.143;
}

float RPMtoSpeedM2(float rpm2){
  return 2.4739*rpm2 + 10.883;
}

float ticksToRPM(long tick) {
  return (tick * 1.0 / 562.25) / SAMPLETIME * 60;
}

long RPMtoTicks(float rpm) {
  return (long)(rpm * 562.25 * SAMPLETIME / 60);
}

float roundTo1DecimalPlace(float var) 
{ 
    float value = (int)(var * 10 + .5); 
    return (float)value / 10; 
} 

float computeSpeedM2(float speedM1) {
  float res = (speedM1 - 7.143) / 2.4906 * 2.4739 + 10.883;
  return roundTo1DecimalPlace(res);
}

float tickToDist(long tick) {
  return PI * Constants::WHEEL_DIAMETER * (tick / Constants::TPR);
}

float distToTick(float dist) {
  return dist / (PI * Constants::WHEEL_DIAMETER) * Constants::TPR;
}

short tickToBlock(float tick) {
  float dist = tickToDist(tick);
  for (short i = 0 ; i <= 5 ; i++) {
    if (abs(dist - i * Constants::BLOCK_SIZE) <= 2)
      return i;
  }
  return 0;
}

float degreeToDist(float degree) {
  // ?????
  return ((17*PI)/360)*degree;
//  return Constants::WHEEL_DIAMETER / 2 * PI * degree / 180;
}
