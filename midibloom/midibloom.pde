import themidibus.*;

// name of the MIDI input device to use
// a list of available devices is printed on startup
String midi_device = "IAC Bus 1";

MidiBus midibus;
PGraphics pg;
PGraphics pg2;
PGraphics pg_blur;
PGraphics pg_pad;
PGraphics pg_mix;
PShader feedback_shader;
PShader blur_shader;
PShader pad_bass_shader;
PShader mix_shader;
float plinky_release = 0.2;
float pad_attack = 3.0;
float pad_release = 2.0;
Ringu ringu1;
Form form1;
Ringu ringu2;
Form form2;
Ringu pad_ringu;
float plinky_presence = 0.0;
float plinky_feedback = 0.0;
float pad_presence = 0.0;
float pad_brightness = 0.0;
float bass_note = 0.0;
float bass_presence = 0.0;
float bass_distort = 0.0;
float bass_velocity = 0.0;
float bass_angle = 0.0;
Line bass_line;
boolean inited = false;

void draw_ringu(PGraphics pg, Ringu ringu, Form form) {
  int n_notes = ringu.notes.length;
  for(int i = 0; i < n_notes; i++) {
    float onness = ringu.get(i);
    boolean is_black = i == 1 || i == 3 || i == 6 || i == 8 || i == 10;

    float angle = form.rotation + map(i, 0, n_notes, 0, TWO_PI);
    float x = form.origin_dist * cos(angle);
    float y = form.origin_dist * sin(angle);
    
    float note_size = map(onness, 0.0, 1.0, form.off_size, form.on_size);
    color note_color = is_black
      ? lerpColor(form.black_off_color, form.black_on_color, onness)
      : lerpColor(form.white_off_color, form.white_on_color, onness);
    float note_weight = map(onness, 0.0, 1.0, form.off_weight, form.on_weight);
      
    pg.stroke(note_color);
    pg.strokeWeight(note_weight);
    pg.ellipse((0.5 + x)*width, 0.5*height + y*width, note_size*width, note_size*width);
  }
}

void setup() {
  //size(960, 540, P3D);
  fullScreen(P3D);
  noStroke();
  noSmooth();
  textSize(24);

  MidiBus.list();
  midibus = new MidiBus(this, midi_device, -1);

  pg = createGraphics(width, height, P3D);
  pg.beginDraw();
  pg.fill(255, 255, 255);
  pg.noFill();
  pg.endDraw();
  
  feedback_shader = loadShader("feedback.frag");
  pg2 = createGraphics(width, height, P3D);
  pg2.beginDraw();
  pg2.background(0, 0, 0);
  pg2.fill(255, 255, 255);
  pg2.noStroke();
  pg2.shader(feedback_shader);
  pg2.endDraw();

  blur_shader = loadShader("blur.frag");
  pg_blur = createGraphics(width, height, P3D);
  pg_blur.beginDraw();
  pg_blur.background(0, 0, 0);
  pg_blur.fill(255, 255, 255);
  pg_blur.noStroke();
  pg_blur.shader(blur_shader);
  pg_blur.endDraw();

  pad_bass_shader = loadShader("padbass.frag");
  pg_pad = createGraphics(width, height, P3D);
  pg_pad.beginDraw();
  pg_pad.background(0, 0, 0);
  pg_pad.fill(255, 255, 255);
  pg_pad.noStroke();
  pg_pad.shader(pad_bass_shader);
  pg_pad.endDraw();

  mix_shader = loadShader("mix.frag");
  pg_mix = createGraphics(width, height, P3D);
  pg_mix.beginDraw();
  pg_mix.background(0, 0, 0);
  pg_mix.fill(255, 255, 255);
  pg_mix.noStroke();
  pg_mix.shader(mix_shader);
  pg_mix.endDraw();
  
  int low1 = 48;
  ringu1 = new Ringu(low1, low1+11);
  form1 = new Form() {{
    origin_dist = 0.0;
    rotation = 0.0;
    off_size = 0.01;
    on_size = 0.03;
    off_weight = 1;
    on_weight = 6;
    white_off_color = color(255, 255, 255, 64);
    white_on_color = color(255, 255, 255, 255);
    black_off_color = color(127, 127, 127, 64);
    black_on_color = color(127, 127, 127, 255);
  }};

  int low2 = low1+12;
  ringu2 = new Ringu(low2, low2+11);
  form2 = new Form() {{
    origin_dist = 0.0;
    rotation = 0.0;
    off_size = form1.off_size;
    on_size = form1.on_size;
    off_weight = form1.off_weight;
    on_weight = form1.on_weight;
    white_off_color = form1.white_off_color;
    white_on_color = form1.white_on_color;
    black_off_color = form1.black_off_color;
    black_on_color = form1.black_on_color;
  }};

  int pad_low = 0;
  pad_ringu = new Ringu(pad_low, pad_low+11);

  bass_line = new Line(0.0, 0.0, 0.0, 0.0);
  
  inited = true;
}

