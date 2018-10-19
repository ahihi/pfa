boolean animate = true;
float count = 9;
float r_eye_min = 0.05;
float r_eye_max = 0.2;
float r_iris_min = 0.55;
float r_iris_max = 0.7;
float r_pupil_min = 0.5;
float r_pupil_max = 0.7;
float pad = 0.15;
float a_max = TWO_PI / 32.0;

void eye(
  float x, float y,
  float r_eye, float r_iris, float r_pupil,
  color c_eye, color c_iris, color c_pupil
) {
  float a = TWO_PI/10.0;
  float dy = r_eye * 0.5 * sin(a) + 0.5;

  fill(c_eye);
  //arc(x, y-dy, r_eye, r_eye, a, PI-a, OPEN);
  //arc(x, y+dy, r_eye, r_eye, PI+a, TWO_PI-a, OPEN);
  // OpenProcessing doesn't seem to support arc(..., OPEN). math time!
  for(int i = -1; i <= 1; i += 2) {
    float a0_x = x + r_eye;
    float a0_y = y - i * 0.5;
    float c0_x = a0_x - 0.5*r_eye;
    float c0_y = a0_y + i * 0.5*r_eye;
    float a1_x = x - r_eye;
    float a1_y = y - i * 0.5;
    float c1_x = a1_x + 0.5*r_eye;
    float c1_y = a1_y + i * 0.5*r_eye; 
    bezier(a0_x, a0_y, c0_x, c0_y, c1_x, c1_y, a1_x, a1_y);  
  }
  
  fill(c_iris);
  ellipse(x, y, r_iris, r_iris);
  
  fill(c_pupil);
  ellipse(x, y, r_pupil, r_pupil);
}

float rescale(float l0, float r0, float l1, float r1, float x) {
  return (x-l0) / (r0-l0) * (r1-l1) + l1;
}

void setup() {
  //size(960, 540);
  fullScreen();
  noStroke();
  fill(255);
  ellipseMode(CENTER);
  
  if(animate) {
    frameRate(10);
  } else {
    noLoop();
    randomSeed(312334411);
  }
  
  background(0, 0, 0);
}

void draw() {  
  fill(0, 0, 0, 64);
  rect(0, 0, width, height);
  
  for(int i = 0; i < count; i++) {
    float x = random(pad, 1.0-pad) * width;
    float y = random(pad, 1.0-pad) * height;
    float r_eye = random(r_eye_min, r_eye_max) * height;
    float r_iris = random(r_iris_min, r_iris_max) * r_eye;
    float r_pupil = random(r_pupil_min, r_pupil_max) * r_iris;
    float a = random(-a_max, a_max);
    color c_iris = color(
      round(random(0.0, 1.0) * 255),
      round(random(0.0, 1.0) * 255),
      round(random(0.0, 1.0) * 255)
    );
    
    pushMatrix();
    translate(x, y);
    rotate(a);
    eye(
      0, 0,
      r_eye, r_iris, r_pupil,
      color(255, 255, 255), c_iris, color(0, 0, 0)
    );
    popMatrix();
  }
}
