precision mediump float;
in_F vec2 ex_UV;
in_F vec4 ex_color;

// Expose the 3 textures so your C++ can actually bind to them!
uniform sampler2D texY;
uniform sampler2D texU;
uniform sampler2D texV;

#if RETRO_REV02  
uniform float screenDim; 
#endif

void main()
{
    // Sample the 3 planes dynamically uploaded by our WebGL C++
    float y = texture2D(texY, ex_UV).r;
    float u = texture2D(texU, ex_UV).r;
    float v = texture2D(texV, ex_UV).r;

    // Apply the official RSDKv5 exact color offsets
    y -= (16.0 / 256.0);
    u -= 0.5;
    v -= 0.5;

    // Convert to RGB
    gl_FragColor.r = 1.164 * y + 1.596 * v;
    gl_FragColor.g = 1.164 * y - 0.392 * u - 0.813 * v;
    gl_FragColor.b = 1.164 * y + 2.017 * u;

#if RETRO_REV02 
    gl_FragColor.rgb *= screenDim;
#endif
}