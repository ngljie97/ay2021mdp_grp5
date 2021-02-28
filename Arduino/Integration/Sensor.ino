#include "Constants.h"
#include "KickSort.h"

short readSensor(short sensorPin) {
  short analogReadings[Constants::SENSOR_SAMPLING];
  for (short i = 0 ; i < Constants::SENSOR_SAMPLING ; i++) {
    analogReadings[i] = analogRead(sensorPin);
    delay(1);
  }
  KickSort<short>::quickSort(analogReadings, Constants::SENSOR_SAMPLING);
  
  // Return median
  return analogReadings[Constants::SENSOR_SAMPLING / 2];
}

short readSensorInstant(short sensorPin) {
  short analogReadings[Constants::SENSOR_SAMPLING];
  for (short i = 0 ; i < Constants::SENSOR_SAMPLING ; i++) {
    analogReadings[i] = analogRead(sensorPin);
  }
  KickSort<short>::quickSort(analogReadings, Constants::SENSOR_SAMPLING);
  
  // Return median
  return analogReadings[Constants::SENSOR_SAMPLING / 2];
}

float getSensorDist(short sensorPin) {
  switch(sensorPin) {
    case Constants::SRFL_PIN:
      return getSRFLdist();
    case Constants::SRFC_PIN:
      return getSRFCdist();
    case Constants::SRFR_PIN:
      return getSRFRdist();
    case Constants::SRLH_PIN:
      return getSRLHdist();
    case Constants::SRLT_PIN:
      return getSRLTdist();
    case Constants::LRR_PIN:
      return getLRRdist();
    default:
      return 0;
  }
}

/************* SRFL - PS1 *************/
float getSRFLdist() {
//  short analogSignal = readSensor(Constants::SRFL_PIN);
//  return calculatePS1(analogSignal);
  short analogSignal = readSensor(Constants::SRFL_PIN);
  float volt = analogSignal * (5.0 / 1023.0);
  return calculateSRDistance(volt);
}

float getSRFLdistInstant() {
//  short analogSignal = readSensor(Constants::SRFL_PIN);
//  return calculatePS1(analogSignal);
  short analogSignal = readSensorInstant(Constants::SRFL_PIN);
  float volt = analogSignal * (5.0 / 1023.0);
  return calculateSRDistance(volt);
}

short getSRFLblockAway() {
  float distInCm = getSRFLdistInstant();
//  float distInCm = getSRFLdist();
//  Serial.print("SRFL distInCm: ");
//  Serial.println(distInCm);
  for (short i = 0 ; i < Constants::SR_UPPER_RANGE ; i++) {
    if (distInCm <= Constants::SRFL_MIN_DIST + i * Constants::BLOCK_SIZE + Constants::BLOCK_SIZE / 2)
      return i + 1;
  }
  if (distInCm <= Constants::SR_MAX_DIST)
    return Constants::SR_UPPER_RANGE;
  return -1; //No obstacle in the range
}

/************* SRFC - PS4 *************/
float getSRFCdist() {
  short analogSignal = readSensor(Constants::SRFC_PIN);
  float volt = analogSignal * (5.0 / 1023.0);
  return calculateSRDistance(volt);
}

float getSRFCdistInstant() {
  short analogSignal = readSensorInstant(Constants::SRFC_PIN);
  float volt = analogSignal * (5.0 / 1023.0);
  return calculateSRDistance(volt);
}

short getSRFCblockAway() {
  float distInCm = getSRFCdistInstant();
//  float distInCm = getSRFCdist();
//  Serial.print("SRFC distInCm: ");
//  Serial.println(distInCm);
  for (short i = 0 ; i < Constants::SR_UPPER_RANGE ; i++) {
    if (distInCm <= Constants::SRFC_MIN_DIST + i * Constants::BLOCK_SIZE + Constants::BLOCK_SIZE / 2)
      return i + 1;
  }
  if (distInCm <= Constants::SR_MAX_DIST)
    return Constants::SR_UPPER_RANGE;
  return -1; //No obstacle in the range
}

