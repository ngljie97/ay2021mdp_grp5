#include "Constants.h"

void frontAngleCalibrate() {
//  Serial.println("Enter frontAngleCalibrate");
  short leftSensorPin, rightSensorPin;
  float offset, multiplier;
//  Serial.print("SRFL: ");
//  Serial.println(getSRFLdist());
//  Serial.print("SRFC: ");
//  Serial.println(getSRFCdist());
//  Serial.print("SRFR: ");
//  Serial.println(getSRFRdist());
  if (getSRFLdist() <= Constants::MAX_DIST_FOR_CALIBRATE && getSRFRdist() <= Constants::MAX_DIST_FOR_CALIBRATE) {
    leftSensorPin = Constants::SRFL_PIN;
    rightSensorPin = Constants::SRFR_PIN;
//    offset = 0;
    multiplier = 1.0 / 2;
//    multiplier = 1;
  } else if (getSRFCdist() <= Constants::MAX_DIST_FOR_CALIBRATE && getSRFRdist() <= Constants::MAX_DIST_FOR_CALIBRATE) {
    leftSensorPin = Constants::SRFC_PIN;
    rightSensorPin = Constants::SRFR_PIN;
//    offset = Constants::SRFR_MIN_DIST - Constants::SRFC_MIN_DIST;
    multiplier = 1;
  } else if (getSRFLdist() <= Constants::MAX_DIST_FOR_CALIBRATE && getSRFCdist() <= Constants::MAX_DIST_FOR_CALIBRATE) {
    leftSensorPin = Constants::SRFL_PIN;
    rightSensorPin = Constants::SRFC_PIN;
//    offset = Constants::SRFC_MIN_DIST - Constants::SRFL_MIN_DIST;
    multiplier = 1;
  } else {
    return; //No 2 obstacles in front to calibrate
  }
  // Difference of right sensor and left sensor
//  float diff = getSensorDist(rightSensorPin) - getSensorDist(leftSensorPin) - offset;
  float diff = getSensorDist(rightSensorPin) - getSensorDist(leftSensorPin);
  float prev_diff;
//  Serial.print("diff: ");
//  Serial.println(diff);
  
  short cnt = 0;
  while (cnt < Constants::MAX_TRIAL && abs(diff) > Constants::THRESHOLD) {
    prev_diff = diff;
    // As distance is small, it is nearly equal to the arc to rotate
    // Rotate (abs(diff) * multiplier)
    if (diff < 0) {  // Right is closer to the wall -> Turn right
      rotateRightShort(abs(diff) * multiplier);
    } else {        // Left is closer to the wall -> Turn left
      rotateLeftShort(abs(diff) * multiplier);
    }
    delay(80);
//    diff = getSensorDist(rightSensorPin) - getSensorDist(leftSensorPin) - offset;
    diff = getSensorDist(rightSensorPin) - getSensorDist(leftSensorPin);
    cnt++;
    
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
      moveShort('B', abs(diff));
    } else {         // Too far from the wall -> Move forwards
      moveShort('F', abs(diff));
    }

    diff = avgFrontDist() - Constants::MIN_DIST;
    cnt++;

//    Serial.print("diff: ");
//    Serial.println(diff);
  }
  delay(Constants::DELAY);
}

void leftAngleCalibrate() {
//  Serial.println("Enter leftAngleCalibrate");
//  Serial.print("SRLH: ");
//  Serial.println(getSRLHdist());
//  Serial.print("SRLT: ");
//  Serial.println(getSRLTdist());
  // Not enough obstacles to calibrate
  if (getSRLHdist() > Constants::MAX_DIST_FOR_CALIBRATE || getSRLTdist() > Constants::MAX_DIST_FOR_CALIBRATE)
    return;
    
  // Difference of right sensor and left sensor
  float diff = getSRLHdist()- getSRLTdist();
  float prev_diff;
//  Serial.print("diff: ");
//  Serial.println(diff);
  
  short cnt = 0;
  while (cnt < Constants::MAX_TRIAL && abs(diff) > 0.05) {
    prev_diff = diff;
    // As distance is small, it is nearly equal to the arc to rotate
    // Rotate (abs(diff) / 2)
    if (diff < 0) {  // Right is closer to the wall -> Turn right
      rotateRightShort(abs(diff) / 2);
    } else {        // Left is closer to the wall -> Turn left
      rotateLeftShort(abs(diff) / 2);
    }
    delay(80);
    diff = getSRLHdist()- getSRLTdist();
    cnt++;

//    Serial.print("diff: ");
//    Serial.println(diff);
//    if ((abs(diff) > abs(prev_diff)) & (abs(diff - prev_diff) > 0.2))
//      break;
  }
//  Serial.print("SRLH: ");
//  Serial.println(getSRLHdist());
//  Serial.print("SRLT: ");
//  Serial.println(getSRLTdist());
  delay(Constants::DELAY);
}

void fullCalibrate() {
  float leftDist = avgLeftDist();
  bool calibrateLeft = false;
  // Calibrate left distance
  if (avgLeftDist() != Constants::INF && abs(avgLeftDist() - Constants::MIN_DIST) > Constants::THRESHOLD) {
    rotateLeftPID(90);
    frontCalibrate();
    rotateRightPID(90);
    calibrateLeft = true;
  }
  leftAngleCalibrate();
  frontCalibrate();
//  leftAngleCalibrate();
  // Calibrate right only when not calibrate left and have obstacle on the right
  if (!calibrateLeft && getSRLTdist() < Constants::MAX_DIST_FOR_CALIBRATE && abs(getSRLTdist() - Constants::MIN_DIST) > Constants::THRESHOLD) {
    rotateRightPID(90);
    frontCalibrate();
    rotateLeftPID(90);
    frontCalibrate();
  }
}

void frontCalibrate() {
  frontAngleCalibrate();
  frontDistanceCalibrate();
}

void rightCalibrate() {
  rotateRightPID(90);
  frontCalibrate();
  rotateLeftPID(90);
  frontCalibrate();
}
