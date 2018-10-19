boolean animate = true;
float count = 9;
float r_socket_min = 0.05;
float r_socket_max = 0.2;
float r_iris_min = 0.55;
float r_iris_max = 0.8;
float r_pupil_min = 0.5;
float r_pupil_max = 0.7;
float pad = 0.15;
float rot_max = TWO_PI / 32.0;
float eyeInterval = 10.0;
int fitAttempts = 5;

float t_nextEye = 0.0;

EyeCanvas eyeCanvas;
ArrayList<Eye> eyes;
ArrayList<Eye> eyes2;

void addEye(float t) {
  float r_socket = random(r_socket_min, r_socket_max) * height;

  float x = 0.0;
  float y = 0.0;
  int i = 0;
  boolean fits = false;
  while(!fits && i < fitAttempts) {
    x = random(pad, 1.0-pad) * width;
    y = random(pad, 1.0-pad) * height;
    i++;
    fits = true;
    for(Eye eye : eyes) {
      float distance = dist(eye.s.x, eye.s.y, x, y);
      if(distance <= r_socket + eye.s.r_socket) {
        fits = false;
        break;
      }
    }
  }

  if(!fits) {
    return;
  }
  
  float r_iris = random(r_iris_min, r_iris_max) * r_socket;
  float r_pupil = random(r_pupil_min, r_pupil_max) * r_iris;
  float rot = random(-rot_max, rot_max);
  color c_iris = color(
    round(random(0.0, 1.0) * 255),
    round(random(0.0, 1.0) * 255),
    round(random(0.0, 1.0) * 255)
  );

  eyes.add(new Eye(
    new EyeState(
      x, y, rot, 0.0,
      r_socket, r_iris, r_pupil,
      c_iris, color(0, 0, 0),
      0.0, 0.0
    ),
    random(200.0, 500.0),
    random(500.0, 2000.0),
    random(200.0, 500.0),
    t
  ));
}

void setup() {
  //size(960, 540);
  fullScreen();

  eyeCanvas = new EyeCanvas(width, height);
  eyes = new ArrayList<Eye>();
  eyes2 = new ArrayList<Eye>();
    
  noStroke();
  fill(255);
  ellipseMode(CENTER);
  
  if(animate) {
    frameRate(60);
  } else {
    noLoop();
    randomSeed(312334411);
  }
  
  background(0, 0, 0);
}

void draw() {
  float t = millis();

  if(t_nextEye <= t) {
    addEye(t);
    t_nextEye = t + eyeInterval;
  }

  eyeCanvas.clear(color(255, 255, 255));

  eyes2.clear();
  for(Eye eye : eyes) {
    eye.update(t, mouseX, mouseY);
    if(eye.isAlive()) {
      eyes2.add(eye);
    }
  }
  ArrayList<Eye> eyesTemp = eyes;
  eyes = eyes2;
  eyes2 = eyesTemp;

  eyeCanvas.eyes(eyes);
  
  background(0, 0, 0);
  eyeCanvas.draw();  
}
