// shaders/glow.glsl
#define NUM_LIGHTS 3

extern vec2 lights[NUM_LIGHTS];
extern vec4 lightColors[NUM_LIGHTS];

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 pixel = Texel(tex, texture_coords);
    
    vec4 glow = vec4(0.0);
    for (int i = 0; i < NUM_LIGHTS; i++) {
        float distance = length(screen_coords - lights[i]);
        glow += lightColors[i] / (distance * distance + 100.0);
    }
    
    return pixel + glow * 0.5;
}