/************* SRFR - PS3 *************/
float getSRFRdist() {
//  short analogSignal = readSensor(Constants::SRFR_PIN);
//  return calculatePS3(analogSignal);
  short analogSignal = readSensor(Constants::SRFR_PIN);
  float volt = analogSignal * (5.0 / 1023.0);
  return calculateSRDistance(volt);
}

float getSRFRdistInstant() {
//  short analogSignal = readSensor(Constants::SRFR_PIN);
//  return calculatePS3(analogSignal);
  short analogSignal = readSensorInstant(Constants::SRFR_PIN);
  float volt = analogSignal * (5.0 / 1023.0);
  return calculateSRDistance(volt);
}

short getSRFRblockAway() {
  float distInCm = getSRFRdistInstant();
//  float distInCm = getSRFRdist();
//  Serial.print("SRFR distInCm: ");
//  Serial.println(distInCm);
  for (short i = 0 ; i < Constants::SR_UPPER_RANGE ; i++) {
    if (distInCm <= Constants::SRFR_MIN_DIST + i * Constants::BLOCK_SIZE + Constants::BLOCK_SIZE / 2)
      return i + 1;
  }
  if (distInCm <= Constants::SR_MAX_DIST)
    return Constants::SR_UPPER_RANGE;
  return -1; //No obstacle in the range
}

/************* SRLH - PS5 *************/
float getSRLHdist() {
//  short analogSignal = readSensor(Constants::SRLH_PIN);
//  return calculatePS5(analogSignal);
  short analogSignal = readSensor(Constants::SRLH_PIN);
  float volt = analogSignal * (5.0 / 1023.0);
  return calculateSRDistance(volt);
}

float getSRLHdistInstant() {
//  short analogSignal = readSensor(Constants::SRLH_PIN);
//  return calculatePS5(analogSignal);
  short analogSignal = readSensorInstant(Constants::SRLH_PIN);
  float volt = analogSignal * (5.0 / 1023.0);
  return calculateSRDistance(volt);
}

short getSRLHblockAway() {
  float distInCm = getSRLHdistInstant();
//  float distInCm = getSRLHdist();
//  Serial.print("SRLH distInCm: ");
//  Serial.println(distInCm);
  for (short i = 0 ; i < Constants::SR_UPPER_RANGE ; i++) {
    if (distInCm <= Constants::SRLH_MIN_DIST + i * Constants::BLOCK_SIZE + Constants::BLOCK_SIZE / 2)
      return i + 1;
  }
  if (distInCm <= Constants::SR_MAX_DIST)
    return Constants::SR_UPPER_RANGE;
  return -1; //No obstacle in the range
}

/************* SRLT - PS6 *************/
float getSRLTdist() {
  short analogSignal = readSensor(Constants::SRLT_PIN);
  float volt = analogSignal * (5.0 / 1023.0);
  return calculateSRDistance(volt);
}

float getSRLTdistInstant() {
  short analogSignal = readSensorInstant(Constants::SRLT_PIN);
  float volt = analogSignal * (5.0 / 1023.0);
  return calculateSRDistance(volt);
}

short getSRLTblockAway() {
  float distInCm = getSRLTdistInstant();
//  float distInCm = getSRLTdist();
//  Serial.print("SRLT distInCm: ");
//  Serial.println(distInCm);
  for (short i = 0 ; i < Constants::SR_UPPER_RANGE ; i++) {
    if (distInCm <= Constants::SRLT_MIN_DIST + i * Constants::BLOCK_SIZE + Constants::BLOCK_SIZE / 2)
      return i + 1;
  }
  if (distInCm <= Constants::SR_MAX_DIST)
    return Constants::SR_UPPER_RANGE;
  return -1; //No obstacle in the range
}

