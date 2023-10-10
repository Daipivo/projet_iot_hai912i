#include <TFT_eSPI.h>       // Include the graphics library
TFT_eSPI tft = TFT_eSPI();  // Create object "tft"

const int ledPin = 17; // Pin sur lequel est connectée la LED

void setup() {
  pinMode(ledPin, OUTPUT); // Configure le pin de la LED en sortie
}

void loop() {
  // Fait clignoter la LED 5 fois
  for (int i = 0; i < 5; i++) {
    digitalWrite(ledPin, HIGH); // Allume la LED
    delay(500); // Attend 500 millisecondes (0,5 seconde)
    digitalWrite(ledPin, LOW); // Éteint la LED
    delay(500); // Attend à nouveau 500 millisecondes
  }
  delay(2000); // Attend 2 secondes avant de recommencer
}
