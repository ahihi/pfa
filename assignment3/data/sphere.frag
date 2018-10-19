#version 410

uniform sampler2D moonTex;
uniform float time;
uniform vec2 resolution;

in vec4 vertColor;
in vec3 ecNormal;
in vec3 lightDir;
in vec4 vertTexCoord;

out vec4 out_color;

void main() {  
  vec3 direction = normalize(lightDir);
  vec3 normal = normalize(ecNormal);
  float intensity = max(0.0, dot(direction, normal));
  vec4 tintColor = vec4(intensity, intensity, intensity, 1.0) * vertColor;
  vec4 color = texture(moonTex, vertTexCoord.st) * tintColor;
  
  out_color = color;
}
