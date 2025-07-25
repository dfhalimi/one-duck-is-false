shader_type spatial;
render_mode blend_mix, cull_back, depth_draw_opaque;

uniform vec4 color1 : source_color = vec4(0.2, 0.4, 0.1, 1.0);
uniform vec4 color2 : source_color = vec4(0.3, 0.5, 0.2, 1.0);
uniform float scale = 10.0;

void fragment() {
    vec2 uv = UV * scale;
    float n = fract(sin(dot(floor(uv), vec2(12.9898,78.233))) * 43758.5453);
    vec4 final_color = mix(color1, color2, n);
    ALBEDO = final_color.rgb;
	ROUGHNESS = 1.0; // 1 = matte, 0 = shiny
}
