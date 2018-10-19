class Line {
  float start;
  float end;
  float start_time;
  float end_time;

  public Line(float start, float end, float time, float duration) {
    this.reset(start, end, time, duration);
  }

  public void reset(float start, float end, float time, float duration) {
    this.start = start;
    this.end = end;
    this.start_time = time;
    this.end_time = time + duration;
  }
    
  public float get(float time) {
    if(this.start_time < this.end_time) {
      float t = max(this.start_time, min(this.end_time, time));
      return map(t, this.start_time, this.end_time, this.start, this.end);
    } else {
      return this.end;
    }
  }
}
