#include <SoftwareSerial.h>

#include <SPI.h>
#include <boards.h>
#include <ble_shield.h>
#include <RBL_nRF8001.h>

#define txPin 0
#define rxPin 1
#define powerPin 3
#define telePin 5
#define LED_CONNECTED_PIN 7

byte pinState = 0;

SoftwareSerial mySerial =  SoftwareSerial(rxPin, txPin);

char inData[20]; // Allocate some space for the string
char inChar = -1; // Where to store the character read
byte index = 0; // Index into array; where to store the character

void setup() {
  //prepare the BLE model
  SPI.setDataMode(SPI_MODE0);
  SPI.setBitOrder(LSBFIRST);
  SPI.setClockDivider(SPI_CLOCK_DIV16);
  SPI.begin();

  ble_begin();

  pinMode(LED_CONNECTED_PIN, OUTPUT);
  pinMode(telePin, OUTPUT);
  pinMode(powerPin, OUTPUT);
  
  // define pin modes for tx, rx, led pins:
  pinMode(rxPin, INPUT);
  pinMode(txPin, OUTPUT);

  // set the data rate for the SoftwareSerial port
  mySerial.begin(9600);
  digitalWrite(powerPin, HIGH);
}

void loop() {

  if (ble_connected()) {
    digitalWrite(LED_CONNECTED_PIN, HIGH);
  }
  else {
    digitalWrite(LED_CONNECTED_PIN, LOW);
  }

  //Receive from BLE
  while (ble_available()) {
    byte data0 = ble_read();
    //Send to serial
    mySerial.print(data0);
    digitalWrite(telePin, HIGH);
  }

  //Receive from arduino
  while ( mySerial.available() ) {
    //send to BLE
    ble_write( mySerial.read() );
    digitalWrite(telePin, HIGH);
  }

  digitalWrite(telePin, LOW);


  ble_do_events();
}

void toggle(int pinNum) {
  // set the LED pin using the pinState variable:
  digitalWrite(pinNum, pinState);
  // if pinState = 0, set it to 1, and vice versa:
  pinState = !pinState;
}

