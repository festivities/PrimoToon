#include "Genshin-Main_inputs.hlsli"


/* Properties */

Texture2D _DiffuseTex;              SamplerState sampler_DiffuseTex;
Texture2D _LightmapTex;             SamplerState sampler_LightmapTex;
Texture2D _FaceShadowTex;           SamplerState sampler_FaceShadowTex;
Texture2D _ShadowRampTex;           SamplerState sampler_ShadowRampTex;

UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

float _EnvironmentLightingStrength;
vector<float, 4> _headForwardVector;
vector<float, 4> _headRightVector;
float _flipFaceLighting;
float _MaterialID;
float _DayOrNight;
float _ToggleTonemapper;
float _RimLightType;
float _RimLightIntensity;
float _RimLightThickness;

float _FaceBlushStrength;
vector<float, 4> _FaceBlushColor;

float _LightArea;
float _UseShadowRampTex;

float _ReturnVertexColors;
float _ReturnVertexColorAlpha;
float _ReturnRimLight;
float _ReturnTangents;
float _ReturnForwardVector;
float _ReturnRightVector;

/* end of properties */


// vertex
vsOut vert(vsIn v){
    vsOut o;
    o.position = UnityObjectToClipPos(v.vertex);
    o.vertexWS = mul(UNITY_MATRIX_M, vector<float, 4>(v.vertex, 1.0)).xyz; // TransformObjectToWorld
    o.tangent = v.tangent;
    o.uv.xy = v.uv0;
    o.normal = v.normal;
    o.screenPos = ComputeScreenPos(o.position);
    o.vertexcol = v.vertexcol;

    UNITY_TRANSFER_FOG(o, o.position);

    return o;
}

#include "Genshin-Helpers.hlsl"

