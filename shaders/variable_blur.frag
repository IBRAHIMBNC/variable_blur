#version 460 core
precision highp float;

#include <flutter/runtime_effect.glsl>

// One pass of a separable variable Gaussian blur, run by the engine as an
// ImageFilter. The widget composes two instances: a horizontal pass
// (uDirection = 1,0) and then a vertical pass (uDirection = 0,1).
//
// Each pixel gets its own sigma: 0 outside the blur regions, rising smoothly
// to uSigma inside them. Pixels with sigma 0 are passed through untouched.
//
// The engine only hands over the part of the widget that is on screen, so
// uOrigin says where that part starts inside the whole widget. All lengths
// are physical pixels.

uniform vec2 uSize;          // set by the engine: size of the input texture
uniform float uSigma;        // full-strength sigma
uniform float uTop;          // how far each blur region reaches
uniform float uBottom;
uniform float uLeft;
uniform float uRight;
uniform float uTransition;   // distance over which the blur rises
uniform vec2 uDirection;     // (1,0) horizontal, (0,1) vertical
uniform float uTaps;         // samples per side for this quality, <= kTaps
uniform vec2 uOrigin;        // top-left of the texture inside the widget
uniform vec2 uWidget;        // size of the whole widget

uniform sampler2D uTexture;  // set by the engine: the child

out vec4 fragColor;

const int kTaps = 32;        // upper bound on samples per side

float rise(float dist, float extent) {
  // dist: how far the pixel is inside a region, from the region's inner edge.
  if (extent <= 0.0 || dist <= 0.0) return 0.0;
  return smoothstep(0.0, 1.0, dist / max(uTransition, 1.0));
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif
  vec2 p = uv * uSize + uOrigin;

  float s = max(
      max(rise(uTop - p.y, uTop),
          rise(p.y - (uWidget.y - uBottom), uBottom)),
      max(rise(uLeft - p.x, uLeft),
          rise(p.x - (uWidget.x - uRight), uRight)));

  float sigma = uSigma * s;
  if (sigma < 0.35) {
    fragColor = texture(uTexture, uv);
    return;
  }

  // Cover +-2.5 sigma (99% of the weight) with at most uTaps samples per
  // side. For large sigma the samples are spread out; linear filtering fills
  // small gaps, and a per-pixel random shift of the sample positions turns
  // what would be a visible grid into fine, invisible noise.
  float radius = 2.5 * sigma;
  float taps = clamp(uTaps, 1.0, float(kTaps));
  float stride = max(1.0, radius / taps);
  vec2 step = uDirection * stride / uSize;
  float jitter = stride > 1.5
      ? fract(52.9829189 * fract(dot(FlutterFragCoord().xy, vec2(0.06711056, 0.00583715)))) - 0.5
      : 0.0;
  float k = -0.5 * stride * stride / (sigma * sigma);

  vec4 sum = texture(uTexture, uv);
  float total = 1.0;
  for (int i = 1; i <= kTaps; i++) {
    float fi = float(i);
    if (fi > taps || fi * stride > radius) break;
    float a = fi + jitter;
    float b = fi - jitter;
    float wa = exp(k * a * a);
    float wb = exp(k * b * b);
    sum += texture(uTexture, uv + step * a) * wa +
           texture(uTexture, uv - step * b) * wb;
    total += wa + wb;
  }
  fragColor = sum / total;
}
