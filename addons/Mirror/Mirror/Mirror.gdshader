shader_type spatial;
render_mode blend_mix,cull_back,unshaded;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D surface_texture : hint_albedo;
uniform float surface_strength : hint_range(0, 30);

void vertex() {
	UV = vec2(1.0) - UV;
}

void fragment() {
	// map shader offset to -1 1 region
	float distortionOffset = (texture(surface_texture, UV).r - 0.5) * 2.0;
	vec2 base_uv = UV + distortionOffset * surface_strength / VIEWPORT_SIZE;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	//Force srgb
	albedo_tex.rgb = mix(pow((albedo_tex.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),albedo_tex.rgb.rgb * (1.0 / 12.92),lessThan(albedo_tex.rgb,vec3(0.04045)));
	ALBEDO = albedo.rgb * albedo_tex.rgb;
}
