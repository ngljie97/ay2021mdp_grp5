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
  return analogReadings[Constants::SENSOR_SAMPLING / 2]; 
//   return sum * 1.0 / Constants::SENSOR_SAMPLING;
}

float readSensorInstant(short sensorPin) {
  short analogReadings[Constants::SENSOR_SAMPLING];
  for (short i = 0 ; i < 30 ; i++) {
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
  float analogSignal = readSensor(Constants::SRFL_PIN);
  return calculatePS1(analogSignal);
//  short analogSignal = readSensor(Constants::SRFL_PIN);
//  float volt = analogSignal * (5.0 / 1023.0);
//  return calculateSRDistance(volt);
}

float getSRFLdistInstant() {
  float analogSignal = readSensorInstant(Constants::SRFL_PIN);
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
  float analogSignal = readSensor(Constants::SRFC_PIN);
  return calculatePS4(analogSignal);
//  short analogSignal = readSensor(Constants::SRFC_PIN);
//  float volt = analogSignal * (5.0 / 1023.0);
//  return calculateSRDistance(volt);
}

float getSRFCdistInstant() {
  float analogSignal = readSensorInstant(Constants::SRFC_PIN);
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
  float analogSignal = readSensor(Constants::SRFR_PIN);
  return calculatePS3(analogSignal);
//  short analogSignal = readSensor(Constants::SRFR_PIN);
//  float volt = analogSignal * (5.0 / 1023.0);
//  return calculateSRDistance(volt);
}

float getSRFRdistInstant() {
  float analogSignal = readSensorInstant(Constants::SRFR_PIN);
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
  float analogSignal = readSensor(Constants::SRLH_PIN);
//  Serial.print("analogSignal SRLH: ");analogSignal
//  Serial.println(analogSignal);
  return calculatePS5(analogSignal);
//  short analogSignal = readSensor(Constants::SRLH_PIN);
//  float volt = analogSignal * (5.0 / 1023.0);
//  return calculateSRDistance(volt);
}

float getSRLHdistInstant() {
  float analogSignal = readSensorInstant(Constants::SRLH_PIN);
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
  float analogSignal = readSensor(Constants::SRLT_PIN);
  return calculatePS6(analogSignal);
//  short analogSignal = readSensor(Constants::SRLT_PIN);
//  float volt = analogSignal * (5.0 / 1023.0);
//  return calculateSRDistance(volt);
}

float getSRLTdistInstant() {
  float analogSignal = readSensorInstant(Constants::SRLT_PIN);
  return calculatePS6(analogSignal);
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
  float analogSignal = readSensor(Constants::LRR_PIN);
  return calculatePS2(analogSignal);
//  short analogSignal = readSensor(Constants::LRR_PIN);
//  float volt = analogSignal * (5.0 / 1023.0);
//  return calculateLRDistance(volt);
}

float getLRRdistInstant() {
  float analogSignal = readSensorInstant(Constants::LRR_PIN);
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
  float a = 124.76620193872922;
  float b = -1.17003664758344;
  float c = 0.005208945657530123;
  float d = -0.000012232150925500758;
  float e = 1.4497940317281796e-8;
  float f = -6.827187197139883e-12;
  float distFromTip = 3.5;
  return ((f*y*y*y*y*y)+(e*y*y*y*y)+(d*y*y*y)+(c*y*y)+(b*y)+(a));
}

// Long range PS2
float calculatePS2(short y){
  float a = 164.21852538532852;
  float b = -0.6797873399998431;
  float c = -0.0001332245814380544;
  float d = 0.000006437952906946337;
  float e = -1.385845751308227e-8;
  float f = 8.964007284085486e-12;
  float distFromTip = 0;
  return ((f*y*y*y*y*y)+(e*y*y*y*y)+(d*y*y*y)+(c*y*y)+(b*y)+(a));
}

// Short range PS3
float calculatePS3(short y){
  float a = 116.9964068372686;
  float b = -0.9622367444094584;
  float c = 0.0038793978466204384;
  float d = -0.000008556310514830144;
  float e = 9.797890950228542e-9;
  float f = -4.544778362133421e-12;
  float distFromTip = 3.5;
//  return ((e*y*y*y*y)+(d*y*y*y)+(c*y*y)+(b*y)+(a)) - 0.39;
//  return ((e*y*y*y*y)+(d*y*y*y)+(c*y*y)+(b*y)+(a)) + 0.1;
  return ((f*y*y*y*y*y)+(e*y*y*y*y)+(d*y*y*y)+(c*y*y)+(b*y)+(a));
}

// Short range PS4
float calculatePS4(short y){
  float a = 117.14399734031277;
  float b = -0.9661548155974651;
  float c = 0.0038416731587994253;
  float d = -0.000008248029018073458;
  float e = 9.12309123440423e-9;
  float f = -4.076440507795106e-12;
  float distFromTip = 2.8;
  return ((f*y*y*y*y*y)+(e*y*y*y*y)+(d*y*y*y)+(c*y*y)+(b*y)+(a)) + 0.7;
}

// Short range PS5
float calculatePS5(short y){
  float a = 181.64137803366788;
  float b = -2.0326282547565193;
  float c = 0.01016993751141173;
  float d = -0.000025941192237791838;
  float e = 3.266190199630939e-8;
  float f = -1.6077974802143495e-11;
  float distFromTip = 1;
  return ((f*y*y*y*y*y)+(e*y*y*y*y)+(d*y*y*y)+(c*y*y)+(b*y)+(a));
}

// Short range PS6
float calculatePS6(short y){
  float a = 209.85098991548384;
  float b = -2.5135322721415925;
  float c = 0.013134002937813262;
  float d = -0.00003454033333407248;
  float e = 4.4567343634925413e-8;
  float f = -2.241725538698334e-11;
  float distFromTip = 0;
  return ((f*y*y*y*y*y)+(e*y*y*y*y)+(d*y*y*y)+(c*y*y)+(b*y)+(a)) + 0.1; //0.25
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
