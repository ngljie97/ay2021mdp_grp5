
#include "DualVNH5019MotorShield.h"
#include "EnableInterrupt.h"

double a0,a1,a2,a3,a4,a5 = 0;
double avg0,avg1,avg2,avg3,avg4,avg5 = 0;
double front = 100;
double totalMoved = 0;
double totalToMove = 90;
int sensorCount = 0;
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
double E1_ticks_moved = 0;
double E2_ticks_moved = 0;

/*-----Motor Speed Variables-----*/
const double SPEED = 200;
double M1_speed;
double M2_speed;
double M2_PID_speed;

/*-----PID Variables-----*/
long ticks_diff_setpoint = 0;
long ticks_diff_error = 0;
long ticks_diff_prev_error = 0;
long ticks_diff_sum_error = 0;
double KP = 0;
double KD = 0;
double KI = 0;

int phase = 0;
bool phaseDone = false;
double lDistance = 0;
double rDistance = 0;
double distanceTravelled = 0;
double travel_degrees = 0;
double travel_distance = 0;

long travel_ticks = (long)(433);
long distance_to_travel = 50;
bool done = false;
double m_PI = 3.14159265;
bool obstacleFound = false;
void setup() {
  // put your setup code here, to run once:
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
  moveToObstacle();

}

void loop() {
  delay(20);
  // put your main code here, to run repeatedly:
    sensorCount++;
  a0 += analogRead(A0);
  a1 += analogRead(A1);
  a2 += analogRead(A2);
  a3 += analogRead(A3);
  a4 += analogRead(A4);
  a5 += analogRead(A5);
  
  if(sensorCount%10 == 0){
    avg0 = CalculateA0(a0/sensorCount);
    avg1 = CalculateA1(a1/sensorCount);
    avg2 = CalculateA2(a2/sensorCount);
    avg4 = CalculateA4(a4/sensorCount);
    front = ((CalculateA2(a2/sensorCount)+CalculateA0(a0/sensorCount))/2);
    sensorCount = 0;
    a0=a1=a2=a3=a4=a5=0;
  }

  //move until near obstacle
  if(!obstacleFound){
    Serial.println("Looking for obstacle");
    Serial.print("Front: ");
    Serial.println(front);
    moveToObstacleLoop();
  }

  if(phaseDone){
    
    switch(phase){
      //turn 45 degrees 
      case 1:
    Serial.println("Phase 1 turning");
      turn(90);
      phaseDone = false;
      break;
      case 2:
    Serial.println("Phase 2 moving");
      moveStraight(25);
      phaseDone = false;
      break;
      case 3:
      turn(275);
    Serial.println("Phase 3 turning");
      phaseDone = false;
      break;
      case 4:
      moveStraight(40);
    Serial.println("Phase 4 moving");
      phaseDone = false;
      break;
      case 5:
      turn(275);
    Serial.println("Phase 5 turning");
      phaseDone = false;
      break;
      case 6:
      moveStraight(25);
    Serial.println("Phase 6 moving");
      phaseDone = false;
      break;
      case 7:
      turn(90);
    Serial.println("Phase 7 turning");
      phaseDone = false;
      break;
      case 8:
      moveStraight(100-totalMoved);
    Serial.println("Phase 8 moving");
      phaseDone = false;
      break;
    }
  }
  else{
    switch(phase){
      case 1:
      turnLoop();
      break;
      case 2:
      moveLoop();
      break;
      case 3:
      turnLoop();
      break;
      case 4:
      moveLoop();
      break;
      case 5:
      turnLoop();
      break;
      case 6:
      moveLoop();
      break;
      case 7:
      turnLoop();
      break;
      case 8:
      moveLoop();
      break;
    }
  }
  
}
void moveInitialize(){
  ticks_reset();
  M1_speed = 100;
  M2_speed = 102.7;
  M2_PID_speed;
  KP = 0.4;
  KD = 0.01;
  KI = 0.005;
  done = false;
}
void moveToObstacle(){
  moveInitialize();
  M1_speed = SPEED;
  M2_speed = computeSpeedM2(SPEED);
  md.setSpeeds(M1_speed, M2_speed);
}
void moveStraight(int amount){
  moveInitialize();
  distance_to_travel = amount;
  M1_speed = SPEED;
  M2_speed = computeSpeedM2(SPEED);
  md.setSpeeds(M1_speed, M2_speed);
};

void moveToObstacleLoop(){
  lDistance = 6 * m_PI * (E2_ticks_moved/562.25);
  rDistance = 6 * m_PI * (E1_ticks_moved/562.25);
  distanceTravelled = (lDistance + rDistance) /2;
  Serial.print("FRONT DISTANCE");
  Serial.println(front);
  if(totalMoved+distanceTravelled >= totalToMove){
    md.setSpeeds(0, 0);
    md.setBrakes(400, 400);
    done = true;
    phase = 9;
    phaseDone = true;
  }
  else if (front <= 20 && !obstacleFound) {
    md.setSpeeds(0, 0);
    md.setBrakes(400, 400);
     printSpeeds(M1_speed, M2_speed);
     Serial.println("OBSTACLE FOUND");
    done = true;
    obstacleFound = true;
    phaseDone = true;
    phase = 1;
    totalMoved += distanceTravelled;
  }
  if (!done) {
    movePIDController();
    delay(0.005); //get called every 1 seconds
  }
};

void moveLoop(){
  lDistance = 6 * m_PI * (E2_ticks_moved/562.25);
  rDistance = 6 * m_PI * (E1_ticks_moved/562.25);
  distanceTravelled = (lDistance + rDistance) /2;
 
  if (distanceTravelled >= distance_to_travel) {
    md.setSpeeds(0, 0);
    md.setBrakes(400, 400);
     printSpeeds(M1_speed, M2_speed);
    done = true;
    phase++;
    phaseDone = true;
  }
  if (!done) {
    movePIDController();
    delay(0.005); //get called every 1 seconds
  }
};

