#include "Constants.h"

void frontAngleCalibrate() {
//  Serial.println("Enter frontAngleCalibrate");
  short leftSensorPin, rightSensorPin;
  float multiplier;
  float gap;
//  Serial.print("SRFL: ");
//  Serial.println(getSRFLdist());
//  Serial.print("SRFC: ");
//  Serial.println(getSRFCdist());
//  Serial.print("SRFR: ");
//  Serial.println(getSRFRdist());
  float left = getSRFLdistInstant();
  float center = getSRFCdistInstant();
  float right = getSRFRdistInstant();
  if (left <= Constants::MAX_DIST_FOR_CALIBRATE && right <= Constants::MAX_DIST_FOR_CALIBRATE) {
    leftSensorPin = Constants::SRFL_PIN;
    rightSensorPin = Constants::SRFR_PIN;
    multiplier = 1.0 / 2;
    gap = 0;
//    multiplier = 1;
  } else if (center <= Constants::MAX_DIST_FOR_CALIBRATE && right <= Constants::MAX_DIST_FOR_CALIBRATE) {
    leftSensorPin = Constants::SRFC_PIN;
    rightSensorPin = Constants::SRFR_PIN;
    multiplier = 1;
    gap = 0;
  } else if (left <= Constants::MAX_DIST_FOR_CALIBRATE && center <= Constants::MAX_DIST_FOR_CALIBRATE) {
    leftSensorPin = Constants::SRFL_PIN;
    rightSensorPin = Constants::SRFC_PIN;
    multiplier = 1;
    gap = 0;
  } 
//    else if (left <= Constants::MAX_DIST_FOR_CALIBRATE && 13 <= center && center <= 17) {
//    leftSensorPin = Constants::SRFL_PIN;
//    rightSensorPin = Constants::SRFC_PIN;
//    multiplier = 1;
//    gap = 10.65;
//  } 
//    else if (12 <= left && left <= 19 && center <= Constants::MAX_DIST_FOR_CALIBRATE) {
//    leftSensorPin = Constants::SRFL_PIN;
//    rightSensorPin = Constants::SRFC_PIN;
//    multiplier = 1;
//    gap = -9.7;
//  } else if (center <= Constants::MAX_DIST_FOR_CALIBRATE && 12 <= right && right <= 18) {
//    leftSensorPin = Constants::SRFC_PIN;
//    rightSensorPin = Constants::SRFR_PIN;
//    multiplier = 1;
//    gap = 11;
//  } else if (12 <= center && center <= 19 && right <= Constants::MAX_DIST_FOR_CALIBRATE) {
//    leftSensorPin = Constants::SRFC_PIN;
//    rightSensorPin = Constants::SRFR_PIN;
//    multiplier = 1;
//    gap = -10.8;
//  } else if (12 <= left && left <= 19 && 12 <= right && right <= 18) {
//    leftSensorPin = Constants::SRFL_PIN;
//    rightSensorPin = Constants::SRFR_PIN;
//    multiplier = 1.0 / 2;
//    gap = 0.5;
//  } else if (12 <= left && left <= 19 && 12 <= center && center <= 18) {
//    leftSensorPin = Constants::SRFL_PIN;
//    rightSensorPin = Constants::SRFC_PIN;
//    multiplier = 1;
//    gap = 0.7;
//  } 
//  else if (12 <= center && center <= 19 && 12 <= right && right <= 18) {
//    leftSensorPin = Constants::SRFC_PIN;
//    rightSensorPin = Constants::SRFR_PIN;
//    multiplier = 1;
//    gap = -0.2;
//  }
  else {
    return; //No 2 obstacles in front to calibrate
  }
  
  // Difference of right sensor and left sensor
  float diff = getSensorDist(rightSensorPin) - getSensorDist(leftSensorPin) - gap;
  float offset = 0;// 0.36;
  /*
  if (diff > 0) {  // Head is further than tail
    offset = 0.3;
  } else {
    offset = 0.3;
  }
  */
  diff += offset;
  float prev_diff;
//  Serial.print("diff: ");
//  Serial.println(diff);
  
  short cnt = 0;
  while (cnt < Constants::MAX_TRIAL && abs(diff) > 0.05) {
    prev_diff = diff;
    // As distance is small, it is nearly equal to the arc to rotate
    // Rotate (abs(diff) * multiplier)
    if (diff < 0) {  // Right is closer to the wall -> Turn right
      rotateRightShort(abs(diff) * multiplier);
    } else {        // Left is closer to the wall -> Turn left
      rotateLeftShort(abs(diff) * multiplier);
    }
    delay(80);
    diff = getSensorDist(rightSensorPin) - getSensorDist(leftSensorPin) - gap;
//    if (diff > 0) {  // Head is further than tail
//      offset = 0;
//    } else {
//      offset = 0;
//    }
    diff += offset;
    cnt++;

    if (abs(diff) > 5)
      break;

//    Serial.print("SRFL: ");
//    Serial.println(getSRFLdist());
//    Serial.print("SRFC: ");
//    Serial.println(getSRFCdist());
//    Serial.print("SRFR: ");
//    Serial.println(getSRFRdist());
//    Serial.print("diff: ");
//    Serial.println(diff);
//    if ((abs(diff) > abs(prev_diff)) & (abs(diff - prev_diff) > 0.2))
//      break;
  }
//  Serial.print("SRFL: ");
//  Serial.println(getSRFLdist());
//  Serial.print("SRFC: ");
//  Serial.println(getSRFCdist());
//  Serial.print("SRFR: ");
//  Serial.println(getSRFRdist());
  delay(Constants::DELAY);
}

