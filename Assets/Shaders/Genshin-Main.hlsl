// vertex
vsOut vert(vsIn v){
    vsOut o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.vertexWS = mul(UNITY_MATRIX_M, v.vertex); // TransformObjectToWorld
    o.vertexOS = v.vertex;
    o.tangent = v.tangent;
    o.uv.xy = v.uv0;
    o.uv.zw = v.uv1;
    o.normal = v.normal;
    o.screenPos = ComputeScreenPos(o.pos);
    o.vertexcol = v.vertexcol;

    UNITY_TRANSFER_FOG(o, o.pos);

    return o;
}

// fragment
vector<fixed, 4> frag(vsOut i, bool frontFacing : SV_IsFrontFace) : SV_Target{
    // if frontFacing == 1 or _UseBackFaceUV2 == 0, use uv.xy, else uv.zw
    vector<half, 2> newUVs = (frontFacing || !_UseBackFaceUV2) ? i.uv.xy : i.uv.zw;

    // sample textures to objects
    vector<fixed, 4> lightmap = _LightmapTex.Sample(sampler_LightmapTex, newUVs);
    vector<fixed, 4> diffuse = _DiffuseTex.Sample(sampler_DiffuseTex, newUVs);
    

    /* NORMAL CREATION */

    vector<half, 3> normalCreationBuffer;

    vector<fixed, 4> modifiedNormalMap;
    modifiedNormalMap.xyz = _NormalTex.Sample(sampler_NormalTex, newUVs).xyz;
    normalCreationBuffer.xy = modifiedNormalMap.xy * 2 - 1;
    normalCreationBuffer.z = max(1 - min(_BumpScale, 0.95), 0.001);
    modifiedNormalMap.xyw = normalCreationBuffer * rsqrt(dot(normalCreationBuffer, normalCreationBuffer));

    /* because miHoYo stores outline directions in the tangents of the mesh,
    // they cannot be used for normal and bump mapping. because of this, we can just recalculate
    // for them with ddx() and ddy(), don't ask me how they work - I don't know as well kekw */ 
    vector<half, 3> dpdx = ddx(i.vertexWS);
    vector<half, 3> dpdy = ddy(i.vertexWS);
    vector<half, 3> dhdx; dhdx.xy = ddx(newUVs);
    vector<half, 3> dhdy; dhdy.xy = ddy(newUVs);

    // modify normals
    dhdy.z = dhdx.y; dhdx.z = dhdy.x;
    normalCreationBuffer = dot(dhdx.xz, dhdy.yz);
    vector<half, 3> recalcTangent = -(0 < normalCreationBuffer) + (normalCreationBuffer < 0);
    dhdx.xy = vector<half, 2>(recalcTangent.xy) * dhdy.yz;
    dpdy *= -dhdx.y;
    dpdx = dpdx * dhdx.x + dpdy;
    normalCreationBuffer = rsqrt(dot(dpdx, dpdx));
    dpdx *= normalCreationBuffer;
    normalCreationBuffer = (frontFacing != 0) ? UnityObjectToWorldNormal(i.normal) : 
                                                -UnityObjectToWorldNormal(i.normal);
    dpdy = normalCreationBuffer.zxy * dpdx.yzx;
    dpdy = normalCreationBuffer.yzx * dpdx.zxy - dpdy.xyz;
    dpdy *= -recalcTangent;
    dpdy *= modifiedNormalMap.y;
    dpdx = modifiedNormalMap.x * dpdx + dpdy;
    modifiedNormalMap.xyw = modifiedNormalMap.www * normalCreationBuffer + dpdx;
    recalcTangent = rsqrt(dot(modifiedNormalMap.xyw, modifiedNormalMap.xyw));
    modifiedNormalMap.xyw *= recalcTangent;
    normalCreationBuffer = (0.99 >= modifiedNormalMap.w) ? modifiedNormalMap.xyw : normalCreationBuffer;

    // hope you understood any of that KEKW, finally switch between normal map and raw normals
    vector<half, 3> rawNormals = (frontFacing != 0) ? UnityObjectToWorldNormal(i.normal) : 
                                                      -UnityObjectToWorldNormal(i.normal);
    vector<half, 3> modifiedNormals = (_UseBumpMap != 0) ? normalCreationBuffer : rawNormals;

    /* END OF NORMAL CREATION */


    /* DOT CREATION */

    // NdotL
    half NdotL = dot(modifiedNormals, normalize(getlightDir()));
    // remap from { -1, 1 } to { 0, 1 }
    NdotL = NdotL * 0.5 + 0.5;

    // NdotV
    vector<half, 3> viewDir = normalize(_WorldSpaceCameraPos.xyz - i.vertexWS);
    half NdotV = dot(modifiedNormals, viewDir);
    NdotV = NdotV * 0.5 + 0.5;

    // NdotH, for some reason they don't remap ranges for the specular
    vector<half, 3> halfVector = normalize(viewDir + _WorldSpaceLightPos0);
    half NdotH = dot(modifiedNormals, halfVector);

    /* END OF DOT CREATION */


    /* MATERIAL IDS */

    half idMasks = lightmap.w;

    half materialID = 1;
    if(idMasks >= 0.2 && idMasks <= 0.4 && _UseMaterial4 != 0){
        materialID = 4;
    } 
    else if(idMasks >= 0.4 && idMasks <= 0.6 && _UseMaterial3 != 0){
        materialID = 3;
    }
    else if(idMasks >= 0.6 && idMasks <= 0.8 && _UseMaterial5 != 0){
        materialID = 5;
    }
    else if(idMasks >= 0.8 && idMasks <= 1.0 && _UseMaterial2 != 0){
        materialID = 2;
    }

    /* END OF MATERIAL IDS */


    /* SHADOW RAMP CREATION */

    vector<fixed, 4> ShadowFinal;
    half NdotL_Factor;

    // create ambient occlusion from lightmap.g
    half occlusion = ((_UseLightMapColorAO != 0) ? lightmap.g : 0.5) * ((_UseVertexColorAO != 0) ? i.vertexcol.r : 1.0);

    // switch between the shadow ramp and custom shadow colors
    if(_UseShadowRamp != 0){
        // calculate shadow ramp width from _ShadowRampWidth and i.vertexcol.g
        half ShadowRampWidthCalc = i.vertexcol.g * 2.0 * _ShadowRampWidth;

        // apply occlusion
        occlusion = smoothstep(0.01, 0.4, occlusion);
        NdotL = lerp(0, NdotL, saturate(occlusion));
        // NdotL_buf will be used as a sharp factor
        half NdotL_buf = NdotL;
        NdotL_Factor = NdotL_buf < _LightArea;

        // add options for controlling shadow ramp width and shadow push
        NdotL = 1 - ((((_LightArea - NdotL) / _LightArea) / ShadowRampWidthCalc));

        vector<half, 2> ShadowRampDayUVs = vector<float, 2>(NdotL, (((6 - materialID) - 1) * 0.1) + 0.05);
        vector<fixed, 4> ShadowRampDay = _ShadowRampTex.Sample(sampler_ShadowRampTex, ShadowRampDayUVs);

        vector<half, 2> ShadowRampNightUVs = vector<float, 2>(NdotL, (((6 - materialID) - 1) * 0.1) + 0.05 + 0.5);
        vector<fixed, 4> ShadowRampNight = _ShadowRampTex.Sample(sampler_ShadowRampTex, ShadowRampNightUVs);

        ShadowFinal = lerp(ShadowRampNight, ShadowRampDay, _DayOrNight);

        // switch between 1 and ramp edge like how the game does it, also make eyes always lit
        ShadowFinal = (NdotL_Factor && lightmap.g < 0.95) ? ShadowFinal : 1;
    }
    else{
        // apply occlusion
        NdotL = (NdotL + occlusion) * 0.5;
        NdotL = (occlusion > 0.95) ? 1.0 : NdotL;
        NdotL = (occlusion < 0.05) ? 0.0 : NdotL;

        // combine all the _ShadowTransitionRange, _ShadowTransitionSoftness, _CoolShadowMultColor and
        // _FirstShadowMultColor parameters into one object
        half globalShadowTransitionRange = _ShadowTransitionRange;
        half globalShadowTransitionSoftness = _ShadowTransitionSoftness;
        vector<fixed, 4> globalCoolShadowMultColor = _CoolShadowMultColor;
        vector<fixed, 4> globalFirstShadowMultColor = _FirstShadowMultColor;

        if(NdotL < _LightArea){
            if(materialID == 2){
                globalShadowTransitionRange = _ShadowTransitionRange2;
                globalShadowTransitionSoftness = _ShadowTransitionSoftness2;
                globalCoolShadowMultColor = _CoolShadowMultColor2;
                globalFirstShadowMultColor = _FirstShadowMultColor2;
            }
            else if(materialID == 3){
                globalShadowTransitionRange = _ShadowTransitionRange3;
                globalShadowTransitionSoftness = _ShadowTransitionSoftness3;
                globalCoolShadowMultColor = _CoolShadowMultColor3;
                globalFirstShadowMultColor = _FirstShadowMultColor3;
            }
            else if(materialID == 4){
                globalShadowTransitionRange = _ShadowTransitionRange4;
                globalShadowTransitionSoftness = _ShadowTransitionSoftness4;
                globalCoolShadowMultColor = _CoolShadowMultColor4;
                globalFirstShadowMultColor = _FirstShadowMultColor4;
            }
            else if(materialID == 5){
                globalShadowTransitionRange = _ShadowTransitionRange5;
                globalShadowTransitionSoftness = _ShadowTransitionSoftness5;
                globalCoolShadowMultColor = _CoolShadowMultColor5;
                globalFirstShadowMultColor = _FirstShadowMultColor5;
            }

            // apply params, form the final light direction
            half buffer1 = NdotL < _LightArea;
            NdotL = -NdotL + _LightArea;
            NdotL /= globalShadowTransitionRange;
            half buffer2 = NdotL >= 1.0;
            NdotL += 0.01;
            NdotL = log2(NdotL);
            NdotL *= globalShadowTransitionSoftness;
            NdotL = exp2(NdotL);
            NdotL = min(NdotL, 1.0);
            NdotL = (buffer2) ? 1.0 : NdotL;
            NdotL = (buffer1) ? NdotL : 1.0;
        }
        else{
            NdotL = 0.0;
        }

        // final NdotL will also be NdotL_Factor
        NdotL_Factor = NdotL;

        // apply color
        vector<fixed, 4> ShadowDay = NdotL * globalFirstShadowMultColor;
        vector<fixed, 4> ShadowNight = NdotL * globalCoolShadowMultColor;

        ShadowFinal = lerp(ShadowDay, ShadowNight, _DayOrNight);

        // switch between 1 and ramp edge like how the game does it, also make eyes always lit
        ShadowFinal = lerp(1, ShadowFinal, NdotL_Factor);
    }

    /* END OF SHADOW RAMP CREATION */


    /* METALLIC */

    // create metal factor to be used later
    half metalFactor = (lightmap.r > 0.9) * _MetalMaterial;

    // multiply world space normals with view matrix
    vector<half, 3> viewNormal = mul(UNITY_MATRIX_V, modifiedNormals);
    // https://github.com/poiyomi/PoiyomiToonShader/blob/master/_PoiyomiShaders/Shaders/8.0/Poiyomi.shader#L8397
    // this part (all 5 lines) i literally do not understand but it fixes the skewing that occurs when the camera 
    // views the mesh at the edge of the screen (PLEASE LET ME GO BACK TO BLENDER)
    vector<half, 3> matcapUV_Detail = viewNormal.xyz * vector<half, 3>(-1, -1, 1);
    vector<half, 3> matcapUV_Base = (mul(UNITY_MATRIX_V, vector<half, 4>(viewDir, 0)).rgb 
                                    * vector<half, 3>(-1, -1, 1)) + vector<half, 3>(0, 0, 1);
    vector<half, 3> matcapUVs = matcapUV_Base * dot(matcapUV_Base, matcapUV_Detail) 
                                / matcapUV_Base.z - matcapUV_Detail;

    // offset UVs to middle and apply _MTMapTileScale
    matcapUVs = vector<half, 3>(matcapUVs.x * _MTMapTileScale, matcapUVs.y, 0) * 0.5 + vector<half, 3>(0.5, 0.5, 0);

    // sample matcap texture with newly created UVs
    vector<fixed, 4> metal = _MetalMapTex.Sample(sampler_MetalMapTex, matcapUVs);
    // prevent metallic matcap from glowing
    metal = saturate(metal * _MTMapBrightness);
    metal = lerp(_MTMapDarkColor, _MTMapLightColor, metal);

    // apply _MTShadowMultiColor ONLY to shaded areas
    metal = (NdotL_Factor) ? metal * _MTShadowMultiColor : metal;

    /* END OF METALLIC */


    /* METALLIC SPECULAR */
    
    vector<half, 4> metalSpecular = NdotH;
    metalSpecular = saturate(pow(metalSpecular, _MTShininess) * _MTSpecularScale);

    // if _MTUseSpecularRamp is set to 1, shrimply use the specular ramp texture
    if(_MTUseSpecularRamp != 0){
        metalSpecular = _SpecularRampTex.Sample(sampler_SpecularRampTex, vector<half, 2>(metalSpecular.x, 0.5));
    }
    else{
        metalSpecular *= lightmap.b;
    }
    
    // apply _MTSpecularColor
    metalSpecular *= _MTSpecularColor;
    // apply _MTSpecularAttenInShadow ONLY to shaded areas
    metalSpecular = saturate((NdotL_Factor) ? metalSpecular * _MTSpecularAttenInShadow : metalSpecular);

    /* END OF METALLIC SPECULAR */


    /* SPECULAR */

    // combine all the _Shininess and _SpecMulti parameters into one object
    half globalShininess = _Shininess;
    half globalSpecMulti = _SpecMulti;
    if(materialID == 2){
        globalShininess = _Shininess2;
        globalSpecMulti = _SpecMulti2;
    }
    else if(materialID == 3){
        globalShininess = _Shininess3;
        globalSpecMulti = _SpecMulti3;
    }
    else if(materialID == 4){
        globalShininess = _Shininess4;
        globalSpecMulti = _SpecMulti4;
    }
    else if(materialID == 5){
        globalShininess = _Shininess5;
        globalSpecMulti = _SpecMulti5;
    }

    vector<half, 4> specular = NdotH;
    // apply _Shininess parameters
    specular = pow(specular, globalShininess);
    // 1.03 may seem arbitrary, but it is shrimply an optimization due to Unity compression, it's supposed to be a 
    // inversion of lightmap.b, also compare specular to inverted lightmap.b
    specular = (1.03 - lightmap.b) < specular;
    specular = saturate(specular * globalSpecMulti * _SpecularColor * lightmap.r);

    /* END OF SPECULAR */


    /* RIM LIGHT CREATION */

    half rimLight = calculateRimLight(i.normal, i.screenPos, _RimLightIntensity, 
                                      _RimLightThickness, 1 - NdotL_Factor);

    /* END OF RIM LIGHT */


    /* ENVIRONMENT LIGHTING */

    vector<fixed, 4> environmentLighting = calculateEnvLighting(i.vertexWS);

    /* END OF ENVIRONMENT LIGHTING */


    /* EMISSION */

    // use diffuse tex alpha channel for emission mask
    fixed emissionFactor = 0;

    vector<fixed, 4> emission = 0;

    // toggle between emission being on or not
    if(_ToggleEmission != 0){
        // again, this may seem arbitrary but it's an optimization because miHoYo likes their textures very crunchy!
        emissionFactor = saturate(diffuse.w - 0.02);

        // toggle between game-like emission or user's own custom emission texture, idk why i used a switch here btw
        switch(_EmissionType){
            case 0:
                emission = _EmissionStrength * vector<fixed, 4>(diffuse.xyz, 1) * _EmissionColor;
                break;
            case 1:
                emission = _EmissionStrength * _EmissionColor * 
                           vector<fixed, 4>(_CustomEmissionTex.Sample(sampler_CustomEmissionTex, newUVs).xyz, 1);
                // apply emission AO
                emission *= vector<fixed, 4>(_CustomEmissionAOTex.Sample(sampler_CustomEmissionAOTex, newUVs).xyz, 1);
                break;
            default:
                break;
        }

        // pulsing emission
        if(_TogglePulse != 0){
            // form the sine wave
            half emissionPulse = sin(_PulseSpeed * _Time.y);
            // remap from ranges { -1, 1 } to { 0, 1 }
            emissionPulse = emissionPulse * 0.5 + 0.5;
            // ensure emissionPulse never goes below or above the minimum and maximum values set by the user
            emissionPulse = mapRange(0, 1, _PulseMinStrength, _PulseMaxStrength, emissionPulse);
            // apply pulse
            emission = lerp((_EmissionType != 0) ? 0 : vector<fixed, 4>(diffuse.xyz, 1) * _EmissionColor, 
                            emission, emissionPulse);
        }
    }
    // eye glow stuff
    if(_ToggleEyeGlow != 0 && lightmap.g > 0.95){
        emissionFactor += 1;
        emission = vector<fixed, 4>(diffuse.xyz, 1) * _EyeGlowStrength;
    }

    /* END OF EMISSION */


    /* DEBUGGING */

    if(_ReturnVertexColors != 0){ return vector<fixed, 4>(i.vertexcol.xyz, 1); }
    if(_ReturnVertexColorAlpha != 0){ return (vector<fixed, 4>)i.vertexcol.a; }
    if(_ReturnRimLight != 0){ return (vector<fixed, 4>)rimLight; }
    if(_ReturnNormals != 0){ return vector<fixed, 4>(modifiedNormals, 1); }
    if(_ReturnRawNormals != 0){ return vector<fixed, 4>(UnityObjectToWorldNormal(i.normal), 1); }
    if(_ReturnTangents != 0){ return i.tangent; }
    if(_ReturnMetal != 0){ return metal; }
    if(_ReturnEmissionFactor != 0){ return emissionFactor; }

    /* END OF DEBUGGING */


    /* COLOR CREATION */

    // apply diffuse ramp
    vector<fixed, 4> finalColor = vector<fixed, 4>(diffuse.xyz, 1) * ShadowFinal;

    // apply metallic only to anything metalFactor encompasses
    finalColor = (metalFactor) ? finalColor * metal : finalColor;

    // add specular to finalColor if metalFactor is evaluated as true, else add metallic specular
    finalColor = (metalFactor) ? finalColor + metalSpecular : finalColor + specular;

    // apply environment lighting
    finalColor *= lerp(1, environmentLighting, _EnvironmentLightingStrength);

    // apply emission
    finalColor = (_EmissionType != 0 && lightmap.g < 0.95) ? finalColor + emission : 
                                                             lerp(finalColor, emission, emissionFactor);

    // apply rim light
    finalColor = (_RimLightType != 0) ? ColorDodge(rimLight, finalColor) : finalColor + rimLight;

    // apply fog
    UNITY_APPLY_FOG(i.fogCoord, finalColor);

    return finalColor;

    /* END OF COLOR CREATION */
}