/************* LRR - PS2 *************/
float getLRRdist() {
//  short analogSignal = readSensor(Constants::LRR_PIN);
//  return calculatePS2(analogSignal);
  short analogSignal = readSensor(Constants::LRR_PIN);
  float volt = analogSignal * (5.0 / 1023.0);
  return calculateLRDistance(volt);
}

float getLRRdistInstant() {
//  short analogSignal = readSensor(Constants::LRR_PIN);
//  return calculatePS2(analogSignal);
  short analogSignal = readSensorInstant(Constants::LRR_PIN);
  float volt = analogSignal * (5.0 / 1023.0);
  return calculateLRDistance(volt);
}

short getLRRblockAway() {
  float distInCm = getLRRdistInstant();
//  float distInCm = getLRRdist();
//  Serial.print("LRR distInCm: ");
//  Serial.println(distInCm);
  for (short i = 0 ; i < Constants::LR_UPPER_RANGE ; i++) {
    if (distInCm <= Constants::LRR_MIN_DIST + i * Constants::BLOCK_SIZE + Constants::BLOCK_SIZE / 2)
      return i + 1;
  }
//  if (distInCm <= Constants::SR_MAX_DIST)
//    return SR_UPPER_RANGE
  return -1; //No obstacle in the range
}

// Short range PS1
float calculatePS1(short y){
  float a = 0.00015570056579094615;
  float b = -0.17094290182630983;
  float c = 57.00375888549351;

  return ((a*y*y)+(b*y)+(c));
}

// Long range PS2
float calculatePS2(short y){
  float a = 0.0000889095153238526;
  float b = -0.18380866864865125;
  float c = 86.30364960580333;

  return ((a*y*y)+(b*y)+(c));
}

// Short range PS3
float calculatePS3(short y){
  float a = 0.0003683757149475359;
  float b = -0.355489407475571;
  float c = 95.92101178385319;

  return ((a*y*y)+(b*y)+(c));
}

// Short range PS5
float calculatePS5(short y){
  float a = 0.00022032383579706093;
  float b = -0.23128743033250806;
  float c = 70.95046330026884;

  return ((a*y*y)+(b*y)+(c));
}

// Short range PS4 and PS6
float calculateSRDistance(float volt) {
  return 29.988 * pow(volt, -1.173);
}

float calculateLRDistance(float volt) {
  return 60.374 * pow(volt, -1.16);
}

/**
 * Return average front dist if exists at least an obstacle in range FRONT_MAX
 * Otherwise, return infinity
 */
float avgFrontDist() {
  float sum = 0;
  short cnt = 0;
  if (getSRFLdist() <= Constants::MAX_DIST_FOR_CALIBRATE) {
    sum += getSRFLdist();
    cnt++;
  }
  if (getSRFCdist() - (Constants::SRFL_MIN_DIST - Constants::SRFC_MIN_DIST) <= Constants::MAX_DIST_FOR_CALIBRATE) {
    sum += getSRFCdist() - (Constants::SRFL_MIN_DIST - Constants::SRFC_MIN_DIST);
    cnt++;
  }
  if (getSRFRdist() <= Constants::MAX_DIST_FOR_CALIBRATE) {
    sum += getSRFRdist();
    cnt++;
  }
  if (cnt == 0)
    return Constants::INF;
  return sum / cnt;
}

/**
 * Return average left dist if exists at least an obstacle in range FRONT_MAX
 * Otherwise, return infinity
 */
float avgLeftDist() {
  float sum = 0;
  short cnt = 0;
  if (getSRLHdist() <= Constants::MAX_DIST_FOR_CALIBRATE) {
    sum += getSRLHdist();
    cnt++;
  }
  if (getSRLTdist() <= Constants::MAX_DIST_FOR_CALIBRATE) {
    sum += getSRLTdist();
    cnt++;
  }
  if (cnt == 0)
    return Constants::INF;
  return sum / cnt;
}
