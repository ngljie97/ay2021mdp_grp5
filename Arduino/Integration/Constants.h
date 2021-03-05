#ifndef CONSTANTS_H
#define CONSTANTS_H

class Constants
{
  public:
    /******* Sensor *******/
    static const short SRFL_PIN = 0; //PS1
    static const short SRFC_PIN = 3; //PS4
    static const short SRFR_PIN = 2; //PS3
    static const short SRLH_PIN = 4; //PS5
    static const short SRLT_PIN = 5; //PS6
    static const short LRR_PIN = 1;  //PS2

    static const short SENSOR_SAMPLING = 30;

    static constexpr float MIN_DIST = 6;

    static constexpr float BLOCK_SIZE = 10;
    static const short SR_UPPER_RANGE = 3;
    static const short LR_UPPER_RANGE = 5;
    static const short SR_MAX_DIST = 37; //Consider changing

    static constexpr float MAX_DIST_FOR_CALIBRATE = 10;
    static constexpr float STOP_DIST = 8;
    
    static constexpr float THRESHOLD = 0.15;

    static const short MAX_TRIAL = 5;

    /******* Motor *******/
    static const short SPEED = 500;
    static const short WHEEL_DIAMETER = 6;
    static constexpr float TPR = 562.25;   //Tick per revolution

    static constexpr float DELAY = 20;
    static constexpr float PID_DELAY = 0.05;
    static const long INF = (long)1e9;

    static const short QUEUE_MAX_SIZE = 10;

    static const short MAX_FORWARD = 5;
};

#endif
