#include "Constants.h"

void frontAngleCalibrate() {
//  Serial.println("Enter frontAngleCalibrate");
  short leftSensorPin, rightSensorPin;
  float multiplier;
//  Serial.print("SRFL: ");
//  Serial.println(getSRFLdist());
//  Serial.print("SRFC: ");
//  Serial.println(getSRFCdist());
//  Serial.print("SRFR: ");
//  Serial.println(getSRFRdist());
  if (getSRFLdist() <= Constants::MAX_DIST_FOR_CALIBRATE && getSRFRdist() <= Constants::MAX_DIST_FOR_CALIBRATE) {
    leftSensorPin = Constants::SRFL_PIN;
    rightSensorPin = Constants::SRFR_PIN;
    multiplier = 1.0 / 2;
//    multiplier = 1;
  } else if (getSRFCdist() <= Constants::MAX_DIST_FOR_CALIBRATE && getSRFRdist() <= Constants::MAX_DIST_FOR_CALIBRATE) {
    leftSensorPin = Constants::SRFC_PIN;
    rightSensorPin = Constants::SRFR_PIN;
    multiplier = 1;
  } else if (getSRFLdist() <= Constants::MAX_DIST_FOR_CALIBRATE && getSRFCdist() <= Constants::MAX_DIST_FOR_CALIBRATE) {
    leftSensorPin = Constants::SRFL_PIN;
    rightSensorPin = Constants::SRFC_PIN;
    multiplier = 1;
  } else {
    return; //No 2 obstacles in front to calibrate
  }
  // Difference of right sensor and left sensor
  float diff = getSensorDist(rightSensorPin) - getSensorDist(leftSensorPin);
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
    diff = getSensorDist(rightSensorPin) - getSensorDist(leftSensorPin);
//    if (diff > 0) {  // Head is further than tail
//      offset = 0;
//    } else {
//      offset = 0;
//    }
    diff += offset;
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
  float offset;
  if (diff > 0) {  // Head is further than tail
    offset = 0;
  } else {
    offset = 0;
  }
  diff += offset;
  float prev_diff;
//  Serial.print("diff: ");
//  Serial.println(diff);
  
  short cnt = 0;
  while (cnt < Constants::MAX_TRIAL && abs(diff) > 0.02) {
    prev_diff = diff;
    // As distance is small, it is nearly equal to the arc to rotate
    // Rotate (abs(diff) / 2)I
    if (diff < 0) {  // Right is closer to the wall -> Turn right
//      rotateRightShort(abs(diff) / 2);
      rotateRightShort(abs(diff) * 0.6);
    } else {        // Left is closer to the wall -> Turn left
//      rotateLeftShort(abs(diff) / 2);
      rotateLeftShort(abs(diff) * 0.6);
    }
    delay(80);
    diff = getSRLHdist()- getSRLTdist();
    if (diff > 0) {  // Head is further than tail
      offset = 0;
    } else {
      offset = 0;
    }
    diff += offset;
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
    leftPID();
    delay(200);
    frontCalibrate();
    rightPID();
    delay(200);
    calibrateLeft = true;
  }
//  leftAngleCalibrate();
  frontCalibrate();
//  leftAngleCalibrate();
  // Calibrate right only when not calibrate left and have obstacle on the right
  if (!calibrateLeft && getLRRdist() < Constants::MAX_DIST_FOR_CALIBRATE && abs(getLRRdist() - Constants::MIN_DIST) > Constants::THRESHOLD) {
    rightPID();
    delay(200);
    frontCalibrate();
    
    leftPID();
    delay(200);
    frontCalibrate();
  }
}

void leftDistanceCalibrate() {
  // Calibrate left distance
  if (avgLeftDist() != Constants::INF && abs(avgLeftDist() - Constants::MIN_DIST) > Constants::THRESHOLD) {
    leftPID();
    delay(200);
    frontCalibrate();
    rightPID();
    delay(200);
  }
}

void frontCalibrate() {
  frontAngleCalibrate();
  frontDistanceCalibrate();
}

void rightCalibrate() {
  if (getLRRdist() < Constants::MAX_DIST_FOR_CALIBRATE && abs(getLRRdist() - Constants::MIN_DIST) > Constants::THRESHOLD) {
    rightPID();
    delay(200);
    frontCalibrate();
    
    leftPID();
    delay(200);
    frontCalibrate();
  }
}

void initialCalibrate() {
  leftPID();
  delay(200);
  leftPID();
  delay(200);
  frontCalibrate();
  
  rightPID();
  delay(200);
  frontCalibrate();
  
  rightPID();
  delay(200);
  leftAngleCalibrate();
}
