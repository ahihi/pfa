#version 410

uniform vec2 resolution;
uniform sampler2D plinky;
uniform sampler2D pad;

out vec4 out_color;

void main() {
  vec2 uv = gl_FragCoord.xy / resolution;
  out_color = clamp(texture(plinky, uv) + texture(pad, uv), 0.0, 1.0);
}
