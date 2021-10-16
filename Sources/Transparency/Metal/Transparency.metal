//
//  Created by Anton Heestand on 2021-09-18.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

float2 getUV(float2 uv, texture2d<float> texture, texture2d<float> backgroundTexture) {
    uint w = texture.get_width();
    uint h = texture.get_height();
    uint bgw = backgroundTexture.get_width();
    uint bgh = backgroundTexture.get_height();
    float up = 0.5 + ((uv.x - 0.5) * float(bgw)) / float(w);
    float vp = 0.5 + ((uv.y - 0.5) * float(bgh)) / float(h);
    float2 uvp = float2(up, vp);
    return uvp;
}

float2 getScale(texture2d<float> texture, texture2d<float> backgroundTexture) {
    uint w = texture.get_width();
    uint h = texture.get_height();
    uint bgw = backgroundTexture.get_width();
    uint bgh = backgroundTexture.get_height();
    float scalex = float(w) / float(bgw);
    float scaley = float(h) / float(bgh);
    return float2(scalex, scaley);
}

float4 blend(float4 color, float4 backgroundColor) {
    return float4(backgroundColor.rgb * (1.0 - color.a) + color.rgb * color.a, max(color.a, backgroundColor.a));
}

fragment float4 transparencyMap(VertexOut vertexOut [[stage_in]],
                                texture2d<float> texture [[ texture(0) ]],
                                texture2d<float> backgroundTexture [[ texture(1) ]],
                                texture2d<float> mapTexture [[ texture(2) ]],
                                sampler sampler [[ sampler(0) ]]) {
    
    float u = vertexOut.texCoord[0];
    float v = vertexOut.texCoord[1];
    float2 uv = float2(u, v);
    float2 uvp = getUV(uv, texture, backgroundTexture);
    float2 scale = getScale(texture, backgroundTexture);

    float4 color = texture.sample(sampler, uvp);
    float4 mapColor = mapTexture.sample(sampler, uv);

    float2 uvmap = uv;
    if (mapColor.a > 0.0) {
        uvmap = float2(mapColor.r, 1.0 - mapColor.g);
        //float2((mapColor.r - 0.5) * scale.x + 0.5, ((1.0 - mapColor.g) - 0.5) * scale.y + 0.5);
    }
    float4 backgroundColor = backgroundTexture.sample(sampler, uvmap);
    
    return backgroundColor; //blend(color, backgroundColor);
}

fragment float4 transparency(VertexOut vertexOut [[stage_in]],
                             texture2d<float> texture [[ texture(0) ]],
                             texture2d<float> backgroundTexture [[ texture(1) ]],
                             sampler sampler [[ sampler(0) ]]) {
    
    float u = vertexOut.texCoord[0];
    float v = vertexOut.texCoord[1];
    float2 uv = float2(u, v);
    float2 uvp = getUV(uv, texture, backgroundTexture);
    
    float4 color = texture.sample(sampler, uvp);
    float4 backgroundColor = backgroundTexture.sample(sampler, uv);

    return blend(color, backgroundColor);
}

