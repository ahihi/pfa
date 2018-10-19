class EyeCanvas {
  private int w;
  private int h;
  private PGraphics src;
  private PGraphics mask;
  
  public EyeCanvas(int w, int h) {
    this.w = w;
    this.h = h;
    
    this.src = createGraphics(this.w, this.h);
    this.src.beginDraw();
    this.src.noStroke();
    this.src.endDraw();
    
    this.mask = createGraphics(this.w, this.h);
    this.mask.beginDraw();
    this.mask.noStroke();
    this.mask.endDraw();
  }

  public void clear(color c_socket) {
    this.src.beginDraw();
    this.src.background(c_socket);
    this.src.endDraw();

    this.mask.beginDraw();
    this.mask.clear();
    this.mask.endDraw();
  }

  public void eyes(ArrayList<Eye> eyes) {
    float a = TWO_PI/10.0;
        
    float k_look = 0.3;
    float k_look_pupil = 0.33;
  
    this.src.beginDraw();
    this.mask.beginDraw();
    
    for(Eye eye : eyes) {
      EyeState s = eye.s;

      // Draw the iris and pupil
      
      float look_dx = s.lookAt_x - s.x;
      float look_dy = s.lookAt_y - s.y;
      float look_a = (float) Math.atan2(look_dy, look_dx);
      float distance = dist(s.x, s.y, s.lookAt_x, s.lookAt_y);
      float distance_n = distance / (k_look*s.r_socket);
      float k_distance = distance_n < 1.0 ? distance_n : 1.0;

      float look_x = (float) Math.cos(look_a) * k_distance;
      float look_y = (float) Math.sin(look_a) * k_distance;
      
      this.src.pushMatrix();
      this.src.translate(s.x, s.y);
      this.src.rotate(s.rot);
      
      this.src.fill(s.c_iris);
      this.src.ellipse(k_look*look_x*s.r_socket, k_look*look_y*s.r_socket, s.r_iris, s.r_iris);
      
      this.src.fill(s.c_pupil);
      this.src.ellipse(k_look_pupil*look_x*s.r_socket, k_look_pupil*look_y*s.r_socket, s.r_pupil, s.r_pupil);
      
      this.src.popMatrix();

      // Draw the white

      this.mask.pushMatrix();
      this.mask.translate(s.x, s.y);
      this.mask.rotate(s.rot);
    
      this.mask.fill(255, 255, 255);
  
      for(int i = -1; i <= 1; i += 2) {
        float a0_x = 0 + s.r_socket;
        float a0_y = 0 - i * 0.5;
        float c0_x = a0_x - 0.5*s.r_socket;
        float c0_y = a0_y + i * 0.5*s.openness*s.r_socket;
        float a1_x = 0 - s.r_socket;
        float a1_y = 0 - i * 0.5;
        float c1_x = a1_x + 0.5*s.r_socket;
        float c1_y = a1_y + i * 0.5*s.openness*s.r_socket; 
        this.mask.bezier(a0_x, a0_y, c0_x, c0_y, c1_x, c1_y, a1_x, a1_y);  
      }

      this.mask.popMatrix();
    }
        
    this.src.endDraw();
    this.mask.endDraw();
  }

  public void draw() {
    this.src.mask(this.mask);
    image(this.src, 0, 0);
  }
}
