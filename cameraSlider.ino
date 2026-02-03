

/*
  DIY Camera Slider with Pan and Tilt Head
  by Dejan Nedelkovski
  www.HowToMechatronics.com

  Library - AccelStepper by Mike McCauley:
  http://www.airspayce.com/mikem/arduino/AccelStepper/index.html

*/
/*Remove Joystick and replace with serial command input*/

#include <AccelStepper.h>
#include <MultiStepper.h>
#include <string.h>
#include <stdio.h>

//#define JoyX A0       // Joystick X pin
//#define JoyY A1       // Joystick Y pin 
//#define slider A2     // Slider potentiometer
//#define inOutPot A3   // In and Out speed potentiometer
//#define JoySwitch 10  // Joystick switch connected

// Define stepper pins
#define STEP_PIN_X 3      // Step pin
#define DIR_PIN_X 2       // Direction pin
#define STEP_PIN_Y 5      // Step pin
#define DIR_PIN_Y 4       // Direction pin
#define STEP_PIN_Z 11      // Step pin
#define DIR_PIN_Z 10      // Direction pin
// Microstepping control pins
#define MS1_PIN_X 7
#define MS2_PIN_X 6
#define MS1_PIN_Y 9
#define MS2_PIN_Y 8 
#define MS1_PIN_Z 13
#define MS2_PIN_Z 12
//Limit Switch Pins
#define LIMIT_PIN_L 22
//#define LIMIT_PIN_R 23

// Define the stepper motors and the pins the will use
AccelStepper stepper1(AccelStepper::DRIVER, STEP_PIN_X, DIR_PIN_X);
AccelStepper stepper2(AccelStepper::DRIVER, STEP_PIN_Y, DIR_PIN_Y);
AccelStepper stepper3(AccelStepper::DRIVER, STEP_PIN_Z, DIR_PIN_Z);

MultiStepper StepperControl;  // Create instance of MultiStepper
long gotoposition[3]; // An array to store the In or Out position for each stepper motor
//int JoyXPos = 0;
//int JoyYPos = 0;
//int sliderPos = 0;
int currentSpeed = 100;
int inOutSpeed = 100;
long XInPoint = 0;
long YInPoint = 0;
long ZInPoint = 0;
long XOutPoint = 0;
long YOutPoint = 0;
long ZOutPoint = 0;
int InandOut = 0;
bool reset=false;
//bool looping= false;
bool InOutSet = false; //bool that determines when the start and end positons are set. APP sends an S char to set state machine to state 1 and state 2 if sent again.
const int BUFFER_SIZE=16;
int input_size=0;
char* input_buffer=(char*)malloc(BUFFER_SIZE);
int x_buffer;
int y_buffer;
int z_buffer;
int v_buffer=100;
char state='N';
long prev_posx;
long prev_posy;
long prev_posz;

void setup() {
  // Establish serial Port
  Serial.begin(9600);Serial.setTimeout(1);
  // Set initial seed values for the steppers
  pinMode(MS1_PIN_X, OUTPUT);
  pinMode(MS2_PIN_X, OUTPUT);

  pinMode(MS1_PIN_Y, OUTPUT);
  pinMode(MS2_PIN_Y, OUTPUT);

  pinMode(MS1_PIN_Z, OUTPUT);
  pinMode(MS2_PIN_Z, OUTPUT);

  pinMode(LIMIT_PIN_L,INPUT_PULLUP);
 // pinMode(LIMIT_PIN_R,INPUT_PULLUP);
 
  // Set microstepping mode (adjust as needed: HIGH or LOW)
  digitalWrite(MS1_PIN_X, HIGH);  // Set to LOW or HIGH for desired microstep setting
  digitalWrite(MS2_PIN_X, LOW);  // Set to LOW or HIGH for desired microstep setting

  digitalWrite(MS1_PIN_Y, HIGH);  // Set to LOW or HIGH for desired microstep setting
  digitalWrite(MS2_PIN_Y, LOW);  // Set to LOW or HIGH for desired microstep setting

  digitalWrite(MS1_PIN_Z, HIGH);  // Set to LOW or HIGH for desired microstep setting
  digitalWrite(MS2_PIN_Z, LOW);  // Set to LOW or HIGH for desired microstep setting
 
  stepper1.setMaxSpeed(3000);
  stepper1.setSpeed(200);
  stepper2.setMaxSpeed(3000);
  stepper2.setSpeed(200);
  stepper3.setMaxSpeed(3000);
  stepper3.setSpeed(200);

  // Create instances for MultiStepper - Adding the 3 steppers to the StepperControl instance for multi control
  StepperControl.addStepper(stepper1);
  StepperControl.addStepper(stepper2);
  StepperControl.addStepper(stepper3);

  // Move the slider to the initial position - homing
  while (digitalRead(LIMIT_PIN_L) != 0) {
    stepper1.setSpeed(2000);
    stepper1.runSpeed();
    stepper1.setCurrentPosition(0); // When limit switch pressed set position to 0 steps
  }
  delay(20);
  // Move 200 steps back from the limit switch
  while (stepper1.currentPosition() != -200) {
    stepper1.setSpeed(-2000);
    stepper1.run();
    
  }
  //Serial.println("setup complete");

}