void frontDistanceCalibrate() {
//  Serial.println("Enter frontDistanceCalibrate");
  // Not calibrate when front dist is more than the max dist for calibrate
//  Serial.print("avgFrontDist: ");
//  Serial.println(avgFrontDist());
  if (avgFrontDist() > Constants::MAX_DIST_FOR_CALIBRATE)
    return;

  float diff = avgFrontDist() - Constants::MIN_DIST;
  short cnt = 0;
  while (cnt < Constants::MAX_TRIAL && abs(diff) > Constants::THRESHOLD) {
    if (diff < 0) {  // Too close to the wall -> Move backwards
      moveShort('B', abs(diff) * 0.5);
    } else {         // Too far from the wall -> Move forwards
      moveShort('F', abs(diff));
    }

    diff = avgFrontDist() - Constants::MIN_DIST;
    cnt++;

//    Serial.print("diff: ");
//    Serial.println(diff);
    if (abs(diff) > 5)
      break;
  }
  delay(Constants::DELAY);
}

bool leftAngleCalibrate() {
//  Serial.println("Enter leftAngleCalibrate");
//  Serial.print("SRLH: ");
//  Serial.println(getSRLHdist());
//  Serial.print("SRLT: ");
//  Serial.println(getSRLTdist());
  // Not enough obstacles to calibrate
  float head = getSRLHdistInstant();
  float tail = getSRLTdistInstant();
//  if ((head > Constants::MAX_DIST_FOR_CALIBRATE || tail > Constants::MAX_DIST_FOR_CALIBRATE) && !(12 < head && head < 18 && 12 < tail && tail < 18))
  if (head > Constants::MAX_DIST_FOR_CALIBRATE || tail > Constants::MAX_DIST_FOR_CALIBRATE)
    return false;
  if (head < 2 || tail < 2)
    return false;

  // Difference of right sensor and left sensor
  float diff = getSRLHdist()- getSRLTdist();
  float offset;
//  if (diff > 0) {  // Head is further than tail
//    offset = 0;
//  } else {
//    offset = 0;
//  }
//  if (12 < head && head < 18)
//    offset = 0.6;
  diff += offset;
  float prev_diff;
//  Serial.print("diff: ");
//  Serial.println(diff);
  
  short cnt = 0;
  while (cnt < Constants::MAX_TRIAL && abs(diff) > 0.05) {
    prev_diff = diff;
    // As distance is small, it is nearly equal to the arc to rotate
    // Rotate (abs(diff) / 2)I
    if (diff < 0) {  // Right is closer to the wall -> Turn right
//      rotateRightShort(abs(diff) / 2);
      rotateRightShort(abs(diff) * 0.6);
    } else {        // Left is closer to the wall -> Turn left
//      rotateLeftShort(abs(diff) / 2);
      rotateLeftShort(abs(diff) * 0.3);
    }
    delay(80);
    diff = getSRLHdist()- getSRLTdist();
    diff += offset;
    cnt++;

//    Serial.print("diff: ");
//    Serial.println(diff);
//    if ((abs(diff) > abs(prev_diff)) & (abs(diff - prev_diff) > 0.2))
//      break;
    if (abs(diff) > 5)
      break;
  }
//  Serial.print("SRLH: ");
//  Serial.println(getSRLHdist());
//  Serial.print("SRLT: ");
//  Serial.println(getSRLTdist());
  delay(Constants::DELAY);
  return true;
}

