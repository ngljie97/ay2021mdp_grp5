#include "Constants.h"


void PIDController(float KP, float KD, float KI, float travel_ticks, bool forward) {  
  /*-----PID Variables-----*/
  long ticks_diff_setpoint = 0;
  long ticks_diff_error = 0;
  long ticks_diff_prev_error = 0;
  long ticks_diff_sum_error = 0;

  E1_ticks = 0;
  E2_ticks = 0;
  E1_ticks_moved = 0;
  E2_ticks_moved = 0;

  long E1_ticks_tracked = 0;
  long E2_ticks_tracked = 0;
  long ticks_per_block = distToTick(Constants::BLOCK_SIZE);
  short blocks_moved = 0;
  short num_of_blocks = tickToBlock(travel_ticks);
  
  float avg_sticks_moved = computeAvgSticksMoved();
  while (avg_sticks_moved < travel_ticks) {
    // For auto forward: travel_ticks is INF
    if (travel_ticks == Constants::INF && (obstacleInFront() || noWallLeft())) {
      md.setBrakes(400, 400);
      break;
    }
    
    //ticks diff error
    ticks_diff_error = (E1_ticks - E2_ticks) - ticks_diff_setpoint;
  
    //Compute ticks from PID formula
    float M2_PID_speed = M2_speed + (ticks_diff_error * KP) + (ticks_diff_prev_error * KD) + (ticks_diff_sum_error * KI);

    M2_speed = M2_PID_speed;

//    printSpeeds(M1_speed, M2_speed);
    md.setSpeeds(M1_speed, M2_speed);

    E1_ticks_tracked += E1_ticks;
    E2_ticks_tracked += E2_ticks;

    // When moved a block, send sensor data and reset ticks tracked
    if (forward && (E1_ticks_tracked + E2_ticks_tracked) / 2.0 >= ticks_per_block) {
//      Serial.print("Dist: ");
//      Serial.println(tickToDist((E1_ticks_tracked + E2_ticks_tracked) / 2.0));
      E1_ticks_tracked = 0;
      E2_ticks_tracked = 0;
      blocks_moved++;
      if (mode == 1)
//        Serial.println("Send in while loop");
//        Serial.print("blocks_moved: ");
//        Serial.println(blocks_moved);
        sendMsg();  //Send sensor data
    }

    //Previous error
    ticks_diff_prev_error = ticks_diff_error;
  
    //Sum error
    ticks_diff_sum_error += ticks_diff_error;
  
    //Reset ticks
    E1_ticks = 0;
    E2_ticks = 0;

    delay(Constants::PID_DELAY);

    avg_sticks_moved = computeAvgSticksMoved();
  }
  md.setSpeeds(0, 0);
  md.setBrakes(400, 400);
  delay(80);
//  Serial.print("blocks_moved: ");
//  Serial.println(blocks_moved);
  if (forward && blocks_moved < num_of_blocks && mode == 1) {
//    Serial.print("Dist: ");
//    Serial.println(tickToDist((E1_ticks_tracked + E2_ticks_tracked) / 2.0));
//    Serial.print("Send outside");
    sendMsg();  //Send sensor data of the last block
  }
}

float computeAvgSticksMoved() {
  return (E1_ticks_moved + E2_ticks_moved) / 2.0;
}

void forwardPID(float dist) {
  float travel_ticks = distToTick(dist);
  float KP = 0.4;
  float KD = 0.01;
  float KI = 0.001;

  M1_speed = Constants::SPEED;
  M2_speed = Constants::SPEED;
  md.setSpeeds(M1_speed, M2_speed);
  
  PIDController(KP, KD, KI, travel_ticks, true);
}

void autoForwardPID() {
  float KP = 0.4;
  float KD = 0.01;
  float KI = 0.005;

  M1_speed = Constants::SPEED;
  M2_speed = Constants::SPEED;
  md.setSpeeds(M1_speed, M2_speed);
  
  PIDController(KP, KD, KI, Constants::INF, true);
}

void rotatePID(float degree) {
  if (degree == 0)
    return;
  short offset = 0;
  if (degree == -90)
    offset = -2;
  float dist = degreeToDist(abs(degree - offset));
  float travel_ticks = distToTick(dist);
  float KP = 0.4;
  float KD = 0.03;
  float KI = 0.01;

  short M1_mul, M2_mul;
  if (degree > 0) {  // Rotate right
    M1_mul = -1;
    M2_mul = 1;
  } else {           // Rotate left
    M1_mul = 1;
    M2_mul = -1;
  }
    
//  M1_speed = M1_mul * Constants::SPEED;
//  M2_speed = M2_mul * computeSpeedM2(Constants::SPEED);
  M1_speed = M1_mul * Constants::SPEED;
  M2_speed = M2_mul * Constants::SPEED;
  md.setSpeeds(M1_speed, M2_speed);

  PIDController(KP, KD, KI, travel_ticks, false);
}

void rotateRightPID(float degree) {
  rotatePID(degree);
}

void rotateLeftPID(float degree) {
  rotatePID(-1 * degree);
}

/**
 * Should stop when obstacle in front or no wall on left side
 */
bool obstacleInFront() {
//  Serial.print("getSRFLdist: ");
//  Serial.println(getSRFLdist());
//  Serial.print("getSRFCdist: ");
//  Serial.println(getSRFCdist());
//  Serial.print("getSRFRdist: ");
//  Serial.println(getSRFRdist());
  if (getSRFLdist() <= Constants::STOP_DIST || getSRFRdist() <= Constants::STOP_DIST)
    return true;
  return false;
}

/**
 * No wall on the left to hug
 */
bool noWallLeft() {
  if (avgLeftDist() == Constants::INF)
    return true;
  return false;
}

void printSpeeds(double speed1, double speed2) {
  Serial.print("M1_speed: ");
  Serial.print(speed1);
  Serial.print("     M2_speed: ");
  Serial.println(speed2);
}
