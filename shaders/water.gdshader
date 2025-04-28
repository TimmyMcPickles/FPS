shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform sampler2D DEPTH_TEXTURE: hint_depth_texture;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_nearest_mipmap, repeat_enable;
uniform ivec2 albedo_texture_size;
uniform float point_size : hint_range(0.1, 128.0, 0.1);

uniform float roughness : hint_range(0.0, 1.0);
uniform sampler2D texture_metallic : hint_default_white, filter_nearest_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_nearest_mipmap, repeat_enable;

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

// Low-poly water parameters
uniform float amount: hint_range(0.2, 5.0, 0.1) = 0.8;
uniform float speed: hint_range(0.1, 5.0, 0.1) = 1;
uniform float beer_factor = 0.2;
uniform vec3 emission = vec3(0.0, 0.0, 0.0);
uniform vec2 texture_scale = vec2(1.0, 1.0);

float generateOffset(float x, float z, float val1, float val2, float time) {
    float radiansX = ((mod(x + z * x * val1, amount) / amount) + (time * speed) * mod(x * 0.8 + z, 1.5)) * 2.0 * 3.14;
    float radiansZ = ((mod(val2 * (z * x + x * z), amount) / amount) + (time * speed) * 2.0 * mod(x, 2.0)) * 2.0 * 3.14;

    return amount * 0.5 * (sin(radiansZ) * cos(radiansX));
}

vec3 applyDistortion(vec3 vertex, float time) {
    float xd = generateOffset(vertex.x, vertex.z, 0.2, 0.1, time);
    float yd = generateOffset(vertex.x, vertex.z, 0.1, 0.3, time);
    float zd = generateOffset(vertex.x, vertex.z, 0.15, 0.2, time);

    return vertex + vec3(xd, yd, zd);
}

void vertex() {
    // Apply original UV transformation
    UV = UV * uv1_scale.xy + uv1_offset.xy;

    // Apply low-poly water vertex distortion
    VERTEX = applyDistortion(VERTEX, TIME * 0.1);
}

void fragment() {
    // Calculate normal from vertex derivatives (low-poly style)
    NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));

    vec2 base_uv = UV;

    // Sample albedo texture with original code
    vec4 albedo_tex = texture(texture_albedo, base_uv);
    ALBEDO = albedo.rgb * albedo_tex.rgb;

    // Apply metallic, specular and roughness from original shader
    float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
    METALLIC = metallic_tex * metallic;
    SPECULAR = specular;

    vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
    float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
    ROUGHNESS = roughness_tex * roughness;

    // Apply emission from low-poly shader
    EMISSION = emission;

    // Handle alpha and beer factor transparency from low-poly shader
    if (beer_factor != 0.0) {
        float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
        depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
        depth = depth + VERTEX.z;
        depth = exp(-depth * beer_factor);
        ALPHA = clamp(1.0 - depth, 0.0, 1.0) * albedo.a * albedo_tex.a;
    } else {
        ALPHA = albedo.a * albedo_tex.a;
    }
}
