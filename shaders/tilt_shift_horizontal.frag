#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uViewSize;
uniform float sigma;
uniform float topExtent;
uniform float bottomExtent;
uniform float leftExtent;
uniform float rightExtent;
uniform float isAndroid;
uniform float kernelSize;
uniform sampler2D uTexture;

out vec4 FragColor;

// Optimized Gaussian weight calculation
float getGaussianWeight(int offset, float sig) {
    float x = float(offset);
    return exp(-0.5 * x * x / (sig * sig));
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uViewSize;
    
    // Fix coordinate system for cross-platform compatibility
    if (isAndroid > 0.5) {
        uv.y = 1.0 - uv.y;
    }
    
    vec4 color = texture(uTexture, uv);
    
    // Early return if sigma is 0 - no blur needed
    if (sigma <= 0.0) {
        FragColor = color;
        return;
    }
    
    // Calculate edge positions
    float topEdge = topExtent * uViewSize.y;
    float bottomEdge = (1.0 - bottomExtent) * uViewSize.y;
    float leftEdge = leftExtent * uViewSize.x;
    float rightEdge = (1.0 - rightExtent) * uViewSize.x;
    
    // Check blur regions
    bool inTop = topExtent > 0.0 && fragCoord.y < topEdge;
    bool inBottom = bottomExtent > 0.0 && fragCoord.y > bottomEdge;
    bool inLeft = leftExtent > 0.0 && fragCoord.x < leftEdge;
    bool inRight = rightExtent > 0.0 && fragCoord.x > rightEdge;
    bool inBlurRegion = inTop || inBottom || inLeft || inRight;
    
    if (!inBlurRegion) {
        FragColor = color;
        return;
    }
    
    // Use kernel size provided from Dart side
    float kSizeFloat = max(kernelSize, 1.0);
    int kSize = int(kSizeFloat);

    vec3 result = vec3(0.0);
    float weightSum = 0.0;
    
    // Optimized loop bounds based on kernel size for better performance
    if (kSize <= 15) {
        // Small blur: use tight loop bounds
        for (int i = -15; i <= 15; ++i) {
            if (i < -kSize || i > kSize) continue;
            float weight = getGaussianWeight(i, sigma);
            if (weight < 0.001) continue;  // Skip negligible weights
            vec2 offset = vec2(float(i) / uViewSize.x, 0.0);
            vec2 sampleUV = uv + offset;
            result += texture(uTexture, sampleUV).rgb * weight;
            weightSum += weight;
        }
    } else if (kSize <= 30) {
        // Medium-small blur: use medium-small loop bounds
        for (int i = -30; i <= 30; ++i) {
            if (i < -kSize || i > kSize) continue;
            float weight = getGaussianWeight(i, sigma);
            if (weight < 0.001) continue;  // Skip negligible weights
            vec2 offset = vec2(float(i) / uViewSize.x, 0.0);
            vec2 sampleUV = uv + offset;
            result += texture(uTexture, sampleUV).rgb * weight;
            weightSum += weight;
        }
    } else if (kSize <= 50) {
        // Medium blur: use medium loop bounds
        for (int i = -50; i <= 50; ++i) {
            if (i < -kSize || i > kSize) continue;
            float weight = getGaussianWeight(i, sigma);
            if (weight < 0.001) continue;  // Skip negligible weights
            vec2 offset = vec2(float(i) / uViewSize.x, 0.0);
            vec2 sampleUV = uv + offset;
            result += texture(uTexture, sampleUV).rgb * weight;
            weightSum += weight;
        }
    } else {
        // Large blur: use full loop bounds
        for (int i = -100; i <= 100; ++i) {
            if (i < -kSize || i > kSize) continue;
            float weight = getGaussianWeight(i, sigma);
            if (weight < 0.001) continue;  // Skip negligible weights
            vec2 offset = vec2(float(i) / uViewSize.x, 0.0);
            vec2 sampleUV = uv + offset;
            result += texture(uTexture, sampleUV).rgb * weight;
            weightSum += weight;
        }
    }
    
    FragColor = vec4(result / weightSum, color.a);
}