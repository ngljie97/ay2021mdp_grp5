#include <SharpIR.h>

#include "DualVNH5019MotorShield.h"
DualVNH5019MotorShield md;
SharpIR sensor(A0,1080);
int val = 0;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  md.init();
}

void loop() {
  // put your main code here, to run repeatedly:
  val = analogRead(A0);
  Serial.println(val);
  printSensor();
}

float sensorDistance(){
  return sensor.distance();
  return sensor.median_Voltage_Sampling();
}

float sensorVoltage(){
  return sensor.median_Voltage_Sampling();
}

void printSensor(){
  Serial.print("Sensor: ");Serial.print(sensorDistance());
  //Serial.print("Sensor Voltage: ");Serial.println(sensorVoltage());
}
