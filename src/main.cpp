#include <Arduino.h>
#include <ESP32Servo.h>

const int trigPin = 13; 
const int echoPin = 12; 
const int servoPin = 14; 


Servo myServo;
void escanIda();
void escanVuelta();
long calcularDistancia();

void setup(){ 
  Serial.begin(115200);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  myServo.attach(servoPin);
}

void loop() {
  
  escanIda();
  escanVuelta();
}

void escanIda()
{
    for (int i = 0; i <= 180; i++) {
    myServo.write(i);
    delay(80); 
    int dist = calcularDistancia();
    
    Serial.print(i);
    Serial.print(",");
    Serial.print(dist);
    Serial.println(".");
  }
}

void escanVuelta()
{
    for (int i = 180; i >= 0; i--) {
    myServo.write(i);
    delay(80); 
    int dist = calcularDistancia();
    
    Serial.print(i);
    Serial.print(",");
    Serial.print(dist);
    Serial.println(".");
  }
}

long calcularDistancia() {
  long lecturas[3];
  
  for(int i = 0; i < 3; i++) {
    digitalWrite(trigPin, LOW);
    delayMicroseconds(2);
    digitalWrite(trigPin, HIGH);
    delayMicroseconds(10);
    digitalWrite(trigPin, LOW);
    
    long duracion = pulseIn(echoPin, HIGH, 25000); 
    lecturas[i] = duracion * 0.034 / 2;
    delay(10); 
  }
  
  
  if (lecturas[0] > lecturas[1]) std::swap(lecturas[0], lecturas[1]);
  if (lecturas[1] > lecturas[2]) std::swap(lecturas[1], lecturas[2]);
  if (lecturas[0] > lecturas[1]) std::swap(lecturas[0], lecturas[1]);

  long distancia = lecturas[1];

  if (distancia <= 2 || distancia > 400) return 400; 
  return distancia;
}
