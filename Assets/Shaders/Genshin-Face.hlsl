#include "Genshin-Main_inputs.hlsli"


/* Properties */

Texture2D _DiffuseTex;      SamplerState sampler_DiffuseTex;
Texture2D _LightmapTex;     SamplerState sampler_LightmapTex;
Texture2D _FaceShadowTex;   SamplerState sampler_FaceShadowTex;
Texture2D _DiffuseRampTex;  SamplerState sampler_DiffuseRampTex;

float _UseDiffuseRampTex;
float _MaterialID;
float _LightArea;
float _DayOrNight;

/* end of properties */


// vertex
vsOut vert(vsIn v){
    vsOut o;
    o.position = UnityObjectToClipPos(v.vertex);
    o.vertexWS = mul(UNITY_MATRIX_M, vector<float, 4>(v.vertex, 1.0)).xyz; // TransformObjectToWorld
    o.uv.xy = v.uv0;
    o.normal = v.normal;
    o.vertexcol = v.vertexcol;

    return o;
}

// fragment
vector<fixed, 4> frag(vsOut i) : SV_Target{
    // sample textures to objects
    vector<fixed, 4> lightmap = _LightmapTex.Sample(sampler_LightmapTex, i.uv.xy);
    vector<fixed, 4> lightmap_mirrored = _LightmapTex.Sample(sampler_LightmapTex, vector<half, 2>(1 - i.uv.x, i.uv.y));


    /* FACE CALCULATION */

    // get light direction
    vector<half, 4> lightDir = _WorldSpaceLightPos0;

    // get head directions
    vector<half, 3> headForward = normalize(unity_ObjectToWorld._12_22_32);
    vector<half, 3> headRight = normalize(unity_ObjectToWorld._13_23_33);

    // get dot products of each head direction and the lightDir
    half FdotL = dot(normalize(lightDir.xz), headForward.xz);
    half RdotL = dot(normalize(lightDir.xz), headRight.xz);

    // remap both dot products from { -1, 1 } to { 0, 1 } and invert
    RdotL = 1 - (RdotL * 0.5 + 0.5);
    FdotL = 1 - (FdotL * 0.5 + 0.5);

    // get direction of lightmap based on RdotL being above 0.5 or below
    vector<fixed, 4> lightmapDir = (RdotL >= 0.5) ? lightmap_mirrored : lightmap;
    
    // use FdotL to drive the face SDF, make sure FdotL has a maximum of 0.999 so that it doesn't glitch
    half shadowRange = min(0.999, FdotL);
    shadowRange = pow(shadowRange, pow((2 - (_LightArea + 0.50)), 3));

    // finally drive faceFactor
    half faceFactor = lightmapDir > shadowRange;

    // sample Face Shadow texture
    vector<fixed, 4> faceShadow = _FaceShadowTex.Sample(sampler_FaceShadowTex, i.uv.xy);

    // use FdotL once again to lerp between shaded and lit for the mouth area
    faceFactor = faceFactor + faceShadow.w * (1 - FdotL);

    /* END OF FACE CALCULATION */


    /* RAMP CREATION */

    vector<half, 2> rampDayUVs = vector<float, 2>(faceFactor, (((6 - _MaterialID) - 1) * 0.1) + 0.05);
    vector<fixed, 4> rampDay = _DiffuseRampTex.Sample(sampler_DiffuseRampTex, rampDayUVs);

    vector<half, 2> rampNightUVs = vector<float, 2>(faceFactor, (((6 - _MaterialID) - 1) * 0.1) + 0.05 + 0.5);
    vector<fixed, 4> rampNight = _DiffuseRampTex.Sample(sampler_DiffuseRampTex, rampNightUVs);

    vector<fixed, 4> rampFinal = lerp(rampNight, rampDay, _DayOrNight);

    // make lit areas 1
    rampFinal = lerp(rampFinal, 1, faceFactor);

    /* END OF RAMP CREATION */

    
    /* COLOR CREATION */

    // apply diffuse ramp
    vector<fixed, 4> finalColor = vector<half, 4>(_DiffuseTex.Sample(sampler_DiffuseTex, i.uv.xy).xyz, 1) * rampFinal;

    return finalColor;

    /* END OF COLOR CREATION */
}
