#version 410

#define PROCESSING_LIGHT_SHADER

uniform mat4 modelview;
uniform mat4 transform;
uniform mat3 normalMatrix;
uniform mat4 texMatrix;

uniform float time;
uniform mat4 modelviewReal;
uniform mat4 modelviewInv;
uniform bool deform;

uniform int lightCount;
uniform vec4 lightPosition[8];

in vec4 vertex;
in vec4 color;
in vec3 normal;
in vec2 texCoord;

out vec4 vertColor;
out vec3 ecNormal;
out vec3 lightDir;
out vec4 vertTexCoord;

vec2 rect2polar(vec2 p) {
  return p.x == 0.0 && p.y == 0.0
    ? vec2(0.0, 0.0)
    : vec2(atan(p.y, p.x), length(p));
}

vec2 polar2rect(vec2 p) {
  return vec2(cos(p.x) * p.y, sin(p.x) * p.y);
}

void main() {
  vec4 v0 = vertex * modelviewInv;

  if(deform) {
    vec2 xz_polar = rect2polar(v0.xz);
    vec2 xy_polar = rect2polar(v0.xy);
    float k = sin(-7.0*(xz_polar.x + 0.2*time)) * cos(-8.0*xy_polar.x + 0.21*time);
    v0 = vec4(v0.xyz * (1 + (0.3 + 0.15 * sin(0.32*time)) * k), v0.w);
  }
  
  vec4 p = v0 * modelviewReal;
   
  gl_Position = transform * p;
  vec3 ecVertex = vec3(p);
  
  vec3 lightPos = vec3(6.0*sin(0.5*time), 6.0*cos(0.45*time), 5.0);
  ecNormal = normalize(normalMatrix * normal);
  lightDir = normalize(lightPos - ecVertex);
  vertColor = color;
  
  vertTexCoord = texMatrix * vec4(texCoord, 1.0, 1.0);
}
