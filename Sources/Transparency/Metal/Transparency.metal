//
//  Created by Anton Heestand on 2021-09-18.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

fragment float4 transparencyMap(VertexOut vertexOut [[stage_in]],
                                texture2d<float> texture [[ texture(0) ]],
                                texture2d<float> backgroundTexture [[ texture(1) ]],
                                texture2d<float> mapTexture [[ texture(2) ]],
                                sampler sampler [[ sampler(0) ]]) {
    
    float u = vertexOut.texCoord[0];
    float v = vertexOut.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 color = texture.sample(sampler, uv);
    float4 backgroundColor = backgroundTexture.sample(sampler, uv);
    float4 mapColor = mapTexture.sample(sampler, uv);

    return float4(0.0);
}

fragment float4 transparencyBlur(VertexOut vertexOut [[stage_in]],
                                 texture2d<float> texture [[ texture(0) ]],
                                 texture2d<float> backgroundTexture [[ texture(1) ]],
                                 texture2d<float> blurTexture [[ texture(3) ]],
                                 sampler sampler [[ sampler(0) ]]) {
    
    float u = vertexOut.texCoord[0];
    float v = vertexOut.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 color = texture.sample(sampler, uv);
    float4 backgroundColor = backgroundTexture.sample(sampler, uv);
    float4 blurColor = blurTexture.sample(sampler, uv);
    
    return float4(0.0);
}

fragment float4 transparencyMapBlur(VertexOut vertexOut [[stage_in]],
                                    texture2d<float> texture [[ texture(0) ]],
                                    texture2d<float> backgroundTexture [[ texture(1) ]],
                                    texture2d<float> mapTexture [[ texture(2) ]],
                                    texture2d<float> blurTexture [[ texture(3) ]],
                                    sampler sampler [[ sampler(0) ]]) {
    
    float u = vertexOut.texCoord[0];
    float v = vertexOut.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 color = texture.sample(sampler, uv);
    float4 backgroundColor = backgroundTexture.sample(sampler, uv);
    float4 mapColor = mapTexture.sample(sampler, uv);
    float4 blurColor = blurTexture.sample(sampler, uv);

    return float4(0.0);
}

fragment float4 transparency(VertexOut vertexOut [[stage_in]],
                             texture2d<float> texture [[ texture(0) ]],
                             texture2d<float> backgroundTexture [[ texture(1) ]],
                             sampler sampler [[ sampler(0) ]]) {
    
    float u = vertexOut.texCoord[0];
    float v = vertexOut.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 color = texture.sample(sampler, uv);
    float4 backgroundColor = backgroundTexture.sample(sampler, uv);

    return float4(0.0);
}

