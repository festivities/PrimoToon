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
    o.vertexcol = (_VertexColorLinear != 0.0) ? VertexColorConvertToLinear(v.vertexcol) : v.vertexcol;

    UNITY_TRANSFER_FOG(o, o.pos);

    return o;
}

// fragment
vector<fixed, 4> frag(vsOut i, bool frontFacing : SV_IsFrontFace) : SV_Target{
    // if frontFacing == 1 or _UseBackFaceUV2 == 0, use uv.xy, else uv.zw
    vector<half, 2> newUVs = (frontFacing || !_UseBackFaceUV2) ? i.uv.xy : i.uv.zw;
    // use only uv.xy for face shader
    newUVs = (_UseFaceMapNew != 0) ? i.uv.xy : newUVs;
    const vector<half, 3> viewDir = normalize(_WorldSpaceCameraPos.xyz - i.vertexWS);
    // get light direction
    const vector<half, 4> lightDir = getlightDir();
    const vector<half, 3> rawNormalsWS = (frontFacing != 0) ? UnityObjectToWorldNormal(i.normal) : 
                                                              -UnityObjectToWorldNormal(i.normal);


    /* TEXTURE CREATION */

    // the author's code has the xy and zw elements of _TexelSize swapped so I swizzle them here (?????? wtf)
    vector<fixed, 4> mainTex = SampleTexture2DBicubicFilter(_MainTex, sampler_MainTex, newUVs, _MainTex_TexelSize.zwxy);
    vector<fixed, 4> lightmapTex = SampleTexture2DBicubicFilter(_LightMapTex, sampler_LightMapTex, newUVs, _LightMapTex_TexelSize.zwxy);
    vector<fixed, 4> facemapTex = SampleTexture2DBicubicFilter(_FaceMap, sampler_FaceMap, newUVs, _FaceMap_TexelSize.zwxy);
    vector<fixed, 4> bumpmapTex = SampleTexture2DBicubicFilter(_BumpMap, sampler_BumpMap, newUVs, _BumpMap_TexelSize.zwxy);

    /* END OF TEXTURE CREATION */


    /* BUFFER, IGNORE */

    vector<half, 3> headForward;
    vector<half, 3> headRight;

    vector<half, 3> modifiedNormalsWS = 0.0;
    vector<half, 3> finalNormalsWS = rawNormalsWS;

    half litFactor;
    fixed emissionFactor;
    vector<fixed, 4> metal;

    vector<fixed, 4> finalColor = 1.0;

    /* END OF BUFFER */


    /* ENVIRONMENT LIGHTING */

    vector<fixed, 4> environmentLighting = calculateEnvLighting(i.vertexWS);

    /* END OF ENVIRONMENT LIGHTING */


    if(_UseFaceMapNew != 0){
        /* TEXTURE CREATION */

        vector<fixed, 4> lightmapTex_mirrored = SampleTexture2DBicubicFilter(_LightMapTex, sampler_LightMapTex, vector<half, 2>(1.0 - i.uv.x, i.uv.y), _LightMapTex_TexelSize.zwxy);

        /* END OF TEXTURE CREATION */


        /* FACE CALCULATION */

        // get head directions
        headForward = normalize(UnityObjectToWorldDir(_headForwardVector.xyz));
        headRight = normalize(UnityObjectToWorldDir(_headRightVector.xyz));

        // get dot products of each head direction and the lightDir
        half FdotL = dot(normalize(lightDir.xz), headForward.xz);
        half RdotL = dot(normalize(lightDir.xz), headRight.xz);

        // remap both dot products from { -1, 1 } to { 0, 1 } and invert
        RdotL = (_flipFaceLighting != 0) ? RdotL * 0.5 + 0.5 : 1 - (RdotL * 0.5 + 0.5);
        FdotL = 1 - (FdotL * 0.5 + 0.5);

        // get direction of lightmap based on RdotL being above 0.5 or below
        vector<fixed, 4> lightmapDir = (RdotL <= 0.5) ? lightmapTex_mirrored : lightmapTex;
        
        // use FdotL to drive the face SDF, make sure FdotL has a maximum of 0.999 so that it doesn't glitch
        half shadowRange = min(0.999, FdotL);
        shadowRange = pow(shadowRange, pow((2 - (_LightArea + 0.50)), 3));

        // finally drive faceFactor
        half faceFactor = smoothstep(shadowRange - _FaceMapSoftness, shadowRange + _FaceMapSoftness, lightmapDir);

        // use FdotL once again to lerp between shaded and lit for the mouth area
        faceFactor = faceFactor + facemapTex.w * (1 - FdotL);

        litFactor = 1.0 - faceFactor;

        /* END OF FACE CALCULATION */


        /* SHADOW RAMP CREATION */

        vector<fixed, 4> ShadowFinal;

        if(_UseShadowRamp != 0){
            vector<half, 2> ShadowRampDayUVs = vector<float, 2>(faceFactor, (((6 - _MaterialID) - 1) * 0.1) + 0.05);
            vector<fixed, 4> ShadowRampDay = _PackedShadowRampTex.Sample(sampler_PackedShadowRampTex, ShadowRampDayUVs);

            vector<half, 2> ShadowRampNightUVs = vector<float, 2>(faceFactor, (((6 - _MaterialID) - 1) * 0.1) + 0.05 + 0.5);
            vector<fixed, 4> ShadowRampNight = _PackedShadowRampTex.Sample(sampler_PackedShadowRampTex, ShadowRampNightUVs);

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


        /* COLOR CREATION */

        // apply diffuse ramp
        finalColor.xyz = mainTex.xyz * ShadowFinal.xyz;

        // apply face blush
        finalColor.xyz *= lerp(1, lerp(1, _FaceBlushColor, mainTex.w), _FaceBlushStrength);

        // apply environment lighting
        finalColor.xyz *= lerp(1.0, environmentLighting, _EnvironmentLightingStrength).xyz;

        /* END OF COLOR CREATION */
    }
    else{
        /* NORMAL CREATION */

        vector<half, 3> normalCreationBuffer;

        vector<fixed, 4> modifiedNormalMap;
        modifiedNormalMap.xyz = bumpmapTex.xyz;
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
        normalCreationBuffer = rawNormalsWS;
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
        modifiedNormalsWS = normalCreationBuffer;
        finalNormalsWS = (_UseBumpMap != 0) ? modifiedNormalsWS : finalNormalsWS;

        /* END OF NORMAL CREATION */


        /* TEXTURE LINE */

        // thx to manashiku bestie for helping with this owo

        half fragCoord = i.screenPos.z / i.screenPos.w;
        fragCoord = 1.0 / (_ZBufferParams.z * fragCoord + _ZBufferParams.w);

        half textureLineThickness = _TextureLineDistanceControl.x * fragCoord + _TextureLineThickness;
        textureLineThickness = 1.0 - min(textureLineThickness, min(_TextureLineDistanceControl.y, 0.99000001));

        fragCoord = fragCoord >= _TextureLineDistanceControl.z;

        half textureLineSmoothness = -_TextureLineSmoothness * fragCoord + textureLineThickness;

        fragCoord = _TextureLineSmoothness * fragCoord + textureLineThickness;
        fragCoord -= textureLineSmoothness;

        vector<fixed, 3> textureLine = bumpmapTex.zzz - textureLineSmoothness.xxx;

        fragCoord = 1.0 / fragCoord;

        textureLine *= fragCoord;
        textureLine = saturate(textureLine);
        fragCoord = textureLine * -2.0 + 3.0;
        textureLine *= textureLine;
        textureLine *= fragCoord;

        // kind of unused
        half textureLineFac = (_TextureLineUse != 0.0) ? textureLine.x : 0.0;

        const vector<fixed, 4> MainTexTintColor = 1.0;

        // i'm pretty sure this is literally just 0 but i am following decompiled code ok shut up
        vector<half, 3> textureLineCol = _TextureLineMultiplier.xyz * mainTex.xyz - mainTex.xyz * 
                                         _TextureLineMultiplier.www;
                        
        textureLine = textureLine * textureLineCol + mainTex.xyz;

        // this becomes the new diffuse
        vector<fixed, 4> newDiffuse = vector<fixed, 4>(textureLine, 1.0);

        /* END OF TEXTURE LINE */


        /* DOT CREATION */

        // NdotL
        half NdotL = dot(finalNormalsWS, normalize(lightDir));
        // remap from { -1, 1 } to { 0, 1 }
        NdotL = NdotL * 0.5 + 0.5;

        // NdotH, for some reason they don't remap ranges for the specular
        vector<half, 3> halfVector = normalize(viewDir + _WorldSpaceLightPos0);
        half NdotH = dot(finalNormalsWS, halfVector);

        /* END OF DOT CREATION */


        /* MATERIAL IDS */

        half idMasks = lightmapTex.w;

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
        half NdotL_buf;

        // create ambient occlusion from lightmap.g
        half occlusion = ((_UseLightMapColorAO != 0) ? lightmapTex.g : 0.5) * ((_UseVertexColorAO != 0) ? i.vertexcol.r : 1.0);

        // switch between the shadow ramp and custom shadow colors
        if(_UseShadowRamp != 0){
            // calculate shadow ramp width from _ShadowRampWidth and i.vertexcol.g
            half ShadowRampWidthCalc = i.vertexcol.g * 2.0 * _ShadowRampWidth;

            // apply occlusion
            occlusion = smoothstep(0.01, 0.4, occlusion);
            NdotL = lerp(0, NdotL, saturate(occlusion));
            // NdotL_buf will be used as a sharp factor
            NdotL_buf = NdotL;
            litFactor = NdotL_buf < _LightArea;

            // add options for controlling shadow ramp width and shadow push
            NdotL = 1 - ((((_LightArea - NdotL) / _LightArea) / ShadowRampWidthCalc));
            NdotL_buf = NdotL;

            vector<half, 2> ShadowRampDayUVs = vector<float, 2>(NdotL, (((6 - materialID) - 1) * 0.1) + 0.05);
            vector<fixed, 4> ShadowRampDay = _PackedShadowRampTex.Sample(sampler_PackedShadowRampTex, ShadowRampDayUVs);

            vector<half, 2> ShadowRampNightUVs = vector<float, 2>(NdotL, (((6 - materialID) - 1) * 0.1) + 0.05 + 0.5);
            vector<fixed, 4> ShadowRampNight = _PackedShadowRampTex.Sample(sampler_PackedShadowRampTex, ShadowRampNightUVs);

            ShadowFinal = lerp(ShadowRampNight, ShadowRampDay, _DayOrNight);

            // switch between 1 and ramp edge like how the game does it, also make eyes always lit
            ShadowFinal = (litFactor && lightmapTex.g < 0.95) ? ShadowFinal : 1;
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

            // final NdotL will also be litFactor
            litFactor = NdotL;
            NdotL_buf = 1.0 - NdotL;

            // apply color
            vector<fixed, 4> ShadowDay = NdotL * globalFirstShadowMultColor;
            vector<fixed, 4> ShadowNight = NdotL * globalCoolShadowMultColor;

            ShadowFinal = lerp(ShadowDay, ShadowNight, _DayOrNight);

            // switch between 1 and ramp edge like how the game does it, also make eyes always lit
            ShadowFinal = lerp(1, ShadowFinal, litFactor);
        }

        /* END OF SHADOW RAMP CREATION */


        /* METALLIC */

        // create metal factor to be used later
        half metalFactor = (lightmapTex.r > 0.9) * _MetalMaterial;

        // multiply world space normals with view matrix
        vector<half, 3> viewNormal = mul(UNITY_MATRIX_V, modifiedNormalsWS);
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
        metal = _MTMap.Sample(sampler_MTMap, matcapUVs);
        // prevent metallic matcap from glowing
        metal = saturate(metal * _MTMapBrightness);
        metal = lerp(_MTMapDarkColor, _MTMapLightColor, metal);

        // apply _MTShadowMultiColor ONLY to shaded areas
        metal = lerp(metal * _MTShadowMultiColor, metal, saturate(NdotL_buf));

        /* END OF METALLIC */


        /* METALLIC SPECULAR */
        
        vector<half, 4> metalSpecular = NdotH;
        metalSpecular = saturate(pow(metalSpecular, _MTShininess) * _MTSpecularScale);

        if(_MTSharpLayerOffset < metalSpecular.x){
            metalSpecular = _MTSharpLayerColor;
        }
        else{
            // if _MTUseSpecularRamp is set to 1, shrimply use the specular ramp texture
            if(_MTUseSpecularRamp != 0){
                metalSpecular = _MTSpecularRamp.Sample(sampler_MTSpecularRamp, vector<half, 2>(metalSpecular.x, 0.5));
            }

            // apply _MTSpecularColor
            metalSpecular *= _MTSpecularColor;
            metalSpecular *= lightmapTex.z;
        }

        // apply _MTSpecularAttenInShadow ONLY to shaded areas
        metalSpecular = lerp(metalSpecular * _MTSpecularAttenInShadow, metalSpecular, saturate(NdotL_buf));

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
        // inversion of lightmapTex.b, also compare specular to inverted lightmapTex.b
        specular = (1.03 - lightmapTex.b) < specular;
        specular = saturate(specular * globalSpecMulti * _SpecularColor * lightmapTex.r);

        /* END OF SPECULAR */


        /* EMISSION */

        // use diffuse tex alpha channel for emission mask
        emissionFactor = 0;

        vector<fixed, 4> emission = 0;

        // toggle between emission being on or not
        if(_ToggleEmission != 0){
            // again, this may seem arbitrary but it's an optimization because miHoYo likes their textures very crunchy!
            emissionFactor = saturate(mainTex.w - 0.03);

            // toggle between game-like emission or user's own custom emission texture, idk why i used a switch here btw
            switch(_EmissionType){
                case 0:
                    emission = _EmissionStrength * vector<fixed, 4>(mainTex.xyz, 1) * _EmissionColor;
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
                emission = lerp((_EmissionType != 0) ? 0 : vector<fixed, 4>(mainTex.xyz, 1) * _EmissionColor, 
                                emission, emissionPulse);
            }
        }
        // eye glow stuff
        if(_ToggleEyeGlow != 0 && lightmapTex.g > 0.95){
            emissionFactor += 1;
            emission = vector<fixed, 4>(mainTex.xyz, 1) * _EyeGlowStrength;
        }

        /* END OF EMISSION */


        /* WEAPON */

        vector<fixed, 3> dissolve = 0.0;
        vector<fixed, 3> weaponPattern = 0.0;
        vector<fixed, 3> scanLine = 0.0;
        if(_UseWeapon != 0.0){
            vector<half, 2> weaponUVs = (_ProceduralUVs != 0.0) ? (i.vertexOS.zx + 0.25) * 1.5 : i.uv.zw;

            /* PATTERN */

            vector<half, 2> weaponPatternUVs = _Time * _Pattern_Speed + weaponUVs; // tmp1.xy
            vector<fixed, 4> weaponPatternTex = SampleTexture2DBicubicFilter(_WeaponPatternTex, sampler_WeaponPatternTex, weaponPatternUVs, _WeaponPatternTex_TexelSize.zwxy);
            half buf = weaponPatternTex;
            weaponPatternTex = sin(((_WeaponDissolveValue - 0.25) * 6.28));
            weaponPatternTex += 1.0;
            buf *= weaponPatternTex.x;

            weaponPattern = buf * _WeaponPatternColor;

            //return vector<fixed, 4>(buf.xxx, 1.0);

            /* END OF PATTERN */


            /* SCAN LINE */

            half buf2 = 1.0 - weaponUVs.y;
            buf = (_ScanDirection_Switch != 0.0) ? buf2 : weaponUVs.y;
            half buf4 = _ScanSpeed * _Time.y;
            half buf3 = buf * 0.5 + buf4;
            vector<fixed, 4> scanTex = _ScanPatternTex.Sample(sampler_ScanPatternTex, vector<half, 2>(weaponUVs.x, buf3));

            scanLine = scanTex.xyz * _ScanColorScaler * _ScanColor.xyz;


            /* END OF SCAN LINE */


            /* DISSOLVE */

            calculateDissolve(dissolve, weaponUVs, weaponPatternTex.x);

            /*buf = dissolveTex < 0.99;

            dissolveTex.x -= 0.001;
            dissolveTex.x = dissolveTex.x < 0.0;
            dissolveTex.x = (buf) ? dissolveTex.x : 0.0;*/

            // apply dissolve
            clip(dissolve.x - _ClipAlphaThreshold);

            /* END OF DISSOLVE */
        }

        /* END OF WEAPON */


        /* CUTOUT TRANSPARENCY */

        if(_ToggleCutout != 0.0) clip(mainTex.w - 0.03 - _TransparencyCutoff);

        /* END OF CUTOUT TRANSPARENCY */


        /* COLOR CREATION */

        vector<fixed, 3> finalDiffuse = ((_TextureLineUse != 0 && _UseBumpMap != 0) ? newDiffuse.xyz : mainTex.xyz);

        // apply diffuse ramp, apply ramp to metallic part only if metallics is disabled bc metal has its own shadow color
        finalColor.xyz = (metalFactor) ? finalDiffuse : finalDiffuse * ShadowFinal.xyz;

        // apply metallic only to anything metalFactor encompasses
        finalColor.xyz = (metalFactor) ? finalColor.xyz * metal.xyz : finalColor.xyz;

        // add specular to finalColor if metalFactor is evaluated as true, else add metallic specular
        finalColor.xyz = (metalFactor) ? finalColor + metalSpecular.xyz : finalColor.xyz + specular.xyz;

        // apply environment lighting
        finalColor.xyz *= lerp(1, environmentLighting, _EnvironmentLightingStrength).xyz;

        // apply emission
        finalColor.xyz = (_EmissionType != 0 && lightmapTex.g < 0.95) ? finalColor.xyz + emission.xyz : 
                                                                        lerp(finalColor, emission, emissionFactor).xyz;

        if(_UseWeapon != 0.0){
            // apply pattern
            finalColor.xyz += max((_UsePattern != 0.0) ? weaponPattern : 0.0, pow(dissolve.y, 2.0) * _WeaponPatternColor * 2);

            // apply scan line
            finalColor.xyz += scanLine;
        }

        /* END OF COLOR CREATION */
    }


    /* FRESNEL CREATION */

    /*----------------------------------------------------/
    u_xlat42 = dot(u_xlat1.xyz, u_xlat1.xyz);
    u_xlat42 = inversesqrt(u_xlat42);
    u_xlat2.xzw = vec3(u_xlat42) * u_xlat1.xyz;  
    u_xlat42 = dot(u_xlat5.xyz, u_xlat2.xzw);
    u_xlat42 = clamp(u_xlat42, 0.0, 1.0);
    u_xlat42 = (-u_xlat42) + 1.0;
    u_xlat42 = max(u_xlat42, 9.99999975e-05);
    u_xlat42 = log2(u_xlat42);
    u_xlat42 = u_xlat42 * _HitColorFresnelPower;
    u_xlat42 = exp2(u_xlat42);
    /----------------------------------------------------*/
    vector<half, 3> fresnel = rsqrt(dot(finalNormalsWS, finalNormalsWS));
    fresnel *= finalNormalsWS;

    // NdotV
    half NdotV = 1.0 - saturate(dot(fresnel, viewDir));
    NdotV = max(NdotV, 9.99999975e-05);
    NdotV = pow(NdotV, _HitColorFresnelPower);

    /*----------------------------------------------------/
    u_xlat2.xzw = max(_ElementRimColor.xyz, _HitColor.xyz);
    u_xlat2.xzw = vec3(u_xlat42) * u_xlat2.xzw;
    u_xlat0.xyz = u_xlat2.xzw * vec3(vec3(_HitColorScaler, _HitColorScaler, _HitColorScaler)) + u_xlat0.xyz;
    
    for now, idk what u_xlat0 could be
    /----------------------------------------------------*/
    //fresnel = max(_ElementRimColor.xyz, _HitColor.xyz) * NdotV.xxx * _HitColorScaler;
    fresnel = _HitColor.xyz * NdotV.xxx * _HitColorScaler;

    /* END OF FRESNEL */


    /* RIM LIGHT CREATION */

    half rimLight = calculateRimLight(i.normal, i.screenPos, _RimLightIntensity, 
                                      _RimLightThickness, 1.0 - litFactor);

    // rim light mustn't appear in backfaces
    rimLight *= frontFacing;

    /* END OF RIM LIGHT */

    
    /* COLOR CREATION */

    // apply fresnel
    finalColor.xyz += (_UseFresnel != 0.0) ? fresnel : 0.0;

    // apply rim light
    finalColor.xyz = (_RimLightType != 0) ? ColorDodge(rimLight, finalColor.xyz) : finalColor.xyz + rimLight;

    // apply fog
    UNITY_APPLY_FOG(i.fogCoord, finalColor);

    /* END OF COLOR CREATION */


    /* DEBUGGING */

    if(_ReturnDiffuseRGB != 0){ return vector<fixed, 4>(mainTex.xyz, 1.0); }
    if(_ReturnDiffuseA != 0){ return vector<fixed, 4>(mainTex.www, 1.0); }
    if(_ReturnLightmapR != 0){ return vector<fixed, 4>(lightmapTex.xxx, 1.0); }
    if(_ReturnLightmapG != 0){ return vector<fixed, 4>(lightmapTex.yyy, 1.0); }
    if(_ReturnLightmapB != 0){ return vector<fixed, 4>(lightmapTex.zzz, 1.0); }
    if(_ReturnLightmapA != 0){ return vector<fixed, 4>(lightmapTex.www, 1.0); }
    if(_ReturnNormalMap != 0){ return vector<fixed, 4>(bumpmapTex.xyz, 1.0); }
    if(_ReturnTextureLineMap != 0){ return vector<fixed, 4>(bumpmapTex.zzz, 1.0); }
    if(_ReturnVertexColorR != 0){ return vector<fixed, 4>(i.vertexcol.xxx, 1.0); }
    if(_ReturnVertexColorG != 0){ return vector<fixed, 4>(i.vertexcol.yyy, 1.0); }
    if(_ReturnVertexColorB != 0){ return vector<fixed, 4>(i.vertexcol.zzz, 1.0); }
    if(_ReturnVertexColorA != 0){ return vector<fixed, 4>(i.vertexcol.www, 1.0); }
    if(_ReturnRimLight != 0){ return vector<fixed, 4>(rimLight.xxx, 1.0); }
    if(_ReturnNormals != 0){ return vector<fixed, 4>(modifiedNormalsWS, 1.0); }
    if(_ReturnRawNormals != 0){ return vector<fixed, 4>(rawNormalsWS, 1.0); }
    if(_ReturnTangents != 0){ return i.tangent; }
    if(_ReturnMetal != 0){ return metal; }
    if(_ReturnEmissionFactor != 0){ return emissionFactor; }
    if(_ReturnForwardVector != 0){ return vector<fixed, 4>(headForward, 1.0); }
    if(_ReturnRightVector != 0){ return vector<fixed, 4>(headRight, 1.0); }

    /* END OF DEBUGGING */

    return finalColor;
}
