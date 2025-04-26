shader_type spatial;
render_mode skip_vertex_transform, cull_disabled;  // Removed ambient_light_disabled

//Albedo texture
uniform sampler2D albedoTex : source_color;
uniform bool paletteswap = false;
//Geometric resolution for vert snap
uniform float snapRes = 50.0;

//vec4 for UV recalculation
varying vec4 vertCoord;

void vertex() {
    // Get model-view position
    vec4 snap_position = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);

    // Snap the position
    snap_position.xyz = floor(snap_position.xyz * snapRes) / snapRes;

    // Use the standard projection matrix to get clip space
    POSITION = PROJECTION_MATRIX * snap_position;

    // Save vertex position for correct uv calculation
    vertCoord = vec4(UV * snap_position.z, snap_position.z, 0.0);

    // Set VERTEX for correct lighting calculations
    VERTEX = snap_position.xyz;

    // Transform normal properly for lighting
    NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
    // Set albedo texture
    vec4 albedo_tex = texture(albedoTex, vertCoord.xy / vertCoord.z);
    ALBEDO = albedo_tex.rgb;

    // Allow proper specular/metallic workflow
    ROUGHNESS = 1.0;

    // Allow lighting to be calculated properly
    // If you had transparent textures you'd want to set ALPHA here too
}