// fragment
vector<fixed, 4> frag(vsOut i) : SV_Target{
    // sample textures to objects
    vector<fixed, 4> lightmap = _LightmapTex.Sample(sampler_LightmapTex, i.uv.xy);
    vector<fixed, 4> lightmap_mirrored = _LightmapTex.Sample(sampler_LightmapTex, vector<half, 2>(1 - i.uv.x, i.uv.y));
    vector<fixed, 4> diffuse = _DiffuseTex.Sample(sampler_DiffuseTex, i.uv.xy);


    /* FACE CALCULATION */

    // get light direction
    vector<half, 4> lightDir = getlightDir();

    // get head directions
    vector<half, 3> headForward = normalize(UnityObjectToWorldDir(_headForwardVector.xyz));
    vector<half, 3> headRight = normalize(UnityObjectToWorldDir(_headRightVector.xyz));

    // get dot products of each head direction and the lightDir
    half FdotL = dot(normalize(lightDir.xz), headForward.xz);
    half RdotL = dot(normalize(lightDir.xz), headRight.xz);

    // remap both dot products from { -1, 1 } to { 0, 1 } and invert
    RdotL = (_flipFaceLighting != 0) ? RdotL * 0.5 + 0.5 : 1 - (RdotL * 0.5 + 0.5);
    FdotL = 1 - (FdotL * 0.5 + 0.5);

    // get direction of lightmap based on RdotL being above 0.5 or below
    vector<fixed, 4> lightmapDir = (RdotL <= 0.5) ? lightmap_mirrored : lightmap;
    
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


    /* SHADOW RAMP CREATION */

    vector<half, 2> ShadowRampDayUVs = vector<float, 2>(faceFactor, (((6 - _MaterialID) - 1) * 0.1) + 0.05);
    vector<fixed, 4> ShadowRampDay = _ShadowRampTex.Sample(sampler_ShadowRampTex, ShadowRampDayUVs);

    vector<half, 2> ShadowRampNightUVs = vector<float, 2>(faceFactor, (((6 - _MaterialID) - 1) * 0.1) + 0.05 + 0.5);
    vector<fixed, 4> ShadowRampNight = _ShadowRampTex.Sample(sampler_ShadowRampTex, ShadowRampNightUVs);

    vector<fixed, 4> ShadowRampFinal = lerp(ShadowRampNight, ShadowRampDay, _DayOrNight);

    // make lit areas 1
    ShadowRampFinal = lerp(ShadowRampFinal, 1, faceFactor);

    /* END OF SHADOW RAMP CREATION */


    /* RIM LIGHT CREATION */

    // basically view-space normals, except we cannot use the normal map so get mesh's raw normals
    vector<half, 3> rimNormals = UnityObjectToWorldNormal(i.normal);
    rimNormals = mul(UNITY_MATRIX_V, rimNormals);

    // https://github.com/TwoTailsGames/Unity-Built-in-Shaders/blob/master/CGIncludes/UnityDeferredLibrary.cginc#L152
    vector<half, 2> screenPos = i.screenPos.xy / i.screenPos.w;

    // sample depth texture and get it in linear form untouched
    half linearDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenPos);
    linearDepth = LinearEyeDepth(linearDepth);

    // now we modify screenPos to offset another sampled depth texture
    screenPos = screenPos + (rimNormals.x * (0.002 + ((_RimLightThickness - 1) * 0.001)));
    screenPos = screenPos + rimNormals.y * 0.001;

    // sample depth texture again to another object with modified screenPos
    half rimDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenPos);
    rimDepth = LinearEyeDepth(rimDepth);

    // now compare the two
    half depthDiff = rimDepth - linearDepth;

    // finally, le rim light :)
    half rimLight = saturate(smoothstep(0, 1, depthDiff));
    // creative freedom from here on
    rimLight *= saturate(lerp(1, 0, linearDepth - 8));
    rimLight = rimLight * max(faceFactor * 0.2, 0.05) * _RimLightIntensity;

    /* END OF RIM LIGHT */


    /* ENVIRONMENT LIGHTING */

    // get the color of whichever's greater between the light direction and the strongest nearby point light
    vector<fixed, 4> environmentLighting = max(_LightColor0, unity_LightColor[0]);
    // now get whichever's greater than the result of the first and the nearest light probe
    vector<half, 3> ShadeSH9Alternative = vector<half, 3>(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w) + 
                                          vector<half, 3>(unity_SHBr.z, unity_SHBg.z, unity_SHBb.z) / 3.0;
    //environmentLighting = max(environmentLighting, vector<fixed, 4>(ShadeSH9(vector<half, 4>(0, 0, 0, 1)), 1));
    environmentLighting = max(environmentLighting, vector<fixed, 4>(ShadeSH9Alternative, 1));

    /* END OF ENVIRONMENT LIGHTING */


    /* DEBUGGING */

    if(_ReturnVertexColors != 0){ return vector<fixed, 4>(i.vertexcol.xyz, 1); }
    if(_ReturnVertexColorAlpha != 0){ return (vector<fixed, 4>)i.vertexcol.a; }
    if(_ReturnRimLight != 0){ return (vector<fixed, 4>)rimLight; }
    if(_ReturnTangents != 0){ return i.tangent; }
    if(_ReturnForwardVector != 0){ return vector<fixed, 4>(headForward.xyz, 1); }
    if(_ReturnRightVector != 0){ return vector<fixed, 4>(headRight.xyz, 1); }

    /* END OF DEBUGGING */


    /* COLOR CREATION */

    // apply diffuse ramp
    vector<fixed, 4> finalColor = vector<fixed, 4>(diffuse.xyz, 1) * ShadowRampFinal;

    // apply face blush
    finalColor *= lerp(1, lerp(1, _FaceBlushColor, diffuse.w), _FaceBlushStrength);

    // apply environment lighting
    finalColor *= lerp(1, environmentLighting, _EnvironmentLightingStrength);

    // apply rim light
    finalColor = (_RimLightType != 0) ? ColorDodge(rimLight, finalColor) : finalColor + rimLight;

    // apply enhancement tonemapper, i know this is wrong application shut up
    finalColor = (_ToggleTonemapper != 0) ? GTTonemap(finalColor) : finalColor;

    // apply fog
    UNITY_APPLY_FOG(i.fogCoord, finalColor);

    return finalColor;

    /* END OF COLOR CREATION */
}
