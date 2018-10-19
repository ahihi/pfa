#version 410

#define TAU 6.283185307179586

uniform vec2 resolution;
uniform float time;
uniform float notes[12];
uniform sampler2D past;
uniform float pad_presence;
uniform float pad_brightness;
uniform float bass_presence;
uniform float bass_distort;
uniform float bass_note;
uniform float bass_velocity;
uniform float bass_angle;
uniform float bass_line;

out vec4 out_color;

vec3 gray1 = vec3(0.4);
vec3 gray2 = vec3(0.7);
vec3 cyan = vec3(0.35686275, 0.80784315, 0.98039216);
vec3 pink = vec3(0.9529412, 0.6627451, 0.72156864);

float rescale(float l0, float r0, float l1, float r1, float x) {
  return (x-l0) / (r0-l0) * (r1-l1) + l1;
}

//	Classic Perlin 3D Noise 
//	by Stefan Gustavson
//
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}
vec3 fade(vec3 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}

float cnoise(vec3 P){
  vec3 Pi0 = floor(P); // Integer part for indexing
  vec3 Pi1 = Pi0 + vec3(1.0); // Integer part + 1
  Pi0 = mod(Pi0, 289.0);
  Pi1 = mod(Pi1, 289.0);
  vec3 Pf0 = fract(P); // Fractional part for interpolation
  vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
  vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  vec4 iy = vec4(Pi0.yy, Pi1.yy);
  vec4 iz0 = Pi0.zzzz;
  vec4 iz1 = Pi1.zzzz;

  vec4 ixy = permute(permute(ix) + iy);
  vec4 ixy0 = permute(ixy + iz0);
  vec4 ixy1 = permute(ixy + iz1);

  vec4 gx0 = ixy0 / 7.0;
  vec4 gy0 = fract(floor(gx0) / 7.0) - 0.5;
  gx0 = fract(gx0);
  vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
  vec4 sz0 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);

  vec4 gx1 = ixy1 / 7.0;
  vec4 gy1 = fract(floor(gx1) / 7.0) - 0.5;
  gx1 = fract(gx1);
  vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
  vec4 sz1 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);

  vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
  vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
  vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
  vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
  vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
  vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
  vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
  vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

  vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
  float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
  float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
  float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
  float n111 = dot(g111, Pf1);

  vec3 fade_xyz = fade(Pf0);
  vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
  vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
  float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
  return 2.2 * n_xyz;
}

vec2 rect2polar(vec2 p) {
  if(p.x == 0.0 && p.y == 0.0) {
    return vec2(0.0, 0.0);
  } else {
    return vec2(atan(p.y, p.x), length(p));            
  }
}

vec2 polar2rect(vec2 p) {
  return vec2(cos(p.x) * p.y, sin(p.x) * p.y);
}

vec3 pad(vec2 p_p) {
  float brightness_curve = pow(pad_brightness, 2.0);
  p_p.x *= -1.0;
  p_p.x += rescale(0.0, 1.0, 0.01, 0.03, brightness_curve) * sin(80.0*p_p.y / (1.0+1.0*p_p.y) - 3.0*time);
  p_p.x += 0.1*time;

  float f = fract(p_p.x / TAU) * 12.0;
  int i = int(floor(f));

  float r = fract(f);
  bool is_edge1 = r < 0.2 || 0.8 <= r;
  bool is_edge2 = r < 0.4 || 0.6 <= r;

  float k_mix = brightness_curve;
  vec3 color1 = mix(gray1, cyan, k_mix);
  vec3 color2 = mix(gray2, pink, k_mix);
  vec3 base_color = 0.4*(is_edge1 ? color1 : is_edge2 ? color2 : vec3(1.0));

  float nois = pow(cnoise(vec3(gl_FragCoord.xy, 2.0*time)) * cnoise(vec3(0.5*gl_FragCoord.yx, -1.6*time)), 0.5);
  float k_nois = 1.5;
  base_color = clamp(
    base_color * pow(k_nois, rescale(0.0, 1.0, -1.0, 1.0, nois)),
    0.0, 1.0
  );
  
  return pow(pad_presence, 0.8) * pow(notes[i], 0.5) * base_color;
}

float triangle(float t) {
  return 2.0 * (abs(0.5 - fract(t - 0.25))) - 0.5;
}

vec3 flower(vec2 p_p, float n, float r0, float r1, float w0) {
  float distort_curve = pow(bass_distort, 1.5);
  
  float k = rescale(0.0, 1.0, 0.0, 0.03, distort_curve);
  p_p.x += k*triangle(160.0*p_p.y - 2.1*time);
  float g = fract((p_p.x + bass_angle) / TAU) * n;
  float j = fract(g);
  float s = (r0 + r1*sin(TAU * j));
  float w = w0;
  float half_w = 0.5*w;

  vec3 color1 = vec3(0.6, 0.0, 0.0);
  vec3 color2 = vec3(1.0, 0.5, 0.0);
  vec3 color = pow(bass_presence, 1.2) * bass_velocity * mix(color1, color2, distort_curve);
  
  return p_p.y - half_w <= s && s < p_p.y + half_w ? color : vec3(0.0);
}

vec2 uv_map(vec2 uv) {
  vec2 uv_sym = uv * 2.0 - 1.0;
  vec2 sgn = sign(uv_sym);
  vec2 uv_sym_d = uv_sym * 0.98;
  vec2 uv_d = (uv_sym_d + 1.0) * 0.5;
  
  return uv_d;
}

void main() {
  vec2 p = (gl_FragCoord.xy - resolution.xy*0.5)/resolution.xx * 0.5;
  vec2 p_p = rect2polar(p);

  vec2 uv = gl_FragCoord.xy / resolution.xy;
  vec3 pad_color = pad(p_p);
  float r = 0.3;
  float w = 0.025 * bass_line;
  vec3 flower_color = flower(p_p, bass_note-23.0, r, r, w);
  vec3 color = pow(clamp(p_p.y, 0.0, 1.0), 0.75) * (pad_color + flower_color);
  
  out_color = vec4(color, 1.0) + 0.8*texture(past, uv_map(uv));
}