void draw() {
  float time = getTime();

  ringu1.update(time);
  ringu2.update(time);
  pad_ringu.update(time);
  
  float turn_freq = 0.02;
  float dist0 = 0.17;
  float k = 0.1;
  float sin_freq = 3.0*turn_freq;
  
  form1.origin_dist = dist0 + k * sin(sin_freq*TWO_PI*time);
  form1.rotation = turn_freq * TWO_PI * time + TWO_PI / (ringu1.count() * 2.0);

  form2.origin_dist = dist0 + k * sin(sin_freq*TWO_PI*time + PI);
  form2.rotation = -turn_freq * TWO_PI * time;
  
  pg.beginDraw();
  pg.background(0, 0, 0, 0);
  draw_ringu(pg, ringu1, form1);
  draw_ringu(pg, ringu2, form2);
  pg.endDraw();
    
  float blur_amount = 3.0 * (1.0 - plinky_presence);
  
  pg_blur.beginDraw();
  pg_blur.background(0, 0, 0);
  blur_shader.set("image", pg);
  blur_shader.set("resolution", width, height);
  blur_shader.set("direction", blur_amount, 0.0);
  pg_blur.rect(0, 0, width, height);
  pg_blur.endDraw();

  pg_blur.beginDraw();
  blur_shader.set("image", pg_blur);
  blur_shader.set("resolution", width, height);
  blur_shader.set("direction", 0.0, blur_amount);
  pg_blur.rect(0, 0, width, height);
  pg_blur.endDraw();

  pg2.beginDraw();
  feedback_shader.set("resolution", width, height);
  feedback_shader.set("time", time);
  feedback_shader.set("scene", pg_blur);
  feedback_shader.set("past", pg2);
  feedback_shader.set("plinky_presence", plinky_presence);
  feedback_shader.set("plinky_feedback", plinky_feedback);
  pg2.rect(0, 0, width, height);
  pg2.endDraw();

  pg_pad.beginDraw();
  pad_bass_shader.set("resolution", width, height);
  pad_bass_shader.set("time", time);
  pad_bass_shader.set("notes", pad_ringu.values);
  pad_bass_shader.set("past", pg_pad);
  pad_bass_shader.set("pad_presence", pad_presence);
  pad_bass_shader.set("pad_brightness", pad_brightness);
  pad_bass_shader.set("bass_presence", bass_presence);
  pad_bass_shader.set("bass_distort", bass_distort);
  pad_bass_shader.set("bass_note", bass_note);
  pad_bass_shader.set("bass_velocity", bass_velocity);
  pad_bass_shader.set("bass_angle", bass_angle);
  pad_bass_shader.set("bass_line", bass_line.get(time));
  pg_pad.rect(0, 0, width, height);
  pg_pad.endDraw();

  pg_mix.beginDraw();
  mix_shader.set("plinky", pg2);
  mix_shader.set("pad", pg_pad);
  pg_mix.rect(0, 0, width, height);
  pg_mix.endDraw();
  
  image(pg_mix, 0, 0);
}

float getTime() {
  return 0.001*millis();
}

void setNote(int channel, int pitch, int velocity, boolean on) {
  if(!inited) {
    return;
  }
  
  float time = getTime();

  //println("note" + (on ? "On" : "Off") + " " + channel + " " + pitch + " " + velocity);
  
  if(channel == 0) {
    float start = on ? 0.0 : 1.0;
    float end = on ? 1.0 : 0.0;
    float duration = on ? 0.0 : plinky_release;
    
    ringu1.set(pitch, start, end, time, duration);
    ringu2.set(pitch, start, end, time, duration);
  } else if(channel == 1) {
    float start = on ? 0.0 : 1.0;
    float end = on ? 1.0 : 0.0;
    float duration = on ? pad_attack : pad_release;

    pad_ringu.set(pitch % 12, start, end, time, duration);
  } else if(channel == 2) {
    float note = float(pitch);
    if(on || bass_note == note) {
      bass_note = on ? note : 0.0;
      bass_velocity = on ? velocity / 127.0 : 0.0;
      if(on) {
        bass_angle = random(0, TWO_PI);
      } 
    }

    if(on) {
      bass_line.reset(1.0, 1.0, time, 0.00);
    } else {
      bass_line.reset(1.0, 0.0, time, 0.05);
    }
  }
}

void noteOn(int channel, int pitch, int velocity) {
  setNote(channel, pitch, velocity, true);
}

void noteOff(int channel, int pitch, int velocity) {
  setNote(channel, pitch, velocity, false);
}

void controllerChange(int channel, int number, int value) {
  if(!inited) {
    return;
  }
  
  //println("controllerChange " + channel + " " + number + " " + value);

  float value_n = float(value) / 127.0;
  
  switch(number) {
  case 30:
    plinky_presence = value_n;
    break;
    
  case 31:
    plinky_feedback = value_n;
    break;

  case 32:
    pad_presence = value_n;
    break;

  case 33:
    pad_brightness = value_n;
    break;

  case 34:
    bass_presence = value_n;
    break;

  case 35:
    bass_distort = value_n;
    break;
  }  
}
