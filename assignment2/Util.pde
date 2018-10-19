static class Util {
  public static float rescale(float l0, float r0, float l1, float r1, float x) {
    return (x-l0) / (r0-l0) * (r1-l1) + l1;
  }
}
