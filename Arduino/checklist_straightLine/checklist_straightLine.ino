
#include "DualVNH5019MotorShield.h"
#include "EnableInterrupt.h"

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
const double SPEED = 300;
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


double lDistance = 0;
double rDistance = 0;
double distanceTravelled = 0;
double travel_degrees = 0;
double travel_distance = 0;
long travel_ticks = (long)(433);
long distance_to_travel = 150;
bool done = false;
double m_PI = 3.14159265;
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
  moveStraight(120);
}

void loop() {
  // put your main code here, to run repeatedly:
  moveLoop();
}

/*** MOVE **/
void moveInitialize(){
  
  ticks_reset();
  M1_speed = 300;
  M2_speed = 302.7;
  M2_PID_speed;
  KP = 0.4;
  KD = 0.01;
  KI = 0.001;
  done = false;
}
void moveStraight(int amount){
  moveInitialize();
  distance_to_travel = amount;
//  M1_speed = SPEED;
//  M2_speed = computeSpeedM2(SPEED);
  M1_speed = 350;
  M2_speed = 345;
  md.setSpeeds(M1_speed, M2_speed);
};

void moveLoop(){
  lDistance = 6 * m_PI * (E2_ticks_moved/562.25);
  rDistance = 6 * m_PI * (E1_ticks_moved/562.25);
  distanceTravelled = (lDistance + rDistance) /2;
  
  if (distanceTravelled >= distance_to_travel) {
//  if(front <= 15){
    md.setSpeeds(0, 0);
    md.setBrakes(400, 400);
     printSpeeds(M1_speed, M2_speed);
    Serial.print("E1_ticks moved: ");
    Serial.print(E1_ticks_moved);
    Serial.print("     E2_ticks moved: ");
    Serial.println(E2_ticks_moved);
    done = true;
  }
  if (!done) {
    Serial.print("E1_distance moved: ");
    Serial.print(rDistance);
    Serial.print("     E2_distance moved: ");
    Serial.println(lDistance);
    Serial.print("Distance moved: ");
    Serial.print(distanceTravelled);
    Serial.print("to move: ");
    Serial.println(distance_to_travel);
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
  printSpeeds(M1_speed, M2_speed);

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
  Serial.print("M1_speed: ");
  Serial.print(speed1);
  Serial.print("     M2_speed: ");
  Serial.println(speed2);
}
