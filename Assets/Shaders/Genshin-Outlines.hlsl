#include "Genshin-Main_inputs.hlsli"


/* Properties */

Texture2D _LightmapTex;             SamplerState sampler_LightmapTex;

float _ToggleFaceShader;
float _EnvironmentLightingStrength;
float _UseMaterial2;
float _UseMaterial3;
float _UseMaterial4;
float _UseMaterial5;
float _UseTangents;

float _OutlineWidth;
vector<float, 4> _OutlineColor;
vector<float, 4> _OutlineColor2;
vector<float, 4> _OutlineColor3;
vector<float, 4> _OutlineColor4;
vector<float, 4> _OutlineColor5;
float _ZOffset;

/* end of properties */


// vertex
vsOut vert(vsIn v){
    vsOut o;
    o.position = UnityObjectToClipPos(v.vertex);
    o.vertexWS = mul(UNITY_MATRIX_M, vector<float, 4>(v.vertex, 1.0)).xyz; // TransformObjectToWorld
    o.uv.xy = v.uv0;
    o.uv.zw = v.uv1;

    // first, form the base outline thickness with vertexcol.w
    vector<float, 3> calcOutline = v.vertexcol.w * (_OutlineWidth * 0.1);
    // get distance between camera and each vertex, ensure thickness does not go below base outline thickness
    float distOutline = max(distance(_WorldSpaceCameraPos, o.vertexWS), 1);
    // clamp distOutline so it doesn't go wild at very far distances
    distOutline = min(distOutline, 10);
    // multiply outline thickness by distOutline to have constant-width outlines
    calcOutline = calcOutline * distOutline;

    // get direction of how the hull will expand - will eventually use tangents soon
    calcOutline *= v.normal;

    // get camera view direction
    vector<half, 3> viewDir = normalize(_WorldSpaceCameraPos - o.vertexWS);

    // optimize outlines for exposed faces so they don't artifact by offsetting in the Z-axis
    calcOutline = calcOutline - mul(unity_WorldToObject, viewDir) * v.vertexcol.z * 0.0015 * _ZOffset;
    // offset vertices
    calcOutline += v.vertex;

    // finally, convert calcOutlines to clip space
    o.position = UnityObjectToClipPos(calcOutline);

    UNITY_TRANSFER_FOG(o, o.position);

    o.TtoW0 = distOutline; // placeholder for debugging distance

    return o;
}

// fragment
vector<fixed, 4> frag(vsOut i, bool frontFacing : SV_IsFrontFace) : SV_Target{
    // if frontFacing == 1, use uv.xy, else uv.zw
    vector<half, 2> newUVs = (frontFacing) ? i.uv.xy : i.uv.zw;

    // sample textures to objects
    vector<fixed, 4> lightmap = _LightmapTex.Sample(sampler_LightmapTex, vector<half, 2>(i.uv.xy));


    /* MATERIAL IDS */

    fixed idMasks = lightmap.w;

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


    /* ENVIRONMENT LIGHTING */

    // get all the point light positions
    vector<half, 3> firstPointLightPos = { unity_4LightPosX0.x, unity_4LightPosY0.x, unity_4LightPosZ0.x };
    vector<half, 3> secondPointLightPos = { unity_4LightPosX0.y, unity_4LightPosY0.y, unity_4LightPosZ0.y };
    vector<half, 3> thirdPointLightPos = { unity_4LightPosX0.z, unity_4LightPosY0.z, unity_4LightPosZ0.z };
    vector<half, 3> fourthPointLightPos = { unity_4LightPosX0.w, unity_4LightPosY0.w, unity_4LightPosZ0.w };

    // get all the point light attenuations
    half firstPointLightAtten = 2 * rsqrt(unity_4LightAtten0.x);
    half secondPointLightAtten = 2 * rsqrt(unity_4LightAtten0.y);
    half thirdPointLightAtten = 2 * rsqrt(unity_4LightAtten0.z);
    half fourthPointLightAtten = 2 * rsqrt(unity_4LightAtten0.w);

    // first, get the distance between each vertex and all of the point light positions,
    // then invert the result and apply attenuation, saturate to prevent my guy from glowing
    // lastly, multiply it to the corresponding light's color
    vector<half, 3> firstPointLight = saturate(lerp(1, 0, distance(i.vertexWS, firstPointLightPos) - 
                                      firstPointLightAtten)) * unity_LightColor[0];
    vector<half, 3> secondPointLight = saturate(lerp(1, 0, distance(i.vertexWS, secondPointLightPos) - 
                                       secondPointLightAtten)) * unity_LightColor[1];
    vector<half, 3> thirdPointLight = saturate(lerp(1, 0, distance(i.vertexWS, thirdPointLightPos) - 
                                      thirdPointLightAtten)) * unity_LightColor[2];
    vector<half, 3> fourthPointLight = saturate(lerp(1, 0, distance(i.vertexWS, thirdPointLightPos) - 
                                       fourthPointLightAtten)) * unity_LightColor[3];

    // THIS COULD USE SOME IMPROVEMENTS, I DON'T KNOW HOW TO DISABLE THIS FOR SPOT LIGHTS
    // compare with all of the other point lights
    vector<half, 3> pointLightCalc = firstPointLight;
    pointLightCalc = max(pointLightCalc, secondPointLight);
    pointLightCalc = max(pointLightCalc, thirdPointLight);
    pointLightCalc = max(pointLightCalc, thirdPointLight);

    // get the color of whichever's greater between the light direction and the strongest nearby point light
    vector<fixed, 4> environmentLighting = max(_LightColor0, vector<fixed, 4>(pointLightCalc, 1));
    // now get whichever's greater than the result of the first and the nearest light probe
    vector<half, 3> ShadeSH9Alternative = vector<half, 3>(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w) + 
                                          vector<half, 3>(unity_SHBr.z, unity_SHBg.z, unity_SHBb.z) / 3.0;
    //environmentLighting = max(environmentLighting, vector<fixed, 4>(ShadeSH9(vector<half, 4>(0, 0, 0, 1)), 1));
    environmentLighting = max(environmentLighting, vector<fixed, 4>(ShadeSH9Alternative, 1));
    // ensure environmentLighting does not make outlines greater than 1
    environmentLighting = min(1, environmentLighting);

    /* END OF ENVIRONMENT LIGHTING */


    /* COLOR CREATION */

    // form outline colors
    vector<fixed, 4> globalOutlineColor = _OutlineColor;
    if(_ToggleFaceShader == 0){
        if(materialID == 2){
            globalOutlineColor = _OutlineColor2;
        }
        else if(materialID == 3){
            globalOutlineColor = _OutlineColor3;
        }
        else if(materialID == 4){
            globalOutlineColor = _OutlineColor4;
        }
        else if(materialID == 5){
            globalOutlineColor = _OutlineColor5;
        }
    }

    // apply environment lighting
    globalOutlineColor *= lerp(1, environmentLighting, _EnvironmentLightingStrength);

    // apply fog
    UNITY_APPLY_FOG(i.fogCoord, globalOutlineColor);

    return globalOutlineColor;

    /* END OF COLOR CREATION */
}
