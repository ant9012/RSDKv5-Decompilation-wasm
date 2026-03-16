precision mediump float; 
varying vec2 vTexCoord;
uniform sampler2D texY;
uniform sampler2D texU;
uniform sampler2D texV;

void main() {
    float y = texture2D(texY, vTexCoord).r;
    float u = texture2D(texU, vTexCoord).r - 0.5;
    float v = texture2D(texV, vTexCoord).r - 0.5;

    float r = y + 1.402 * v;
    float g = y - 0.344136 * u - 0.714136 * v;
    float b = y + 1.772 * u;

    gl_FragColor = vec4(r, g, b, 1.0);
}