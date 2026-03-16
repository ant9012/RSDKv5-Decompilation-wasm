// Force WebGL to use Desktop OpenGL 32-bit precision
#ifdef GL_ES
precision highp float;
#endif

// =======================
// VARIABLES
// =======================
in_F vec2 ex_UV;
in_F vec4 ex_color;

uniform sampler2D texDiffuse; // screen display texture

uniform vec2 pixelSize;   // internal game resolution 
uniform vec2 textureSize; // size of the internal framebuffer texture
uniform vec2 viewSize;    // window viewport size

#if RETRO_REV02  
uniform float screenDim;  // screen dimming percent
#endif

// =======================
// DEFINITIONS
// =======================
#define viewSizeHD  720.0                   
#define brightness  1.25                    

// NOTE: The 'intencity' vec3 was removed here to prevent the red WebGL banding!

void main()
{
    vec2 texelPos = (textureSize.xy / pixelSize.xy) * ex_UV.xy;
    vec4 size     = (pixelSize.xy / textureSize.xy).xyxy * texelPos.xyxy;
    vec2 exp      = size.zw * textureSize.xy - floor(size.zw * textureSize.xy) - 0.5;

    vec4 factor  = pow(vec4(2.0), pow(vec4(-1.0, 1.0, -2.0, 2.0) - exp.x, vec4(2.0)) * -3.0);
    float  factor2 = pow(2.0, pow(exp.x, 2.0) * -3.0); 

    vec3 power;
    power.x = pow(2.0, pow(exp.y, 2.0) * -8.0);
    power.y = pow(2.0, pow(-1.0 - exp.y, 2.0) * -8.0);
    power.z = pow(2.0, pow(1.0 - exp.y, 2.0) * -8.0);

    vec3 color1  = texture2D(texDiffuse, (floor(size.zw * textureSize.xy   + vec2( 1.0, -1.0))   + 0.5)      / textureSize.xy).rgb * factor.y * brightness;
    vec3 color2  = texture2D(texDiffuse, (floor(size.zw * textureSize.xy   + vec2(-2.0, 0.0))    + 0.5)      / textureSize.xy).rgb * factor.z * brightness;
    vec3 color3  = texture2D(texDiffuse, (floor(size.zw * textureSize.xy   + vec2(-1.0, 0.0))    + 0.5)      / textureSize.xy).rgb * factor.x * brightness;
    vec3 color4  = texture2D(texDiffuse, (floor(size.zw * textureSize.xy   + vec2( 1.0, 0.0))    + 0.5)      / textureSize.xy).rgb * factor.y * brightness;
    vec3 color5  = texture2D(texDiffuse, (floor(size.zw * textureSize.xy   + 0.0)                + 0.5)      / textureSize.xy).rgb * factor2  * brightness;
    vec3 color6  = texture2D(texDiffuse, (floor(size.zw * textureSize.xy   + vec2(-1.0, 1.0))    + 0.5)      / textureSize.xy).rgb * factor.x * brightness;
    vec3 color7  = texture2D(texDiffuse, (floor(size.zw * textureSize.xy   + vec2(2.0, 0.0))     + 0.5)      / textureSize.xy).rgb * factor.w * brightness;
    vec3 color8  = texture2D(texDiffuse, (floor(size.zw * textureSize.xy   + -1.0)               + 0.5)      / textureSize.xy).rgb * factor.x * brightness;
    vec3 color9  = texture2D(texDiffuse, (floor(size.zw * textureSize.xy   + vec2(0.0, -1.0))    + 0.5)      / textureSize.xy).rgb * factor2  * brightness;
    vec3 color10 = texture2D(texDiffuse, (floor(size.zw * textureSize.xy   + 1.0)                + 0.5)      / textureSize.xy).rgb * factor.y * brightness;
    vec3 color11 = texture2D(texDiffuse, (floor(size.xy * textureSize.xy   + vec2(0.0, 1.0))     + 0.5)      / textureSize.xy).rgb * factor2  * brightness;

    vec3 final = 
        (color2 + color3 + color4 + color5 + color7) / (factor.z + factor.x + factor.y + factor2 + factor.w) * power.x +
        (color1 + color8 + color9)                   / (factor.y + factor.x + factor2)                       * power.y +
        (color10 + color6 + color11)                 / (factor.y + factor.x + factor2)                       * power.z;

    // THE FIX: We stripped out the scanlineIntencity RGB mask entirely. 
    // The `power` vectors naturally handle the CRT scanlines without drawing red bands!
    gl_FragColor.rgb = final.rgb;
	
#if RETRO_REV02 
	gl_FragColor.rgb *= screenDim;
#endif
}