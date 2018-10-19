class EyeState {
  public float x;
  public float y;
  public float rot;
  public float openness;
  public float r_socket;
  public float r_iris;
  public float r_pupil;
  public color c_iris;
  public color c_pupil;
  public float lookAt_x;
  public float lookAt_y;

  public EyeState(
    float x, float y, float rot, float openness,
    float r_socket, float r_iris, float r_pupil,
    color c_iris, color c_pupil,
    float lookAt_x, float lookAt_y
  ) {
    this.x = x;
    this.y = y;
    this.rot = rot;
    this.openness = openness;
    this.r_socket = r_socket;
    this.r_iris = r_iris;
    this.r_pupil = r_pupil;
    this.c_iris = c_iris;
    this.c_pupil = c_pupil;
    this.lookAt_x = lookAt_x;
    this.lookAt_y = lookAt_y;
  }
}