void movePIDController() {
  //ticks diff error
  ticks_diff_error = (E1_ticks - E2_ticks) - ticks_diff_setpoint;

  //Compute ticks from PID formula
  M2_PID_speed = M2_speed + (ticks_diff_error * KP) + (ticks_diff_prev_error * KD) + (ticks_diff_sum_error * KI);
  
  //convert adjusted ticks to RPM
  M2_speed = M2_PID_speed;

  md.setSpeeds(M1_speed, M2_speed);
  //printSpeeds(M1_speed, M2_speed);

  E1_ticks_moved += E1_ticks;
  E2_ticks_moved += E2_ticks;

  //Previous error
  ticks_diff_prev_error = ticks_diff_error;

  //Sum error
  ticks_diff_sum_error += ticks_diff_error;

  //Reset ticks
  E1_ticks = 0;
  E2_ticks = 0;
}
/** MOVE END**/
/** TURN **/

void turnInitialize(){
  
  KP = 0.4;
  KD = 0.03;
  KI = 0.01;
  ticks_reset();
  M1_speed = SPEED;
  M2_speed = computeSpeedM2(SPEED)*0.93;
  md.setSpeeds(M1_speed, M2_speed*-1);
  done = false;
}

void turn(int amount){
  travel_degrees = amount;
  turnInitialize();
  
  travel_distance = ((17*m_PI)/360)*travel_degrees;
}

void turnLoop(){
  lDistance = 6 * m_PI * (E2_ticks_moved/562.25);
  rDistance = 6 * m_PI * (E1_ticks_moved/562.25);
  distanceTravelled = (lDistance + rDistance) /2;
   if (distanceTravelled >= travel_distance*(1+(travel_degrees/20500))) {
    md.setSpeeds(0, 0);
    md.setBrakes(400, 400);
    done = true;
    Serial.println("Turn Done");
    Serial.print("Turn distance: ");
    Serial.println(travel_distance);
    Serial.print("Moved: ");
    Serial.print(distanceTravelled);
    phase++;
    phaseDone = true;
  }
  if(!done){
    turnPIDController();
    delay(0.005); //get called every 1 seconds
  }
}

void turnPIDController(){
    //ticks diff error
  ticks_diff_error = (E1_ticks - E2_ticks) - ticks_diff_setpoint;

  //Compute ticks from PID formula
  M2_PID_speed = (M2_speed) + (ticks_diff_error * KP) + (ticks_diff_prev_error * KD) + (ticks_diff_sum_error * KI);
  
  //convert adjusted ticks to RPM
  M2_speed = M2_PID_speed;

  md.setSpeeds(M1_speed, M2_speed*-1);
  printSpeeds(M1_speed, M2_speed*-1);

  E1_ticks_moved += E1_ticks;
  E2_ticks_moved += E2_ticks;

  //Previous error
  ticks_diff_prev_error = ticks_diff_error;

  //Sum error
  ticks_diff_sum_error += ticks_diff_error;

  //Reset ticks
  E1_ticks = 0;
  E2_ticks = 0;
}
/** TURN END **/
void ticks_reset(){
  E1_ticks = 0;
  E2_ticks = 0;
  E1_ticks_moved = 0;
  E2_ticks_moved = 0;
  
  
  ticks_diff_setpoint = 0;
  ticks_diff_error = 0;
  ticks_diff_prev_error = 0;
  ticks_diff_sum_error = 0;

  distanceTravelled = 0;
}
void E1_ticks_increment()
{
  E1_ticks++;
}

void E2_ticks_increment()
{
  E2_ticks++;
}

double RPMtoSpeedM1(double rpm1){
  return 2.4906*rpm1 + 7.143;
}

double RPMtoSpeedM2(double rpm2){
  return 2.4739*rpm2 + 10.883;
}

double ticksToRPM(long tick) {
  return (tick * 1.0 / 562.25) / SAMPLETIME * 60;
}

long RPMtoTicks(double rpm) {
  return (long)(rpm * 562.25 * SAMPLETIME / 60);
}

double roundTo1DecimalPlace(float var) 
{ 
    double value = (int)(var * 10 + .5); 
    return (double)value / 10; 
} 


double computeSpeedM2(double speedM1) {
  double res = (speedM1 - 7.143) / 2.4906 * 2.4739 + 10.883;
  return roundTo1DecimalPlace(res);
}
double readDouble() {
  String str = Serial.readString();
  return str.toDouble();
}

void printSpeeds(double speed1, double speed2) {
//  Serial.print("M1_speed: ");
//  Serial.print(speed1);
//  Serial.print("     M2_speed: ");
//  Serial.println(speed2);
}

float CalculateA4(float y){
  float a = 0.00022032383579706093;
  float b = -0.23128743033250806;
  float c = 70.95046330026884;

  return ((a*y*y)+(b*y)+(c));
}
float CalculateA1(float y){
  float a = 0.0000889095153238526;
  float b = -0.18380866864865125;
  float c = 86.30364960580333;

  return ((a*y*y)+(b*y)+(c));
}
float CalculateA0(float y){
  float a = 0.00015570056579094615;
  float b = -0.17094290182630983;
  float c = 57.00375888549351;

  return ((a*y*y)+(b*y)+(c));
}
float CalculateA2(float y){
  float a = 0.0003683757149475359;
  float b = -0.355489407475571;
  float c = 95.92101178385319;

  return ((a*y*y)+(b*y)+(c));
}
