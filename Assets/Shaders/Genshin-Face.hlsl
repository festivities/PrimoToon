// vertex
vsOut vert(vsIn v){
    vsOut o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.vertexWS = mul(UNITY_MATRIX_M, v.vertex); // TransformObjectToWorld
    o.vertexOS = v.vertex;
    o.tangent = v.tangent;
    o.uv.xy = v.uv0;
    o.normal = v.normal;
    o.screenPos = ComputeScreenPos(o.pos);
    o.vertexcol = v.vertexcol;

    UNITY_TRANSFER_FOG(o, o.pos);

    return o;
}

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
    half faceFactor = smoothstep(shadowRange - _FaceMapSoftness, shadowRange + _FaceMapSoftness, lightmapDir);

    // sample Face Shadow texture
    vector<fixed, 4> faceShadow = _FaceShadowTex.Sample(sampler_FaceShadowTex, i.uv.xy);

    // use FdotL once again to lerp between shaded and lit for the mouth area
    faceFactor = faceFactor + faceShadow.w * (1 - FdotL);

    /* END OF FACE CALCULATION */


    /* SHADOW RAMP CREATION */

    vector<fixed, 4> ShadowFinal;

    if(_UseShadowRamp != 0){
        vector<half, 2> ShadowRampDayUVs = vector<float, 2>(faceFactor, (((6 - _MaterialID) - 1) * 0.1) + 0.05);
        vector<fixed, 4> ShadowRampDay = _ShadowRampTex.Sample(sampler_ShadowRampTex, ShadowRampDayUVs);

        vector<half, 2> ShadowRampNightUVs = vector<float, 2>(faceFactor, (((6 - _MaterialID) - 1) * 0.1) + 0.05 + 0.5);
        vector<fixed, 4> ShadowRampNight = _ShadowRampTex.Sample(sampler_ShadowRampTex, ShadowRampNightUVs);

        ShadowFinal = lerp(ShadowRampNight, ShadowRampDay, _DayOrNight);
    }
    else{
        vector<fixed, 4> ShadowDay = _FirstShadowMultColor;
        vector<fixed, 4> ShadowNight = _CoolShadowMultColor;

        ShadowFinal = lerp(ShadowDay, ShadowNight, _DayOrNight);
    }

    // make lit areas 1
    ShadowFinal = lerp(ShadowFinal, 1, faceFactor);

    /* END OF SHADOW RAMP CREATION */


    /* RIM LIGHT CREATION */

    half rimLight = calculateRimLight(i.normal, i.screenPos, _RimLightIntensity, 
                                      _RimLightThickness, faceFactor);

    /* END OF RIM LIGHT */


    /* ENVIRONMENT LIGHTING */

    vector<fixed, 4> environmentLighting = calculateEnvLighting(i.vertexWS);

    /* END OF ENVIRONMENT LIGHTING */


    /* DEBUGGING */

    if(_ReturnVertexColors != 0){ return vector<fixed, 4>(i.vertexcol.xyz, 1); }
    if(_ReturnVertexColorAlpha != 0){ return (vector<fixed, 4>)i.vertexcol.a; }
    if(_ReturnRimLight != 0){ return (vector<fixed, 4>)rimLight; }
    if(_ReturnNormals != 0){ return vector<fixed, 4>(UnityObjectToWorldNormal(i.normal), 1); }
    if(_ReturnTangents != 0){ return i.tangent; }
    if(_ReturnForwardVector != 0){ return vector<fixed, 4>(headForward.xyz, 1); }
    if(_ReturnRightVector != 0){ return vector<fixed, 4>(headRight.xyz, 1); }

    /* END OF DEBUGGING */


    /* COLOR CREATION */

    // apply diffuse ramp
    vector<fixed, 4> finalColor = vector<fixed, 4>(diffuse.xyz, 1) * ShadowFinal;

    // apply face blush
    finalColor *= lerp(1, lerp(1, _FaceBlushColor, diffuse.w), _FaceBlushStrength);

    // apply environment lighting
    finalColor *= lerp(1, environmentLighting, _EnvironmentLightingStrength);

    // apply rim light
    finalColor = (_RimLightType != 0) ? ColorDodge(rimLight, finalColor) : finalColor + rimLight * finalColor;

    // apply fog
    UNITY_APPLY_FOG(i.fogCoord, finalColor);

    return finalColor;

    /* END OF COLOR CREATION */
}
