extern vec2 resolution;
extern float time;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec2 uv = screen_coords / resolution;

    // Create a subtle moving gradient with fewer light levels
    float gradient = uv.y * 0.5 + 0.3 + 0.03 * sin(time * 0.2 + uv.x * 2.0);

    // Generate softer noise
    float noise = fract(sin(dot(uv * vec2(10.9898, 70.233), vec2(33.89, 30.67))) * 43758.5453);
    noise = smoothstep(0.4, 0.6, noise);  // Reduce the intensity of the noise

    // Mix gradient and noise with a lower noise influence
    float subtleNoise = mix(gradient, noise, 0.05);

    // Add slight movement to the background
    uv.x += sin(time * 0.1) * 0.01;
    uv.y += cos(time * 0.1) * 0.01;

    return vec4(subtleNoise * 0.8, subtleNoise * 0.8, subtleNoise * 1.0, 1.0);
}
