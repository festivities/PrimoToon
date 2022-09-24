#include "Genshin-Main_inputs.hlsli"


/* Properties */

Texture2D _LightmapTex;             SamplerState sampler_LightmapTex;

UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

float _ToggleFaceShader;
float _EnvironmentLightingStrength;
float _UseMaterial2;
float _UseMaterial3;
float _UseMaterial4;
float _UseMaterial5;
float _UseTangents;

float _OutlineType;
float _OutlineWidth;
vector<float, 4> _OutlineColor;
vector<float, 4> _OutlineColor2;
vector<float, 4> _OutlineColor3;
vector<float, 4> _OutlineColor4;
vector<float, 4> _OutlineColor5;
float _MaxOutlineZOffset;

/* end of properties */


// vertex
vsOut vert(vsIn v){
    vsOut o;
    o.position = UnityObjectToClipPos(v.vertex);
    o.vertexWS = mul(UNITY_MATRIX_M, vector<float, 4>(v.vertex, 1.0)).xyz; // TransformObjectToWorld
    o.uv.xy = v.uv0;
    o.uv.zw = v.uv1;

    if(_OutlineType != 0){
        // first, form the base outline thickness with vertexcol.w
        vector<float, 3> calcOutline = v.vertexcol.w * (_OutlineWidth * 0.1);
        // get distance between camera and each vertex, ensure thickness does not go below base outline thickness
        float distOutline = max(distance(_WorldSpaceCameraPos, o.vertexWS), 1);
        // clamp distOutline so it doesn't go wild at very far distances
        distOutline = min(distOutline, 10);
        // multiply outline thickness by distOutline to have constant-width outlines
        calcOutline = calcOutline * distOutline;

        // switch between outline types
        switch(_OutlineType){
            case 1:
                calcOutline *= v.normal;
                break;
            case 2:
                calcOutline *= v.tangent.xyz;
                break;
            default:
                break;
        }

        // get camera view direction
        vector<half, 3> viewDir = normalize(_WorldSpaceCameraPos - o.vertexWS);

        // optimize outlines for exposed faces so they don't artifact by offsetting in the Z-axis
        calcOutline = calcOutline - mul(unity_WorldToObject, viewDir) * v.vertexcol.z * 0.0015 * _MaxOutlineZOffset;
        // offset vertices
        calcOutline += v.vertex;

        // finally, convert calcOutlines to clip space
        o.position = UnityObjectToClipPos(calcOutline);

        o.TtoW0 = distOutline; // placeholder for debugging distance
    }

    UNITY_TRANSFER_FOG(o, o.position);

    return o;
}

#include "Genshin-Helpers.hlsl"

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

    vector<fixed, 4> environmentLighting = calculateEnvLighting(i.vertexWS);
    
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
