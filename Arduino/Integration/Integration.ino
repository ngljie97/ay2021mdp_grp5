#include "DualVNH5019MotorShield.h"
#include "EnableInterrupt.h"
#include <ArduinoQueue.h>
#include "Constants.h"


DualVNH5019MotorShield md;

//Motor 1
#define encoder1A 3
#define encoder1B 5

//Motor 2
#define encoder2A 11
#define encoder2B 13

#define SAMPLETIME 0.2 //in seconds how often is read

/*-----Ticks Variable-----*/
volatile long E1_ticks = 0;
volatile long E2_ticks = 0;

/*-----Check Ticks Variables-----*/
volatile long E1_ticks_moved = 0;
volatile long E2_ticks_moved = 0;

/*-----Motor Speed Variables-----*/
float M1_speed;
float M2_speed;

/**
 * Mode:
 * - FP: 0      (send action complete)
 * - EX & IF: 1 (send sensor data)
 */
short mode = 0;

/*-----Communication Variables-----*/
String receivedMsg  = "";
ArduinoQueue<String> q(Constants::QUEUE_MAX_SIZE);
String FORWARD_CMD = "F";
String FORWARD_OBSTACLE_AVOID_CMD = "FOA";
String TURN_LEFT_CMD = "L";
String TURN_RIGHT_CMD = "R";
String CALIBRATE_CMD = "C";
String RIGHT_CALIBRATE_CMD = "RC";
String INITIAL_CALIBRATE_CMD = "IC";
String FP_START_CMD = "FP_START";
String EX_START_CMD = "EX_START";
String IF_START_CMD = "IF_START";

// Send to Algo (P)
String SENSOR_DATA = "P|SENSOR_DATA";
String ACTION_COMPLETE = "P|ACTION_COMPLETE";
String SPLITTER = ":";

short delayTime = 100;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  md.init();
  
  pinMode(encoder1A, INPUT);
  pinMode(encoder1B, INPUT);
  pulseIn(encoder1A, HIGH);

  pinMode(encoder2A, INPUT);
  pinMode(encoder2B, INPUT);
  pulseIn(encoder2A, HIGH);

  enableInterrupt(encoder1A, E1_ticks_increment, RISING);
  enableInterrupt(encoder2A, E2_ticks_increment, RISING);
//  forwardPID(40, false);
//  forwardPID(40, false);
//  forwardPID(40, false);
//  rotateRightPID(90);
//  rotateLeftPID(90);
//  fullCalibrate();
//  frontAngleCalibrate();

/************* Test straight **************/
//forwardPID(40, false);
//delay(100);
//forwardPID(40, false);
//delay(200);
//rightPID();
//delay(100);
//rightPID();
//delay(100);
//forwardPID(40, false);
//delay(100);
//forwardPID(40, false);

  
}

void loop() {
  // put your main code here, to run repeatedly:  
  //delay(500);
  if (Serial.available() > 0) {
    char c = (char)Serial.read();
    if (c == '\n') {
      q.enqueue(receivedMsg);
      receivedMsg = "";
    } else {
      receivedMsg += c;
    }
  }
  if (!q.isEmpty()) {
    String cmd = q.dequeue();
//    Serial.print("P|cmd:");
//    Serial.println(cmd);
    executeCmd(cmd);
  }

 


  /************* Test right turn **************/
//  forwardPID(40, false);
//  delay(delayTime);
//  rightPID();
//  delay(delayTime);

  /************* Keep turning right **************/
//  rightPID();
//  delay(delayTime);

  /************* Test left turn **************/
//  forwardPID(40, false);
//  delay(delayTime);
//  leftPID();
//  delay(delayTime);

  /************* Keep turning left **************/
//  leftPID();
//  delay(delayTime);

//  forwardPID(40, false);
//  delay(delayTime);
//  rightPID();
//  delay(delayTime);
//  forwardPID(40, false);
//  delay(delayTime);
//  leftPID();
//  delay(delayTime);
//  forwardPID(40, false);
//  delay(delayTime);
//  leftPID();
//  delay(delayTime);
//  forwardPID(40, false);
//  delay(delayTime);
//  leftPID();
//  delay(delayTime);
//  forwardPID(40, false);
//  delay(delayTime);
//  leftPID();
//  delay(delayTime);
//  forwardPID(40, false);
//  delay(delayTime);
//  rightPID();
//  delay(delayTime);
//  forwardPID(40, false);
//  delay(delayTime);
//  rightPID();
//  delay(delayTime);
//  forwardPID(40, false);
//  delay(delayTime);
//  rightPID();
//  delay(delayTime);

//  forwardPID(10, false);
//  rightPID();
//  forwardPID(10, false);
//  leftPID();
//  forwardPID(10, false);
//  leftPID();`
//  forwardPID(10, false);
//  rightPID();

//  fullCalibrate();
//  leftPID();
//  delay(delayTime);
//  rightPID();
//  delay(delayTime);
}

