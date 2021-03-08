#include "Constants.h"
#include "KickSort.h"

float readSensor(short sensorPin) {
  short analogReadings[Constants::SENSOR_SAMPLING];
  float sum = 0;
  for (short i = 0 ; i < Constants::SENSOR_SAMPLING ; i++) {
    analogReadings[i] = analogRead(sensorPin);
    sum += analogReadings[i];
    delay(1);
  }
  KickSort<short>::quickSort(analogReadings, Constants::SENSOR_SAMPLING);
  
  // Return median
//  return analogReadings[Constants::SENSOR_SAMPLING / 2]; 
   return sum * 1.0 / Constants::SENSOR_SAMPLING;
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
  short analogSignal = readSensor(Constants::SRFL_PIN);
  return calculatePS1(analogSignal);
//  short analogSignal = readSensor(Constants::SRFL_PIN);
//  float volt = analogSignal * (5.0 / 1023.0);
//  return calculateSRDistance(volt);
}

float getSRFLdistInstant() {
  short analogSignal = readSensorInstant(Constants::SRFL_PIN);
  return calculatePS1(analogSignal);
//  short analogSignal = readSensorInstant(Constants::SRFL_PIN);
//  float volt = analogSignal * (5.0 / 1023.0);
//  return calculateSRDistance(volt);
}

short getSRFLblockAway() {
  float distInCm = getSRFLdistInstant();
//  float distInCm = getSRFLdist();
//  Serial.print("SRFL distInCm: ");
//  Serial.println(distInCm);
  for (short i = 0 ; i < Constants::SR_UPPER_RANGE ; i++) {
    if (distInCm <= Constants::MIN_DIST + i * Constants::BLOCK_SIZE + Constants::BLOCK_SIZE / 2)
      return i + 1;
  }
//  if (distInCm <= Constants::SR_MAX_DIST)
//    return Constants::SR_UPPER_RANGE;
  return -1; //No obstacle in the range
}

/************* SRFC - PS4 *************/
float getSRFCdist() {
  short analogSignal = readSensor(Constants::SRFC_PIN);
  return calculatePS4(analogSignal);
//  short analogSignal = readSensor(Constants::SRFC_PIN);
//  float volt = analogSignal * (5.0 / 1023.0);
//  return calculateSRDistance(volt);
}

float getSRFCdistInstant() {
  short analogSignal = readSensorInstant(Constants::SRFC_PIN);
  return calculatePS4(analogSignal);
//  short analogSignal = readSensorInstant(Constants::SRFC_PIN);
//  float volt = analogSignal * (5.0 / 1023.0);
//  return calculateSRDistance(volt);
}

short getSRFCblockAway() {
  float distInCm = getSRFCdistInstant();
//  float distInCm = getSRFCdist();
//  Serial.print("SRFC distInCm: ");
//  Serial.println(distInCm);
  for (short i = 0 ; i < Constants::SR_UPPER_RANGE ; i++) {
    if (distInCm <= Constants::MIN_DIST + i * Constants::BLOCK_SIZE + Constants::BLOCK_SIZE / 2)
      return i + 1;
  }
//  if (distInCm <= Constants::SR_MAX_DIST)
//    return Constants::SR_UPPER_RANGE;
  return -1; //No obstacle in the range
}

/************* SRFR - PS3 *************/
float getSRFRdist() {
  short analogSignal = readSensor(Constants::SRFR_PIN);
  return calculatePS3(analogSignal);
//  short analogSignal = readSensor(Constants::SRFR_PIN);
//  float volt = analogSignal * (5.0 / 1023.0);
//  return calculateSRDistance(volt);
}

float getSRFRdistInstant() {
  short analogSignal = readSensorInstant(Constants::SRFR_PIN);
  return calculatePS3(analogSignal);
//  short analogSignal = readSensorInstant(Constants::SRFR_PIN);
//  float volt = analogSignal * (5.0 / 1023.0);
//  return calculateSRDistance(volt);
}

short getSRFRblockAway() {
  float distInCm = getSRFRdistInstant();
//  float distInCm = getSRFRdist();
//  Serial.print("SRFR distInCm: ");
//  Serial.println(distInCm);
  for (short i = 0 ; i < Constants::SR_UPPER_RANGE ; i++) {
    if (distInCm <= Constants::MIN_DIST + i * Constants::BLOCK_SIZE + Constants::BLOCK_SIZE / 2)
      return i + 1;
  }
//  if (distInCm <= Constants::SR_MAX_DIST)
//    return Constants::SR_UPPER_RANGE;
  return -1; //No obstacle in the range
}

/************* SRLH - PS5 *************/
float getSRLHdist() {
  short analogSignal = readSensor(Constants::SRLH_PIN);
  return calculatePS5(analogSignal);
//  short analogSignal = readSensor(Constants::SRLH_PIN);
//  float volt = analogSignal * (5.0 / 1023.0);
//  return calculateSRDistance(volt);
}

float getSRLHdistInstant() {
  short analogSignal = readSensorInstant(Constants::SRLH_PIN);
  return calculatePS5(analogSignal);
//  short analogSignal = readSensorInstant(Constants::SRLH_PIN);
//  float volt = analogSignal * (5.0 / 1023.0);
//  return calculateSRDistance(volt);
}

short getSRLHblockAway() {
  float distInCm = getSRLHdistInstant();
//  float distInCm = getSRLHdist();
//  Serial.print("SRLH distInCm: ");
//  Serial.println(distInCm);
  for (short i = 0 ; i < Constants::SR_UPPER_RANGE ; i++) {
    if (distInCm <= Constants::MIN_DIST + i * Constants::BLOCK_SIZE + Constants::BLOCK_SIZE / 2)
      return i + 1;
  }
//  if (distInCm <= Constants::SR_MAX_DIST)
//    return Constants::SR_UPPER_RANGE;
  return -1; //No obstacle in the range
}

