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

float _ClipPlaneWorld;
float _MaxOutlineZOffset;
float _OutlineType; // cb0[13]
float _OutlineWidth; // cb0[39].w or cb0[15].x
float _Scale; // cb0[17].z
float _UseClipPlane;
vector<float, 4> _ClipPlane; // cb0[26]
vector<float, 4> _OutlineColor;
vector<float, 4> _OutlineColor2;
vector<float, 4> _OutlineColor3;
vector<float, 4> _OutlineColor4;
vector<float, 4> _OutlineColor5;
vector<float, 4> _OutlineWidthAdjustScales; // cb0[20]
vector<float, 4> _OutlineWidthAdjustZs; // cb0[19]

/* end of properties */


// vertex
vsOut vert(vsIn v){
    vsOut o;
    o.position = UnityObjectToClipPos(v.vertex);
    o.vertexWS = mul(UNITY_MATRIX_M, v.vertex); // TransformObjectToWorld, v0
    o.uv.xy = v.uv0;
    o.uv.zw = v.uv1;


    /* game-accurate 
    const float OutlineCorrectionWidth = 2.25; // cb0[39].w or cb0[15].x
    const vector<float, 4> posInput = v.vertex;
    const vector<float, 3> normalInput = v.normal;*/

    /*cb3[0] unity_ObjectToWorld[0]
    #define cb3[1] unity_ObjectToWorld[1]
    #define cb3[2] unity_ObjectToWorld[2]
    #define cb3[3] unity_ObjectToWorld[3]
    
    #define cb3[5] unity_WorldToObject[1]
    #define cb3[4] unity_WorldToObject[0]
    #define cb3[6] unity_WorldToObject[2]
    #define cb3[7] unity_WorldToObject[3]

    #define cb4[9] UNITY_MATRIX_V[0]
    #define cb4[10] UNITY_MATRIX_V[1]
    #define cb4[11] UNITY_MATRIX_V[2]
    #define cb4[12] UNITY_MATRIX_V[3]

    #define cb0[26] _ClipPlane
    #define cb0[17].x _MaxOutlineZOffset
    #define cb0[13].x _OutlineType
    #define cb0[39].w _OutlineWidth
    #define cb0[15].x OutlineCorrectionWidth
    #define cb0[20] _OutlineWidthAdjustScales
    #define cb0[19] _OutlineWidthAdjustZs
    #define cb0[17].z _Scale

    #define cb1[5].xyz _WorldSpaceCameraPos.xyz)

    #define v0 posInput
    #define v1 v.vertexcol
    #define v2 normalInput
    #define v3 v.tangent*/

    /*vector<float, 4> r0, r1, r2, r3, r4; 
    r0.x = _OutlineType == 0.000000;
    if (r0.x != 0) {
        o.position = vector<float, 4>(0, 0, 0, 0);
    }
    if (r0.x == 0) {
        r0.xy = vector<float, 2>(0,0) != vector<float, 2>(_UseClipPlane, _ClipPlaneWorld);
        r0.z = abs(_ClipPlane.w) < 0.00100000005;
        r1.xyz = _ClipPlane.xyz * _ClipPlane.www;
        r1.xyz = r0.zzz ? vector<float, 3>(0, 0, 0) : r1.xyz; // line 71
        r2.xyzw = unity_WorldToObject[1].xyzw * r1.yyyy;
        r2.xyzw = unity_WorldToObject[0].xyzw * r1.xxxx + r2.xyzw;
        r1.xyzw = unity_WorldToObject[2].xyzw * r1.zzzz + r2.xyzw; // line 74
        r1.xyzw = unity_WorldToObject[3].xyzw + r1.xyzw;
        r1.xyz = r1.xyz / r1.www;
        r2.xyz = unity_WorldToObject[1].xyz * _ClipPlane.yyy;
        r2.xyz = unity_WorldToObject[0].xyz * _ClipPlane.xxx + r2.xyz;
        r2.xyz = unity_WorldToObject[2].xyz * _ClipPlane.zzz + r2.xyz; // line 79
        r0.z = dot(r1.xyz, r2.xyz);
        r0.w = dot(posInput.xyz, r2.xyz);
        r1.x = r0.w < r0.z;
        r0.z = r0.w + -r0.z;
        r2.xyz = -r0.zzz * r2.xyz + posInput.xyz;
        r2.w = 0;
        r3.xyz = posInput.xyz;
        r3.w = 1;
        r1.xyzw = r1.xxxx ? r2.xyzw : r3.xyzw;
        r0.z = dot(posInput.xyz, _ClipPlane.xyz); // line 89
        r0.w = -0.00999999978 + _ClipPlane.w;
        r0.w = r0.z < r0.w;
        r0.z = -_ClipPlane.w + r0.z;
        r2.xyz = -r0.zzz * _ClipPlane.xyz + posInput.xyz;
        r2.w = 0;
        r2.xyzw = r0.wwww ? r2.xyzw : r3.xyzw;
        r1.xyzw = r0.yyyy ? r1.xyzw : r2.xyzw;
        r0.xyzw = r0.xxxx ? r1.xyzw : r3.xyzw;
        r1.xyw = unity_ObjectToWorld[3].xyz + -_WorldSpaceCameraPos.xyz; // line 98
        r2.x = unity_ObjectToWorld[0].x;
        r2.y = unity_ObjectToWorld[1].x; // line 100
        r2.z = unity_ObjectToWorld[2].x;
        r2.w = r1.x;
        r3.xyz = r0.xyz;
        r3.w = posInput.w;
        r2.x = dot(r2.xyzw, r3.xyzw); // line 105
        r4.x = unity_ObjectToWorld[0].y;
        r4.y = unity_ObjectToWorld[1].y;
        r4.z = unity_ObjectToWorld[2].y;
        r4.w = r1.y;
        r2.y = dot(r4.xyzw, r3.xyzw); // line 110
        r1.x = unity_ObjectToWorld[0].z;
        r1.y = unity_ObjectToWorld[1].z;
        r1.z = unity_ObjectToWorld[2].z;
        r2.z = dot(r1.xyzw, r3.xyzw);
        r1.x = unity_ObjectToWorld[0].w; // line 115
        r1.y = unity_ObjectToWorld[1].w;
        r1.z = unity_ObjectToWorld[2].w;
        r1.w = unity_ObjectToWorld[3].w;
        r2.w = dot(r1.xyzw, r3.xyzw);
        r0.x = UNITY_MATRIX_V[0].x; // line 120
        r0.y = UNITY_MATRIX_V[1].x;
        r0.z = UNITY_MATRIX_V[2].x;
        r0.x = dot(r0.xyz, r2.xyz);
        r1.x = UNITY_MATRIX_V[0].y;
        r1.y = UNITY_MATRIX_V[1].y; // line 125
        r1.z = UNITY_MATRIX_V[2].y;
        r0.y = dot(r1.xyz, r2.xyz);
        r1.x = UNITY_MATRIX_V[0].z;
        r1.y = UNITY_MATRIX_V[1].z;
        r1.z = UNITY_MATRIX_V[2].z;
        r0.z = dot(r1.xyz, r2.xyz);
        r1.x = UNITY_MATRIX_V[0].w;
        r1.y = UNITY_MATRIX_V[1].w;
        r1.z = UNITY_MATRIX_V[2].w;
        r1.w = UNITY_MATRIX_V[3].w; // line 135
        r1.x = dot(r1.xyzw, r2.xyzw);
        r1.y = _OutlineType == 1.000000;
        r1.yzw = r1.yyy ? normalInput : v.tangent.xyz;
        r2.xyz = unity_ObjectToWorld[1].xyz * r1.zzz;
        r2.xyz = unity_ObjectToWorld[0].xyz * r1.yyy + r2.xyz;
        r1.yzw = unity_ObjectToWorld[2].xyz * r1.www + r2.xyz;
        r2.xy = UNITY_MATRIX_V[1].xy * r1.zz; // line 142
        r1.yz = UNITY_MATRIX_V[0].xy * r1.yy + r2.xy;
        r2.xy = UNITY_MATRIX_V[2].xy * r1.ww + r1.yz;
        r2.z = 0.00999999978; // line 145
        r1.y = dot(r2.xyz, r2.xyz);
        r1.y = rsqrt(r1.y);
        r1.yz = r2.xy * r1.yy;
        r1.w = 2.41400003 / glstate_matrix_projection[1].y;
        r2.x = r1.w * -r0.z;
        r2.x = r2.x < _OutlineWidthAdjustZs.y;
        r3.xy = r2.xx ? _OutlineWidthAdjustZs.xy : _OutlineWidthAdjustZs.yz;
        r3.zw = r2.xx ? _OutlineWidthAdjustScales.xy : _OutlineWidthAdjustScales.yz;
        r1.w = -r0.z * r1.w + -r3.x;
        r2.xy = r3.yw + -r3.xz;
        r2.x = max(0.00100000005, r2.x);
        r1.w = saturate(r1.w / r2.x);
        r1.w = r1.w * r2.y + r3.z;
        r2.x = _OutlineWidth * OutlineCorrectionWidth;
        r1.w = r2.x * r1.w;
        r1.w = 100 * r1.w;
        r1.w = _Scale * r1.w;
        r1.w = 0.414250195 * r1.w; // line 165
        r1.w = v.vertexcol.w * r1.w;
        r2.x = dot(r0.xyz, r0.xyz);
        r2.x = rsqrt(r2.x);
        r2.xyz = r2.xxx * r0.xyz;
        r2.xyz = (vector<float, 3>)_MaxOutlineZOffset * r2.xyz; // line 170
        r2.xyz = (vector<float, 3>)_Scale * r2.xyz;
        r2.w = -0.5 + v.vertexcol.z;
        r0.xyz = r2.xyz * r2.www + r0.xyz;
        r0.xy = r1.yz * r1.ww + r0.xy;
        r2.xyzw = UNITY_MATRIX_P[1].xyzw * r0.yyyy; // line 174
        r2.xyzw = UNITY_MATRIX_P[0].xyzw * r0.xxxx + r2.xyzw;
        r2.xyzw = UNITY_MATRIX_P[2].xyzw * r0.zzzz + r2.xyzw;
        r1.xyzw = UNITY_MATRIX_P[3].xyzw * r1.xxxx + r2.xyzw;
        r0.x = 0 != cb0[30].y;
        r2.xz = float2(0.5,0.5) * r1.xw;
        r0.y = cb1[6].x * r1.y;
        r2.w = 0.5 * r0.y;
        r0.yz = r2.xw + r2.zz;

        o.position = UnityObjectToClipPos(r1);
    }*/


    // easier to understand version
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
    else{
        o.position = vector<float, 4>(0, 0, 0, 0);
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
