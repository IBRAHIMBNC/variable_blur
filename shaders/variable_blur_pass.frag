#version 460 core
precision highp float;

#include <flutter/runtime_effect.glsl>

// One pass of a separable variable Gaussian blur, run on a small (downscaled)
// copy of the child. The widget runs it twice: horizontal (uDirection = 1,0),
// then vertical (uDirection = 0,1). Each pixel gets its own sigma: 0 outside
// the blur regions, rising smoothly to uSigma inside them.
//
// All lengths are pixels of the small copy.

uniform vec2 uSize;          // size of the small copy
uniform float uSigma;        // full-strength sigma
uniform float uTop;          // how far each blur region reaches
uniform float uBottom;
uniform float uLeft;
uniform float uRight;
uniform float uTransition;   // distance over which the blur rises
uniform vec2 uDirection;     // (1,0) horizontal, (0,1) vertical
uniform float uTaps;         // samples per side for this quality, <= kTaps
uniform float uFlip;         // 1 to flip the image's Y axis when sampling

uniform sampler2D uTexture;

out vec4 fragColor;

const int kTaps = 32;        // upper bound on samples per side

// Reads the image, repeating its edge pixels past the border. Some backends
// return transparent outside the image, which would let the sharp child show
// through near the edges.
vec4 tap(vec2 uv) {
  vec2 edge = 0.5 / uSize;
  return texture(uTexture, clamp(uv, edge, 1.0 - edge));
}

float rise(float dist, float extent) {
  // dist: how far the pixel is inside a region, from the region's inner edge.
  if (extent <= 0.0 || dist <= 0.0) return 0.0;
  return smoothstep(0.0, 1.0, dist / max(uTransition, 1.0));
}

float strength(vec2 p) {
  return max(max(rise(uTop - p.y, uTop),
                 rise(p.y - (uSize.y - uBottom), uBottom)),
             max(rise(uLeft - p.x, uLeft),
                 rise(p.x - (uSize.x - uRight), uRight)));
}

void main() {
  vec2 p = FlutterFragCoord().xy;
  vec2 uv = p / uSize;
  float flip = uFlip;
#ifdef IMPELLER_TARGET_OPENGLES
  flip = 1.0 - flip;
#endif
  if (flip > 0.5) uv.y = 1.0 - uv.y;
  vec2 dir = uDirection;
  if (flip > 0.5) dir.y = -dir.y;

  float sigma = uSigma * strength(p);
  if (sigma < 0.35) {
    fragColor = tap(uv);
    return;
  }

  // Cover +-2.5 sigma (99% of the weight) with at most uTaps samples per
  // side. For large sigma the samples are spread out; linear filtering fills
  // small gaps, and a per-pixel random shift of the sample positions turns
  // what would be a visible grid into fine, invisible noise.
  float radius = 2.5 * sigma;
  float taps = clamp(uTaps, 1.0, float(kTaps));
  float stride = max(1.0, radius / taps);
  vec2 step = dir * stride / uSize;
  float jitter = stride > 1.5
      ? fract(52.9829189 * fract(dot(p, vec2(0.06711056, 0.00583715)))) - 0.5
      : 0.0;
  float k = -0.5 * stride * stride / (sigma * sigma);

  vec4 sum = tap(uv);
  float total = 1.0;
  for (int i = 1; i <= kTaps; i++) {
    float fi = float(i);
    if (fi > taps || fi * stride > radius) break;
    float a = fi + jitter;
    float b = fi - jitter;
    float wa = exp(k * a * a);
    float wb = exp(k * b * b);
    sum += tap(uv + step * a) * wa + tap(uv - step * b) * wb;
    total += wa + wb;
  }
  fragColor = sum / total;
}