/************* SRLT - PS6 *************/
float getSRLTdist() {
  short analogSignal = readSensor(Constants::SRLT_PIN);
  return calculatePS5(analogSignal);
//  short analogSignal = readSensor(Constants::SRLT_PIN);
//  float volt = analogSignal * (5.0 / 1023.0);
//  return calculateSRDistance(volt);
}

float getSRLTdistInstant() {
  short analogSignal = readSensorInstant(Constants::SRLT_PIN);
  return calculatePS5(analogSignal);
//  short analogSignal = readSensorInstant(Constants::SRLT_PIN);
//  float volt = analogSignal * (5.0 / 1023.0);
//  return calculateSRDistance(volt);
}

short getSRLTblockAway() {
  float distInCm = getSRLTdistInstant();
//  float distInCm = getSRLTdist();
//  Serial.print("SRLT distInCm: ");
//  Serial.println(distInCm);
  for (short i = 0 ; i < Constants::SR_UPPER_RANGE ; i++) {
    if (distInCm <= Constants::MIN_DIST + i * Constants::BLOCK_SIZE + Constants::BLOCK_SIZE / 2)
      return i + 1;
  }
//  if (distInCm <= Constants::SR_MAX_DIST)
//    return Constants::SR_UPPER_RANGE;
  return -1; //No obstacle in the range
}

/************* LRR - PS2 *************/
float getLRRdist() {
  short analogSignal = readSensor(Constants::LRR_PIN);
  return calculatePS2(analogSignal);
//  short analogSignal = readSensor(Constants::LRR_PIN);
//  float volt = analogSignal * (5.0 / 1023.0);
//  return calculateLRDistance(volt);
}

float getLRRdistInstant() {
  short analogSignal = readSensorInstant(Constants::LRR_PIN);
  return calculatePS2(analogSignal);
//  short analogSignal = readSensorInstant(Constants::LRR_PIN);
//  float volt = analogSignal * (5.0 / 1023.0);
//  return calculateLRDistance(volt);
}

short getLRRblockAway() {
  float distInCm = getLRRdistInstant();
//  float distInCm = getLRRdist();
//  Serial.print("LRR distInCm: ");
//  Serial.println(distInCm);
  for (short i = 0 ; i < Constants::LR_UPPER_RANGE ; i++) {
    if (distInCm <= Constants::MIN_DIST + i * Constants::BLOCK_SIZE + Constants::BLOCK_SIZE / 2)
      return i + 1;
  }
  return -1; //No obstacle in the range
}

// Short range PS1
float calculatePS1(short y){
  float a = 104.95390732865984;
  float b = -0.7628434838429381;
  float c = 0.0024951951507336785;
  float d = -0.000003833539767108626;
  float e = 2.220941122720654e-9;
  float distFromTip = 3.5;
  return ((e*y*y*y*y)+(d*y*y*y)+(c*y*y)+(b*y)+(a));
}

// Long range PS2
float calculatePS2(short y){
  float a = 180.23964327874648 - 1;
  float b = -1.1830011646189995;
  float c = 0.0036512408771051776;
  float d = -0.000005423756552094324;
  float e = 3.003927201398369e-9;
  float distFromTip = 0;
  return ((e*y*y*y*y)+(d*y*y*y)+(c*y*y)+(b*y)+(a));
}

// Short range PS3
float calculatePS3(short y){
  float a = 77.17969059497881;
  float b = -0.40813818271924773;
  float c = 0.0009199097711358715;
  float d = -9.232483512802136e-7;
  float e = 3.1403547504425725e-10;
  float distFromTip = 3.5;
//  return ((e*y*y*y*y)+(d*y*y*y)+(c*y*y)+(b*y)+(a)) - 0.39;
//  return ((e*y*y*y*y)+(d*y*y*y)+(c*y*y)+(b*y)+(a)) + 0.1;
  return ((e*y*y*y*y)+(d*y*y*y)+(c*y*y)+(b*y)+(a)) - 0.1;
}

// Short range PS4
float calculatePS4(short y){
  float a = 58.055716132069826;
  float b = -0.2385246865019394;
  float c = 0.00038508683536618126;
  float d = -2.067876969195102e-7;
  float e = -2.480214809028296e-11;
  float distFromTip = 2.8;
  return ((e*y*y*y*y)+(d*y*y*y)+(c*y*y)+(b*y)+(a)) - 0.35;
}

// Short range PS5
float calculatePS5(short y){
  float a = 106.66951260105641;
  float b = -0.6862081004105913;
  float c = 0.0019619775363461404;
  float d = -0.0000025911873441724526;
  float e = 1.277960719392304e-9;
  float distFromTip = 1;
  return ((e*y*y*y*y)+(d*y*y*y)+(c*y*y)+(b*y)+(a));
}

// Short range PS6
float calculatePS6(short y){
  float a = 109.36338485581553;
  float b = -0.727957651160299;
  float c = 0.00214883616098274;
  float d = -0.0000029237996346267947;
  float e = 1.482334995624426e-9;
  float distFromTip = 0;
  return ((e*y*y*y*y)+(d*y*y*y)+(c*y*y)+(b*y)+(a)) - 0.3;
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
  if (getSRFCdist() <= Constants::MAX_DIST_FOR_CALIBRATE) {
    sum += getSRFCdist();
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
