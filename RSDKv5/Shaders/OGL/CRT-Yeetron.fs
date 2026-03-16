#ifdef GL_ES
precision highp float;
#endif

// =======================
// VARIABLES
// =======================
in_F vec2 ex_UV;
in_F vec4 ex_color;

uniform sampler2D texDiffuse;
uniform vec2 pixelSize;
uniform vec2 textureSize;
uniform vec2 viewSize;

#if RETRO_REV02
uniform float screenDim;
#endif

#define RSDK_PI     3.14159
#define viewSizeHD  720.0

void main()
{
    vec2 pixelPos         = ex_UV.xy * textureSize.xy;
    vec2 roundedPixelPos  = floor(pixelPos.xy);

    // Calculate the scanline darkness wave
    float scanlineWeight = clamp(abs(sin(pixelPos.y * RSDK_PI)) + 0.25, 0.5, 1.0);
    pixelPos.xy          = fract(pixelPos.xy) + vec2(-0.5, -0.5);

    vec2 invTexPos = -ex_UV.xy * textureSize.xy + (roundedPixelPos + vec2(0.5, 0.5));
    vec2 newTexPos;
    newTexPos.x = clamp(-abs(invTexPos.x * 0.5) + 1.5, 0.8, 1.25);
    newTexPos.y = clamp(-abs(invTexPos.y * 2.0) + 1.25, 0.5, 1.0);

    scanlineWeight *= newTexPos.x;

    vec2 texPos   = ((pixelPos.xy + -clamp(pixelPos.xy, vec2(-0.25, -0.25), vec2(0.25, 0.25))) * 2.0 + roundedPixelPos + 0.5) / textureSize.xy;
    vec4 texColor = texture2D(texDiffuse, texPos.xy);

    vec3 blendedColor;
    
    // THE FIX: Apply the exact same scanline weight to Red, Green, and Blue uniformly.
    // This completely prevents the Red channel from separating and creating red lines!
    blendedColor.rgb = texColor.rgb * scanlineWeight;

    gl_FragColor.rgb = blendedColor.rgb;

#if RETRO_REV02 
	gl_FragColor.rgb *= screenDim;
#endif
}