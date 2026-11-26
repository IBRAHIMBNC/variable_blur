#version 460 core
precision highp float;

#include <flutter/runtime_effect.glsl>

// Lays the blurred small copy over the sharp child, stretched back to full
// size. It is fully visible where the blur is strong, fades out where the
// blur is weaker than the small copy's own softness, and is invisible in
// the sharp area, so the sharp part keeps every original pixel.
//
// The overlay only covers the child's own shape (taken from the unblurred
// small copy), so see-through parts such as rounded corners neither leak
// the sharp child through the blur nor spread a halo outside the shape.
//
// Lengths are in the widget's logical pixels.

uniform vec2 uSize;          // widget size
uniform float uTop;          // how far each blur region reaches
uniform float uBottom;
uniform float uLeft;
uniform float uRight;
uniform float uTransition;   // distance over which the blur rises
uniform float uSigmaSmall;   // full-strength sigma, in pixels of the small copy
uniform float uFlip;         // 1 to flip the image's Y axis when sampling
uniform vec2 uSmall;         // size of the small copy, in its pixels
uniform vec2 uCropOrigin;    // top-left of the part the small copy shows
uniform vec2 uCropSize;      // size of that part

uniform sampler2D uBlurred;
uniform sampler2D uShape;     // the unblurred small copy, for its alpha

out vec4 fragColor;

float rise(float dist, float extent) {
  if (extent <= 0.0 || dist <= 0.0) return 0.0;
  return smoothstep(0.0, 1.0, dist / max(uTransition, 1e-3));
}

void main() {
  vec2 p = FlutterFragCoord().xy;
  float s = max(max(rise(uTop - p.y, uTop),
                    rise(p.y - (uSize.y - uBottom), uBottom)),
                max(rise(uLeft - p.x, uLeft),
                    rise(p.x - (uSize.x - uRight), uRight)));
  // Below about one small-copy pixel of blur, the small copy is softer than
  // the blur asked for, so cross-fade from the sharp child instead.
  float alpha = smoothstep(0.0, 1.0, uSigmaSmall * s);
  if (alpha <= 0.0) {
    fragColor = vec4(0.0);
    return;
  }
  vec2 uv = (p - uCropOrigin) / uCropSize;
  float flip = uFlip;
  if (flip > 0.5) uv.y = 1.0 - uv.y;
  // Bilinear upscale done by hand, so it is smooth whatever filtering the
  // engine uses for shader images (older versions sample nearest).
  // Texel indexes are clamped so edge pixels repeat past the border.
  vec2 t = uv * uSmall - 0.5;
  vec2 f = fract(t);
  vec2 i0 = clamp(floor(t), vec2(0.0), uSmall - 1.0);
  vec2 i1 = clamp(floor(t) + 1.0, vec2(0.0), uSmall - 1.0);
  vec2 t00 = (vec2(i0.x, i0.y) + 0.5) / uSmall;
  vec2 t10 = (vec2(i1.x, i0.y) + 0.5) / uSmall;
  vec2 t01 = (vec2(i0.x, i1.y) + 0.5) / uSmall;
  vec2 t11 = (vec2(i1.x, i1.y) + 0.5) / uSmall;
  vec4 blurred = mix(mix(texture(uBlurred, t00), texture(uBlurred, t10), f.x),
                     mix(texture(uBlurred, t01), texture(uBlurred, t11), f.x),
                     f.y);
  float shape = mix(mix(texture(uShape, t00).a, texture(uShape, t10).a, f.x),
                    mix(texture(uShape, t01).a, texture(uShape, t11).a, f.x),
                    f.y);
  if (blurred.a <= 0.0) {
    fragColor = vec4(0.0);
    return;
  }
  // Blurred colour, un-premultiplied, then covered by the child's shape.
  fragColor = vec4(blurred.rgb / blurred.a, 1.0) * (alpha * shape);
}