void executeCmd(String cmd) {
  if (cmd.startsWith("FAC")) {
    frontAngleCalibrate();
    sendActionComplete();
  } else if (cmd.startsWith("FDC")) {
    frontDistanceCalibrate();
    sendActionComplete(); 
  } else if (cmd.startsWith("LAC")) {
    leftAngleCalibrate();
    sendActionComplete();
  } else if (cmd.startsWith(FP_START_CMD)) {
    mode = 0;
  } else if (cmd.startsWith(EX_START_CMD) || cmd.startsWith(IF_START_CMD)) {
    mode = 1;
    sendMsg();
  } else if (cmd.startsWith(FORWARD_OBSTACLE_AVOID_CMD)) {
    String temp = "";
    for (short i = 4 ; i < cmd.length() ; i++) {
      temp += cmd.charAt(i);
    }
    int dist = temp.toInt() * Constants::BLOCK_SIZE;
    bool obstacleAvoid = true;
    forwardPID(dist, obstacleAvoid);
    if (mode == 0)
      sendActionComplete();
  } else if (cmd.startsWith(FORWARD_CMD) && cmd.length() == 1) {
    autoForwardPID();
  } else if (cmd.startsWith(FORWARD_CMD) && cmd.length() > 1) {
    String temp = "";
    for (short i = 2 ; i < cmd.length() ; i++) {
      temp += cmd.charAt(i);
    }
    int dist = temp.toInt() * Constants::BLOCK_SIZE;
    bool obstacleAvoid = true;
    forwardPID(dist, obstacleAvoid);
    if (mode == 0)
      sendActionComplete();
  } else if (cmd.startsWith(RIGHT_CALIBRATE_CMD)) {
//    rightCalibrate();
    sendActionComplete();
  } else if (cmd.startsWith(INITIAL_CALIBRATE_CMD)) {
      initialCalibrate();
  } else if (cmd.startsWith(TURN_LEFT_CMD)) {
    if (mode == 1) {
      rightCalibrate();
      frontCalibrate();
      leftAngleCalibrate();
    }
//    rightCalibrate();
//    frontCalibrate();
    leftPID();
    sendMsg();
  } else if (cmd.startsWith(TURN_RIGHT_CMD)) {
    if (mode == 1) {
      leftDistanceCalibrate();
      frontCalibrate();
    }
//    leftDistanceCalibrate();
//    frontCalibrate();
//    fullCalibrate();
    rightPID();
//    if (mode == 1) {
//      leftAngleCalibrate();
//    }
    sendMsg();
  } else if (cmd.startsWith(CALIBRATE_CMD)) {
    fullCalibrate();
    sendActionComplete();
  }
}

void E1_ticks_increment()
{
//  Serial.println("in E1_ticks_increment");
  E1_ticks_moved++;
  E1_ticks++;
  //E1_ticks_moved++;
}

void E2_ticks_increment()
{
//  Serial.println("in E2_ticks_increment");
  E2_ticks_moved++;
  E2_ticks++;
  //E2_ticks_moved++;
}

/**
 * Send message to Algo
 * Mode 0 (FP): send ACTION_COMPLETE
 * Mode 1 (EX & IF): send SENSOR_DATA
 */
void sendMsg() {
  if (mode == 0) {
    Serial.println(ACTION_COMPLETE);
  } else {
    short SRFL = getSRFLblockAway();
    short SRFC = getSRFCblockAway();
    short SRFR = getSRFRblockAway();
    short SRLH = getSRLHblockAway();
    short SRLT = getSRLTblockAway();
    short LRR = getLRRblockAway();
    Serial.print(SENSOR_DATA); Serial.print(SPLITTER);
    Serial.print(SRFL); Serial.print(SPLITTER);
    Serial.print(SRFC); Serial.print(SPLITTER);
    Serial.print(SRFR); Serial.print(SPLITTER);
    Serial.print(SRLH); Serial.print(SPLITTER);
    Serial.print(SRLT); Serial.print(SPLITTER);
    Serial.println(LRR);
    
    Serial.print("getSRFLdist: ");
    Serial.println(getSRFLdist());
    Serial.print("getSRFCdist: ");
    Serial.println(getSRFCdist());
    Serial.print("getSRFRdist: ");
    Serial.println(getSRFRdist());
    Serial.print("getSRLHdist: ");
    Serial.println(getSRLHdist());
    Serial.print("getSRLTdist: ");
    Serial.println(getSRLTdist());
    Serial.print("getLRRdist: ");
    Serial.println(getLRRdist());
//    Serial.println(readSensor(Constants::LRR_PIN));
  }
}

void sendActionComplete() {
  Serial.println(ACTION_COMPLETE);
}