void loop() {
  // Limiting the movement - Do nothing if limit switch pressed or distance traveled in other direction greater then 80cm alter based on our length if needed
  while (digitalRead(LIMIT_PIN_L) == 0 || stepper1.currentPosition() < -64800) {}
  /* Speed Control Logic*/
 //Read serial port
  readSerial();
  // If Set button is pressed - toggle between the switch cases
  if (InOutSet) {
    //Serial.println("set pressed");
    delay(500);
    if (reset) {
      InandOut = 4;
      //Serial.println("reset");
    }
    switch (InandOut) { 
      case 0:   // Set IN position
        InandOut = 1;
        XInPoint = stepper1.currentPosition(); // Set the IN position for steppers 1
        YInPoint = stepper2.currentPosition(); // Set the IN position for steppers 2
        ZInPoint = stepper3.currentPosition(); // Set the IN position for steppers 3
        InOutSet=false;
        //Serial.println("set in");
        break;

      case 1: // Set OUT position
        InandOut = 2;
        XOutPoint = stepper1.currentPosition(); //  Set the OUT Points for both steppers
        YOutPoint = stepper2.currentPosition();
        ZOutPoint = stepper3.currentPosition();
        InOutSet=false;
        //Serial.println("set out");
        break;

      case 2: // Move to IN position / go to case 3
        //Serial.println("move to in");
        InOutSet=false;
        
        inOutSpeed = v_buffer; // set speed
        // Place the IN position into the Array
        
        /*
        gotoposition[0] = XInPoint;
        gotoposition[1] = YInPoint;
        gotoposition[2] = ZInPoint;
        stepper1.setMaxSpeed(inOutSpeed);
        stepper2.setMaxSpeed(inOutSpeed);
        stepper3.setMaxSpeed(inOutSpeed);

        Serial.print("Stepper X: ");
        Serial.println(stepper1.currentPosition());
        Serial.print("Xin:");
        Serial.println(XInPoint);

        Serial.print("Stepper Y: ");
        Serial.println(stepper2.currentPosition());
        Serial.print("Yin: ");
        Serial.println(YInPoint);

        Serial.print("Stepper Z: ");
        Serial.println(stepper3.currentPosition());
        Serial.print("Zin: ");
        Serial.println(ZInPoint);
        */

        
        if(stepper1.currentPosition()!=XInPoint||stepper2.currentPosition()!=YInPoint||stepper3.currentPosition()!=ZInPoint){
          StepperControl.moveTo(gotoposition); // Calculates the required speed for all motors
          StepperControl.runSpeedToPosition(); // Blocks until all are in position
          InandOut = 3;
        }
        //}
        //delay(200);
        //Serial.write(A) tell the app that the motor has arrived
        
        break;

      case 3: // Move to OUT position / go back to case 2
        InOutSet=false;
        // if current position!= gotoposition move to gotopositon else break
        //if(stepper1.currentPosition()!=XOutPoint){
        
        inOutSpeed = v_buffer;
        // Place the OUT position into the Array
        gotoposition[0] = XOutPoint;
        gotoposition[1] = YOutPoint;
        gotoposition[2] = ZOutPoint;
        stepper1.setMaxSpeed(inOutSpeed);
        stepper2.setMaxSpeed(inOutSpeed);
        stepper3.setMaxSpeed(inOutSpeed);
        /*
        Serial.print("Stepper X: ");
        Serial.println(stepper1.currentPosition());
        Serial.print("Xout:");
        Serial.println(XOutPoint);

        Serial.print("Stepper Y: ");
        Serial.println(stepper2.currentPosition());
        Serial.print("Yout: ");
        Serial.println(YOutPoint);

        Serial.print("Stepper Z: ");
        Serial.println(stepper3.currentPosition());
        Serial.print("Zout: ");
        Serial.println(ZOutPoint);


        // Calculates the required speed for all motors
        Serial.println("runto");
*/
        if(stepper1.currentPosition()!=XOutPoint||stepper2.currentPosition()!=YOutPoint||stepper3.currentPosition()!=ZOutPoint){
          StepperControl.moveTo(gotoposition);
          StepperControl.runSpeedToPosition(); // Blocks until all are in position
          InandOut = 2;
        }
        //Serial.println("complete");
        //delay(200); //replace with millis functions
        //Serial.write(A) tell the app that the motor has arrived
        //}
        break;

      case 4: // If Set button is held longer then half a second go back to case 0
        InandOut = 0;
        InOutSet=false;
        reset=false;
        delay(1000);
        break;
    }
  }
  prev_posx=stepper1.currentPosition();
  prev_posy=stepper2.currentPosition();
  prev_posz=stepper3.currentPosition();
  
  // Slider Movement
  // If potentiometer is turned left, move slider left
  if (x_buffer > prev_posx) {
 //  sliderPos = map(sliderPos, 600, 1024, 0, 3000);//TODO: FIX
    //update previous  pos 
    //prev_posx=x_buffer;
    stepper1.setSpeed(v_buffer); // Increase speed as turning
  }
  // If potentiometer is turned right, move slider right
  else if (x_buffer < prev_posx ) {
  //  sliderPos = map(sliderPos, 400, 0, 0, 3000);
    stepper1.setSpeed(-v_buffer); // Increase speed as turning
    //prev_posx=x_buffer;
  }
  // If potentiometer in middle, no movement
  else {
    stepper1.setSpeed(0);
  }

  // Pan movement
  // if Joystick is moved left, move stepper 2 or pan to left
  // If current_pos> prev_pos
  if (y_buffer > prev_posy) {
    stepper2.setSpeed(currentSpeed);
    //prev_posy=y_buffer;
  }
  // if Joystick is moved right, move stepper 2 or pan to right
  // If current_pos> prev_pos
  else if (y_buffer < prev_posy) {
    stepper2.setSpeed(-currentSpeed);
    //prev_posy=y_buffer;
  }
  // if Joystick stays in middle, no movement
  else {
    stepper2.setSpeed(0);
  }

  //Tilt movement
  if (z_buffer > prev_posz) {
    stepper3.setSpeed(currentSpeed);
    //prev_posz=z_buffer;
  }
  else if (z_buffer < prev_posz) {
    stepper3.setSpeed(-currentSpeed);
    //prev_posz=z_buffer;
  }
  else {
    stepper3.setSpeed(0);
  }

  
  // Execute the above commands - run the stepper motors
  stepper1.runSpeed();
  stepper2.runSpeed();
  stepper3.runSpeed();
}


