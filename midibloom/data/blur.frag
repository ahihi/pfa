#version 410

uniform sampler2D image;
uniform vec2 resolution;
uniform vec2 direction;

out vec4 out_color;

vec4 texture_o(sampler2D image, vec2 uv) {
  vec4 color = texture(image, uv);
  color.a = 1.0;
  return color;
}

// https://github.com/Jam3/glsl-fast-gaussian-blur
vec4 blur9(sampler2D image, vec2 uv, vec2 resolution, vec2 direction) {
  vec4 color = vec4(0.0);
  vec2 off1 = vec2(1.3846153846) * direction;
  vec2 off2 = vec2(3.2307692308) * direction;
  color += texture_o(image, uv) * 0.2270270270;
  color += texture_o(image, uv + (off1 / resolution)) * 0.3162162162;
  color += texture_o(image, uv - (off1 / resolution)) * 0.3162162162;
  color += texture_o(image, uv + (off2 / resolution)) * 0.0702702703;
  color += texture_o(image, uv - (off2 / resolution)) * 0.0702702703;
  return color;
}

vec4 blur13(sampler2D image, vec2 uv, vec2 resolution, vec2 direction) {
  vec4 color = vec4(0.0);
  vec2 off1 = vec2(1.411764705882353) * direction;
  vec2 off2 = vec2(3.2941176470588234) * direction;
  vec2 off3 = vec2(5.176470588235294) * direction;
  color += texture_o(image, uv) * 0.1964825501511404;
  color += texture_o(image, uv + (off1 / resolution)) * 0.2969069646728344;
  color += texture_o(image, uv - (off1 / resolution)) * 0.2969069646728344;
  color += texture_o(image, uv + (off2 / resolution)) * 0.09447039785044732;
  color += texture_o(image, uv - (off2 / resolution)) * 0.09447039785044732;
  color += texture_o(image, uv + (off3 / resolution)) * 0.010381362401148057;
  color += texture_o(image, uv - (off3 / resolution)) * 0.010381362401148057;
  return color;
}

void main() {
  vec2 uv = gl_FragCoord.xy/resolution;
  out_color = blur13(image, uv, resolution, direction);
}
