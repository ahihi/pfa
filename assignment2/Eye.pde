class Eye {
  public EyeState s;
  private float dur_open;
  private float dur_stay;
  private float dur_close;
  private float t_start;
  private float t_open;
  private float t_stay;
  private float t_close;
  private float t;
  
  public Eye(
    EyeState s,
    float dur_open, float dur_stay, float dur_close,
    float t
  ) {
    this.s = s;
    this.dur_open = dur_open;
    this.dur_stay = dur_stay;
    this.dur_close = dur_close;
    this.t_start = t;
    this.t_open = this.t_start + this.dur_open;
    this.t_stay = this.t_open + this.dur_stay;
    this.t_close = this.t_stay + this.dur_close;
    this.t = t;
  }

  public void update(float t, float lookAt_x, float lookAt_y) {
    this.t = t;

    this.s.lookAt_x = lookAt_x;
    this.s.lookAt_y = lookAt_y;
    
    if(this.t < this.t_open) {
      this.s.openness = Util.rescale(this.t_start, this.t_open, 0.0, 1.0, this.t);
      return;
    }

    if(this.t < this.t_stay) {
      this.s.openness = 1.0;
      return;
    }

    if(this.t < this.t_close) {
      this.s.openness = Util.rescale(this.t_stay, this.t_close, 1.0, 0.0, this.t);
      return;
    }

    this.s.openness = 0.0;
  }

  public boolean isAlive() {
    return this.t < this.t_close;
  }
}