/*This fuction parses serial commands sent from the app 
 X100> Y70> Z101> moves the camera to 
 S>  save as start position
 X150> Y100> Z50> move to end position
 V100> set x speed
 S> save as end position
 
 S> move to start
 S> move to move to end
 R> reset


*/
void readSerial(){
  bool newchar=false;
 
  while (Serial.available()>0 && newchar== false){
    char in;
    in=Serial.read();
    switch(in){
      //X input
      case 'X':
        //Set to X state
        state='X';
        break;
      //Y input
      case 'Y':
        //move to the Y state
        state='Y';
        break;
      //Z input
      case 'Z':
        //move to the Z state
        state='Z';
        break;
      //Set velocity
      case 'V':
        state='V';
        break;
      //reset
      case 'R':
        reset=true;
        break;
      //enable set mode
      case 'S':
        InOutSet=true;
        break;
      //END STATE
      case '>':
        //append terminate cstring char
        input_buffer[input_size]='\0';
        // convert cstring to int value
        if(state=='X'){
          x_buffer=atoi(input_buffer);
          //Serial.println("State X");
        }
        else if(state=='Y'){
          y_buffer=atoi(input_buffer);
          //Serial.println("State Y");
        }
        else if(state=='Z'){
          z_buffer=atoi(input_buffer);
          //Serial.println("State Z");
        }
        else if(state=='V'){
          v_buffer=atoi(input_buffer);
          //Serial.println("State Z");
        }
        
        //clear input buffer
        strcpy(input_buffer,"");
        //reset input buffer size
        input_size=0;
        //exit whileloop
        newchar=true;
        state='N';
      default:
        if(isDigit(in)){
          input_buffer[input_size]=in;
          input_size=input_size+1;
        }
      break;
    }
  }
 
  if(newchar==true){
  /*
    //Serial.print("Stepper X: ");
    //Serial.println(x);
    Serial.print("X:");
    Serial.println(x_buffer);

    //Serial.print("Stepper Y: ");
    //Serial.println(y);
    Serial.print("Y: ");
    Serial.println(y_buffer);

    //Serial.print("Stepper Z: ");
    //Serial.println(z);
    Serial.print("Z: ");
    Serial.println(z_buffer);
    Serial.println("new msg");
    */
    free(input_buffer);
    //send command back to app to confirm state and action
  
  }
  
}