void fullCalibrate() {
  float leftDist = avgLeftDist();
  bool calibrateLeft = false;
  // Calibrate left distance
  leftDistanceCalibrate();
//  if (leftDist != Constants::INF && (leftDist < 4.6 || leftDist > 5.4)) {
//    leftPID();
//    delay(Constants::TURN_DELAY);
//    frontCalibrate();
//    rightPID();
//    delay(Constants::TURN_DELAY);
//    calibrateLeft = true;
//  }
//  leftAngleCalibrate();
  frontCalibrate();
  leftAngleCalibrate();
  if (leftDist < Constants::MAX_DIST_FOR_CALIBRATE)
    calibrateLeft = true;
  // Calibrate right only when not calibrate left and have obstacle on the right
  float LRR = getLRRdistInstant();
  if (!calibrateLeft && LRR < Constants::MAX_DIST_FOR_CALIBRATE && abs(LRR - Constants::MIN_DIST) > Constants::THRESHOLD) {
    rightPID();
    delay(Constants::TURN_DELAY);
    frontCalibrate();
    
    leftPID();
    delay(Constants::TURN_DELAY);
    frontCalibrate();
  }
}

void leftDistanceCalibrate() {
  // Calibrate left distance
  if (getSRLHdistInstant() > Constants::MAX_DIST_FOR_CALIBRATE || getSRLTdistInstant() > Constants::MAX_DIST_FOR_CALIBRATE)
    return;
  
  float leftDist = avgLeftDist();
  if (leftDist != Constants::INF && (leftDist < 4 || leftDist > 5.9)) {
    leftPID();
    delay(Constants::TURN_DELAY);
    frontCalibrate();
    rightPID();
    delay(Constants::TURN_DELAY);
  }
}

void frontCalibrate() {
  frontDistanceCalibrate();
  frontAngleCalibrate();
//  frontAngleCalibrate();
//  frontAngleCalibrate();
//  frontDistanceCalibrate();
}

void rightCalibrate() {
  if (getLRRdistInstant() < Constants::MAX_DIST_FOR_CALIBRATE && abs(getLRRdistInstant() - Constants::MIN_DIST) > Constants::THRESHOLD) {
    rightPID();
    delay(Constants::TURN_DELAY);
    frontCalibrate();
    
    leftPID();
    delay(Constants::TURN_DELAY);
    frontCalibrate();
  }
}

void initialCalibrate() {
  leftPID();
  delay(Constants::TURN_DELAY);
  leftPID();
  delay(Constants::TURN_DELAY);
  frontCalibrate();
  
  rightPID();
  delay(Constants::TURN_DELAY);
  frontCalibrate();
  
  rightPID();
  delay(Constants::TURN_DELAY);
  leftAngleCalibrate();
}
