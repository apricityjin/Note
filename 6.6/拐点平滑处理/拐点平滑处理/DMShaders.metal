//
//  DMShaders.metal
//  DemoMetal
//
//  Created by apricity on 2023/5/30.
//

#include <metal_stdlib>
using namespace metal;

#include "DMShaderTypes.h"

// Vertex shader outputs and fragment shader inputs
struct RasterizerData
{
    float4 position [[position]];
};

vertex RasterizerData
vertexShader(uint vertexID [[vertex_id]],
             constant vector_float2 *viewportSizePointer [[buffer(0)]],
             constant DMVertex *vertices [[buffer(1)]])
{
    RasterizerData out;
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);
    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = pixelSpacePosition / (viewportSize / 2.0);
    return out;
}

fragment float4
fragmentShader(RasterizerData in [[stage_in]],
               texture2d<half> colorTexture [[texture(0)]])
{
    return float4(1.0, 0, 0, 1.0);
}
