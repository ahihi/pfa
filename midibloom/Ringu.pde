class Ringu {
  public int low;
  public int high;
  public Line[] notes;
  public float[] values;
  
  public Ringu(int low, int high) {
    this.low = low;
    this.high = high;
    this.notes = new Line[this.count()];
    for(int i = 0; i < this.count(); i++) {
      this.notes[i] = new Line(0.0, 0.0, 0.0, 0.0);
    }
    this.values = new float[this.count()];
  }

  public int count() {
    return this.high - this.low + 1;
  }

  public boolean contains(int note) {
    boolean yes = this.low <= note && note <= this.high;
    return yes;
  }

  public void update(float time) {
    for(int i = 0; i < this.count(); i++) {
      this.values[i] = this.notes[i].get(time);
    }
  }
  
  public float get(int note) {
    return this.values[note];
  }
  
  public void set(int note, float start, float end, float time, float duration) {
    if(this.contains(note)) {
      int i = note - this.low;
      float value = this.values[i];
      float real_start = start;
      float real_duration = duration;
      if(min(start, end) <= value && value <= max(start, end)) {
        float elapsed_time = map(value, start, end, 0, duration);
        real_start = value;
        real_duration = duration - elapsed_time;
      }
      this.notes[i].reset(real_start, end, time, real_duration);
    }
  }
}
