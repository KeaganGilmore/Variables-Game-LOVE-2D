// shaders/target.glsl
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec2 uv = texture_coords;
    float d = length(uv - vec2(0.5));
    
    vec3 col = vec3(1.0 - smoothstep(0.3, 0.31, d));
    col *= vec3(1.0, 0.5, 0.0);  // Orange color
    
    return vec4(col, 1.0);
}