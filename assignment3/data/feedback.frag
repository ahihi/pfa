#version 410

uniform sampler2D scene;
uniform sampler2D past;
uniform vec2 resolution;
uniform bool shift;
uniform float flow;
uniform float feedback;

out vec4 out_color;

vec2 uv_map(vec2 uv) {
  vec2 uv_sym = uv * 2.0 - 1.0;
  vec2 sgn = sign(uv_sym);
  vec2 uv_sym_d = uv_sym * flow;
  vec2 uv_d = (uv_sym_d + 1.0) * 0.5;
  
  return uv_d;
}

vec3 rgb2hsl(vec3 rgb) {
    float r = rgb.r;
    float g = rgb.g;
    float b = rgb.b;
    float v, m, vm, r2, g2, b2;
    float h = 0.0;
    float s = 0.0;
    float l = 0.0;
    v = max(max(r, g), b);
    m = min(min(r, g), b);
    l = (m + v) / 2.0;
    if(l > 0.0) {
        vm = v - m;
        s = vm;
        if(s > 0.0) {
            s /= (l <= 0.5) ? (v + m) : (2.0 - v - m);
            r2 = (v - r) / vm;
            g2 = (v - g) / vm;
            b2 = (v - b) / vm;
            if(r == v) {
                h = (g == m ? 5.0 + b2 : 1.0 - g2);
            } else if(g == v) {
                h = (b == m ? 1.0 + r2 : 3.0 - b2);
            } else {
                h = (r == m ? 3.0 + g2 : 5.0 - r2);
            }
        }
    }
    h /= 6.0;
    return vec3(h, s, l);
}

vec3 hsl2rgb(vec3 hsl) {
    float h = hsl.x;
    float s = hsl.y;
    float l = hsl.z;
    float r = l;
    float g = l;
    float b = l;
    float v = (l <= 0.5) ? (l * (1.0 + s)) : (l + s - l*s);
    if(v > 0.0) {
        float m, sv;
        int sextant;
        float fract, vsf, mid1, mid2;
        m = l + l - v;
        sv = (v - m) / v;
        h *= 6.0;
        sextant = int(h);
        fract = h - float(sextant);
        vsf = v * sv * fract;
        mid1 = m + vsf;
        mid2 = v - vsf;
        if(sextant == 0) {
            r = v;
            g = mid1;
            b = m;
        } else if(sextant == 1) {
            r = mid2;
            g = v;
            b = m;
        } else if(sextant == 2) {
            r = m;
            g = v;
            b = mid1;
        } else if(sextant == 3) {
            r = m;
            g = mid2;
            b = v;
        } else if(sextant == 4) {
            r = mid1;
            g = m;
            b = v;
        } else if(sextant == 5) {
            r = v;
            g = m;
            b = mid2;
        }
    }
    return vec3(r, g, b);
}

vec3 hueshift(float dh, vec3 color) {
  vec3 hsl = rgb2hsl(color);
  hsl.x = fract(hsl.x + 1.0 + dh);
  return hsl2rgb(hsl);
}

void main() {
  vec2 uv = gl_FragCoord.xy/resolution;
  vec3 scene_color = hueshift(shift ? 0.25 : 0.0, texture(scene, uv).rgb);
  vec3 past_color = hueshift(shift ? -0.01 : 0.0, texture(past, uv_map(uv)).rgb);
  
  out_color = vec4(mix(scene_color, past_color, feedback), 1.0);;
}
