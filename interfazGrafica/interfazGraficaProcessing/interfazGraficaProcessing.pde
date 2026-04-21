import processing.serial.*;

Serial myPort;
String angle="";
String distance="";
String data="";
String noObject;
float pixsDistance;
int iAngle, iDistance;
int index1=0;

// LISTA PARA EL RASTRO PERSISTENTE
ArrayList<Detection> trail = new ArrayList<Detection>();

void setup() {
  size(1200, 700); 
  smooth();
  /*============================================IMPORTANTE========================================
Verifica que el puerto sea el correcto (el "/dev/ttyUSB0" por el COM3 o puerto que se esté utilizando 
 ===============================================IMPORTANTE========================================*/ 
myPort = new Serial(this, "/dev/ttyUSB0", 115200); 
  myPort.bufferUntil('.'); 
}

void draw() {
  // Limpiamos el fondo por completo para que el rastro lo controle la clase
  background(0); 

  drawRadar(); 
  
  // DIBUJAR RASTRO PERSISTENTE
  for (int i = trail.size() - 1; i >= 0; i--) {
    Detection d = trail.get(i);
    d.display();
    d.fade();
    if (d.isDead()) {
      trail.remove(i);
    }
  }
  
  drawLine();
  drawText();
}

void serialEvent (Serial myPort) {
  try {
    data = myPort.readStringUntil('.');
    if (data != null) {
      data = data.substring(0, data.length()-1);
      index1 = data.indexOf(",");
      
      if (index1 > -1) {
        angle = data.substring(0, index1);
        distance = data.substring(index1 + 1, data.length());

        iAngle = int(trim(angle));
        iDistance = int(trim(distance));

        // AGREGAR AL RASTRO SI ESTÁ EN RANGO
        if (iDistance < 40 && iDistance > 0) {
          trail.add(new Detection(iAngle, iDistance));
        }
      }
    }
  } catch (Exception e) {
    println("Error leyendo serial: " + e.toString());
  }
}

// CLASE PARA LOS CÍRCULOS PERSISTENTES
class Detection {
  float a, d;
  float opacity = 150; 

  Detection(float angle, float dist) {
    a = angle;
    d = dist;
  }

  void fade() {
    opacity -= 1.5; // Velocidad de desaparición
  }

  boolean isDead() {
    return opacity <= 0;
  }

  void display() {
    pushMatrix();
    translate(width/2, height-height*0.074);
    float pDist = d * ((height-height*0.1666)*0.025);
    noStroke();
    fill(255, 10, 10, opacity); // ROJO TRANSPARENTE
    ellipse(pDist*cos(radians(a)), -pDist*sin(radians(a)), 30, 30);
    popMatrix();
  }
}

void drawRadar() {
  pushMatrix();
  translate(width/2, height-height*0.074);
  noFill();
  strokeWeight(2);
  stroke(98, 245, 31);
  arc(0, 0, (width-width*0.0625), (width-width*0.0625), PI, TWO_PI);
  arc(0, 0, (width-width*0.27), (width-width*0.27), PI, TWO_PI);
  arc(0, 0, (width-width*0.479), (width-width*0.479), PI, TWO_PI);
  arc(0, 0, (width-width*0.687), (width-width*0.687), PI, TWO_PI);
  line(-width/2, 0, width/2, 0);
  popMatrix();
}

void drawLine() {
  pushMatrix();
  strokeWeight(9);
  stroke(30, 250, 60);
  translate(width/2, height-height*0.074);
  line(0, 0, (height-height*0.12)*cos(radians(iAngle)), -(height-height*0.12)*sin(radians(iAngle)));
  popMatrix();
}

void drawText() {
  pushMatrix();
  fill(0);
  noStroke();
  rect(0, height-height*0.0648, width, height); // Limpiar área de texto
  
  fill(98, 245, 31);
  textSize(25);
  text("10cm", width-width*0.3854, height-height*0.0833);
  text("20cm", width-width*0.281, height-height*0.0833);
  text("30cm", width-width*0.177, height-height*0.0833);
  text("40cm", width-width*0.0729, height-height*0.0833);
  
  textSize(40);
  text("Radar IoT", width-width*0.95, height-height*0.0277);
  text("Ang: " + iAngle + "°", width-width*0.48, height-height*0.0277);
  text("Dist: " + (iDistance < 40 ? iDistance + " cm" : "OOR"), width-width*0.26, height-height*0.0277);
  popMatrix();
}
