// keys
//
// 1: sphere
// 2: +deformation
// 3: +feedback
// 4: +flow
// 5: +hue shift (default)
// space: reverse flow

PShader planetShader;
PImage planetTexture;
PGraphics pg;
PShader feedbackShader;
PGraphics pg2;
float cameraY = 0;
float cameraZ = 8;

boolean noDeform = false;
boolean noFeedback = false;
boolean noFlow = false;
boolean noHueShift = false;
boolean reverseFlow = false;

void setup() {
  fullScreen(P3D);
  
  frameRate(60);

  planetShader = loadShader("sphere.frag", "sphere.vert");
  planetTexture = loadImage("venusmap-violet.png");
  pg = createGraphics(width, height, P3D);
  pg.beginDraw();
  pg.noStroke();
  pg.fill(255, 255, 255);
  pg.smooth();
  pg.sphereDetail(220);
  
  float invAspect = ((float) height) / width;
  pg.frustum(-1.0, 1.0, -invAspect, invAspect, 1, 20);
  pg.camera(0, cameraY, cameraZ, 0, cameraY, 0, 0, 1, 0);
  pg.shader(planetShader);
  pg.endDraw();

  feedbackShader = loadShader("feedback.frag");
  pg2 = createGraphics(width, height, P3D);
  pg2.beginDraw();
  pg2.noStroke();
  pg2.fill(255, 255, 255);
  pg2.background(0, 0, 0);
  pg2.shader(feedbackShader);
  pg2.endDraw();
  
  noStroke();
  fill(255, 255, 255);
}

void draw() {
  float t = 0.001 * millis();
  
  pg.beginDraw();
  
  pg.background(0, 0, 0);
  pg.ambientLight(0, 0, 0);
  
  PMatrix3D modelviewReal = ((PGraphicsOpenGL) pg).modelview;
  PMatrix3D modelviewInv = ((PGraphicsOpenGL) pg).modelviewInv;

  planetShader.set("time", t);
  planetShader.set("moonTex", planetTexture);
  planetShader.set("modelviewReal", modelviewReal);
  planetShader.set("modelviewInv", modelviewInv);
  planetShader.set("deform", !noDeform);
  
  pg.pushMatrix();
  pg.rotateY(0.1*t);
  pg.sphere(4.0);
  pg.popMatrix();

  pg.endDraw();

  pg2.beginDraw();

  feedbackShader.set("scene", pg);
  feedbackShader.set("past", pg2);
  feedbackShader.set("resolution", width, height);
  feedbackShader.set("shift", !noHueShift);
  feedbackShader.set("flow", noFlow ? 1.0 : reverseFlow ? 1.01 : 0.99);
  feedbackShader.set("feedback", noFeedback ? 0.0 : 0.95);
  
  pg2.rect(0, 0, width, height);

  pg2.endDraw();

  image(pg2, 0, 0);
}

void keyPressed() {
  if('1' <= key && key <= '5') {
    noDeform = key < '2';
    noFeedback = key < '3';
    noFlow = key < '4';
    noHueShift = key < '5';
  }

  if(key == ' ') {
    reverseFlow = !reverseFlow;
  }
}
