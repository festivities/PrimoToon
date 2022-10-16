Shader ".festivity/PrimoToon/genshin-face"{
    Properties{
        [Header(Textures)] [MainTex] [NoScaleOffset] [HDR] [Space(10)] _DiffuseTex ("Diffuse", 2D) = "white"{}
        [NoScaleOffset] _LightmapTex ("Lightmap", 2D) = "white"{}
        [NoScaleOffset] _FaceShadowTex ("Face Shadow", 2D) = "white"{}
        [NoScaleOffset] [HDR] _ShadowRampTex ("Shadow Ramp", 2D) = "white"{}

        [Header(Miscellaneous and Lighting Options)] [Space(10)] _EnvironmentLightingStrength ("Environment Lighting Strength", Range(0.0, 1.0)) = 1.0
        [Toggle] [HideInInspector] _ToggleFaceShader ("Use Face Shader?", Range(0.0, 1.0)) = 1.0
        _headForwardVector ("Forward Vector, ignore the last element", Vector) = (0, 1, 0, 0)
        _headRightVector ("Right Vector, ignore the last element", Vector) = (0, 0, -1, 0)
        [Toggle] _flipFaceLighting ("Flip Face Lighting?", Range(0.0, 1.0)) = 0.0
        [IntRange] _MaterialID ("Material ID", Range(1.0, 5.0)) = 2.0
        _DayOrNight ("Nighttime?", Range(0.0, 1.0)) = 0.0
        [Toggle] _FallbackOutlines ("Fallback Outlines?", Range(0.0, 1.0)) = 0.0
        [KeywordEnum(Add, Color Dodge)] _RimLightType ("Rim Light Blend Mode", Float) = 0.0
        _RimLightIntensity ("Rim Light Intensity", Float) = 1.0
        _RimLightThickness ("Rim Light Thickness", Range(0.0, 10.0)) = 1.0

        [Header(Face Blush)] [Space(10)] _FaceBlushStrength ("Face Blush Strength", Range(0.0, 1.0)) = 0.0
        [Gamma] _FaceBlushColor ("Face Blush Color", Color) = (1.0, 0.8, 0.7, 1.0)

        [Header(Diffuse or Lighting Options)] [Space(10)] _FaceMapSoftness ("Face Lighting Softness", Range(0.0, 1.0)) = 0.001
        _LightArea ("Shadow Position", Range(0.0, 2.0)) = 0.55
        [Toggle] _UseShadowRamp ("Use Shadow Ramp Texture?", Float) = 1.0
        [Gamma] _CoolShadowMultColor ("Nighttime Shadow Color", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _FirstShadowMultColor ("Daytime Shadow Color", Color) = (0.9, 0.7, 0.75, 1)

        [Header(Outline Options)] [Space(10)] _MaxOutlineZOffset ("Z-Offset", Float) = 1.0
        [Toggle] [HideInInspector] _ClipPlaneWorld ("Clip Plane World", Range(0.0, 1.0)) = 1.0
        [KeywordEnum(None, Normal, Tangent)] _OutlineType ("Outline Type", Float) = 1.0
        _OutlineWidth ("Outline Width", Float) = 0.03
        _Scale ("Outline Scale", Float) = 0.01
        [Toggle] [HideInInspector] _UseClipPlane ("Use Clip Plane?", Range(0.0, 1.0)) = 0.0
        [HideInInspector] _ClipPlane ("Clip Plane", Vector) = (0.0, 0.0, 0.0, 0.0)
        [Gamma] _OutlineColor ("Outline Color 1", Color) = (0.0, 0.0, 0.0, 1.0)
        _OutlineWidthAdjustScales ("Outline Width Adjust Scales", Vector) = (0.01, 0.245, 0.6, 0.0)
        _OutlineWidthAdjustZs ("Outline Width Adjust Zs", Vector) = (0.001, 2.0, 6.0, 0.0)

        [Header(Debugging)] [Space(10)] [Toggle] _ReturnVertexColors ("Show Vertex Colors (RGB only)", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnVertexColorAlpha ("Show Vertex Color Alpha", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnRimLight ("Show Rim Light", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnNormals ("Show Normals", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnTangents ("Show Tangents", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnForwardVector ("Show Forward Vector (it should look blue)", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnRightVector ("Show Right Vector (it should look red)", Range(0.0, 1.0)) = 0.0
    }
    SubShader{
        Tags{ 
            "RenderType"="Opaque"
            "Queue"="Geometry"
        }

        HLSLINCLUDE

        #pragma vertex vert
        #pragma fragment frag

        #pragma multi_compile _ UNITY_HDR_ON
        #pragma multi_compile_fog

        #include "UnityCG.cginc"
        #include "UnityLightingCommon.cginc"
        #include "UnityShaderVariables.cginc"


        /* properties */

        Texture2D _DiffuseTex;              SamplerState sampler_DiffuseTex;
        Texture2D _LightmapTex;             SamplerState sampler_LightmapTex;
        Texture2D _FaceShadowTex;           SamplerState sampler_FaceShadowTex;
        Texture2D _NormalTex;               SamplerState sampler_NormalTex;
        Texture2D _ShadowRampTex;           SamplerState sampler_ShadowRampTex;
        Texture2D _SpecularRampTex;         SamplerState sampler_SpecularRampTex;
        Texture2D _MetalMapTex;             SamplerState sampler_MetalMapTex;

        Texture2D _CustomEmissionTex;       SamplerState sampler_CustomEmissionTex;
        Texture2D _CustomEmissionAOTex;     SamplerState sampler_CustomEmissionAOTex;

        UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

        float _DayOrNight;
        float _ToggleFaceShader;
        float _EnvironmentLightingStrength;
        float _FallbackOutlines;
        vector<float, 4> _headForwardVector;
        vector<float, 4> _headRightVector;
        float _flipFaceLighting;
        float _MaterialID;
        float _RimLightType;
        float _RimLightIntensity;
        float _RimLightThickness;

        float _ToggleEmission;
        float _ToggleEyeGlow;
        float _EmissionType;
        vector<float, 4> _EmissionColor;
        float _EyeGlowStrength;
        float _EmissionStrength;
        float _TogglePulse;
        float _PulseSpeed;
        float _PulseMinStrength;
        float _PulseMaxStrength;

        float _FaceBlushStrength;
        vector<float, 4> _FaceBlushColor;

        float _BumpScale;
        float _FaceMapSoftness;
        float _LightArea;
        float _ShadowRampWidth;
        float _ShadowTransitionRange;
        float _ShadowTransitionRange2;
        float _ShadowTransitionRange3;
        float _ShadowTransitionRange4;
        float _ShadowTransitionRange5;
        float _ShadowTransitionSoftness;
        float _ShadowTransitionSoftness2;
        float _ShadowTransitionSoftness3;
        float _ShadowTransitionSoftness4;
        float _ShadowTransitionSoftness5;
        float _TextureBiasWhenDithering;
        float _TextureLineSmoothness;
        float _TextureLineThickness;
        float _TextureLineUse;
        float _UseBackFaceUV2;
        float _UseBumpMap;
        float _UseLightMapColorAO;
        float _UseMaterial2;
        float _UseMaterial3;
        float _UseMaterial4;
        float _UseMaterial5;
        float _UseShadowRamp;
        float _UseVertexColorAO;
        vector<float, 4> _CoolShadowMultColor;
        vector<float, 4> _CoolShadowMultColor2;
        vector<float, 4> _CoolShadowMultColor3;
        vector<float, 4> _CoolShadowMultColor4;
        vector<float, 4> _CoolShadowMultColor5;
        vector<float, 4> _FirstShadowMultColor;
        vector<float, 4> _FirstShadowMultColor2;
        vector<float, 4> _FirstShadowMultColor3;
        vector<float, 4> _FirstShadowMultColor4;
        vector<float, 4> _FirstShadowMultColor5;
        vector<float, 4> _TextureLineDistanceControl;
        vector<float, 4> _TextureLineMultiplier;

        float _Shininess;
        float _Shininess2;
        float _Shininess3;
        float _Shininess4;
        float _Shininess5;
        float _SpecMulti;
        float _SpecMulti2;
        float _SpecMulti3;
        float _SpecMulti4;
        float _SpecMulti5;
        vector<float, 4> _SpecularColor;

        float _MTMapBrightness;
        float _MTMapTileScale;
        float _MTShininess;
        float _MTSpecularAttenInShadow;
        float _MTSpecularScale;
        float _MTUseSpecularRamp;
        float _MetalMaterial;
        vector<float, 4> _MTMapDarkColor;
        vector<float, 4> _MTMapLightColor;
        vector<float, 4> _MTShadowMultiColor;
        vector<float, 4> _MTSpecularColor;

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

        float _ReturnVertexColors;
        float _ReturnVertexColorAlpha;
        float _ReturnRimLight;
        float _ReturnNormals;
        float _ReturnRawNormals;
        float _ReturnTangents;
        float _ReturnMetal;
        float _ReturnEmissionFactor;
        float _ReturnForwardVector;
        float _ReturnRightVector;

        /* end of properties */


        ENDHLSL

        Pass{
            Name "ForwardBase"

            Tags{ "LightMode" = "ForwardBase" }

            Cull Off

            HLSLPROGRAM

            #pragma multi_compile_fwdbase

            #include "Genshin-Face.hlsl"

            ENDHLSL
        }
        Pass{
            Name "OutlinePass"

            Tags{ "LightMode" = "ForwardBase" }

            Cull Front

            HLSLPROGRAM

            #pragma multi_compile_fwdbase

            #include "Genshin-Outlines.hlsl"

            ENDHLSL
        }
        UsePass "Standard/SHADOWCASTER"
    }
}
