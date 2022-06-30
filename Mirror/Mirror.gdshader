shader_type spatial;
render_mode blend_mix,cull_back,unshaded;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;

void vertex() {
	UV = vec2(1.0) - UV;
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	//Force srgb
	albedo_tex.rgb = mix(pow((albedo_tex.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),albedo_tex.rgb.rgb * (1.0 / 12.92),lessThan(albedo_tex.rgb,vec3(0.04045)));
	ALBEDO = albedo.rgb * albedo_tex.rgb;
}
