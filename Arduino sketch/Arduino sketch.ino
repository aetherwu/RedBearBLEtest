
#include <SPI.h>
#include <boards.h>
#include <RBL_nRF8001.h>

#define LIGHT_1_PIN 4
#define LIGHT_2_PIN 7


void setup() {
  SPI.setDataMode(SPI_MODE0);
  SPI.setBitOrder(LSBFIRST);
  SPI.setClockDivider(SPI_CLOCK_DIV16);
  SPI.begin();

  ble_begin();

  pinMode(LIGHT_1_PIN, OUTPUT);
  pinMode(LIGHT_2_PIN, OUTPUT);
}

void loop() {

  if (ble_connected()) {
    digitalWrite(LIGHT_1_PIN, HIGH);
  } 
  else {
    digitalWrite(LIGHT_1_PIN, LOW);
  }

  ble_do_events();

  while(ble_available()) {

    byte data0 = ble_read();
    byte data1 = ble_read();
    if (data0 == 0x01) {
      if (data1 == 0x01) {
        digitalWrite(LIGHT_2_PIN, HIGH);
      } 
      else {
        digitalWrite(LIGHT_2_PIN, LOW);
      }
    } 
  }
}



