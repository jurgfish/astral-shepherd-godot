// NOTE: Shader automatically converted from Godot Engine 4.7.2.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D texture_albedo: source_color, filter_nearest, repeat_disable;
uniform sampler2D texture_emission: source_color, filter_nearest, repeat_disable;

void fragment() {
	vec3 albedo_tex = texture(texture_albedo, UV).rgb;
	vec3 emission_tex = texture(texture_emission, UV).rgb;

	ALBEDO = albedo_tex;
	EMISSION = albedo_tex * emission_tex;
	METALLIC = 0.0;
	ROUGHNESS = 0.5;
}
