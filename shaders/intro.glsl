extern vec2 resolution;
extern number time;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = screen_coords / resolution;
    
    // Create a smooth gradient background
    vec3 gradientStart = vec3(0.1, 0.1, 0.2); // Dark blue-gray
    vec3 gradientEnd = vec3(0.2, 0.2, 0.3);   // Slightly lighter
    vec3 bgColor = mix(gradientStart, gradientEnd, uv.y);
    
    // Add a subtle scanning effect
    float scanLine = abs(sin(uv.y * 50.0 - time * 10.0)) * 0.05;
    vec3 scanColor = bgColor + vec3(scanLine);

    return vec4(scanColor, 1.0);
}
