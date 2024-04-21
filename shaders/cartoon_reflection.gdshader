shader_type canvas_item;

uniform float line_thickness;
uniform float cos_threshold : hint_range(-1.0, 1.0);

uniform vec3 overlay_colour : source_color;

void fragment() {
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = SCREEN_UV*line_thickness;
    
    uv.y += uv.x;
    
    vec3 col = step(cos(uv.yyy), vec3(cos_threshold));

    // Output to screen
    COLOR.rgb = mix(texture(TEXTURE, UV).rgb, overlay_colour, col);
}
