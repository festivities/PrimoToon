Shader ".festivity/PrimoToon/genshin-main"{
    Properties{
        [Header(Textures)] [MainTex] [NoScaleOffset] [HDR] [Space(10)] _DiffuseTex ("Diffuse", 2D) = "white"{}
        [NoScaleOffset] _LightmapTex ("Lightmap", 2D) = "white"{}
        [NoScaleOffset] _NormalTex ("Normal Map", 2D) = "bump"{}
        [NoScaleOffset] [HDR] _ShadowRampTex ("Shadow Ramp", 2D) = "white"{}
        [NoScaleOffset] [HDR] _SpecularRampTex ("Specular Ramp", 2D) = "white"{}
        [NoScaleOffset] [HDR] _MetalMapTex ("Metallic Matcap", 2D) = "white"{}

        [Header(Miscellaneous and Lighting Options)] [Space(10)] _DayOrNight ("Nighttime?", Range(0.0, 1.0)) = 0.0
        _EnvironmentLightingStrength ("Environment Lighting Strength", Range(0.0, 1.0)) = 1.0
        [Toggle] _FallbackOutlines ("Fallback Outlines?", Range(0.0, 1.0)) = 0.0
        [KeywordEnum(Add, Color Dodge)] _RimLightType ("Rim Light Blend Mode", Float) = 0.0
        _RimLightIntensity ("Rim Light Intensity", Float) = 1.0
        _RimLightThickness ("Rim Light Thickness", Range(0.0, 10.0)) = 1.0

        [Header(Emission Options)] [Space(10)] [Toggle] _ToggleEmission ("Toggle Emission?", Range(0.0, 1.0)) = 0.0
        [Toggle] _ToggleEyeGlow ("Toggle Eye Glow?", Range(0.0, 1.0)) = 1.0
        [KeywordEnum(Default, Custom)] _EmissionType ("Emission Type", Float) = 0.0
        [NoScaleOffset] [HDR] _CustomEmissionTex ("Custom Emission Texture", 2D) = "black"{}
        [NoScaleOffset] _CustomEmissionAOTex ("Custom Emission AO", 2D) = "white"{}
        [Gamma] _EmissionColor ("Emission Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _EyeGlowStrength ("Eye Glow Strength", Float) = 1.0
        _EmissionStrength ("Emission Strength", Float) = 1.0
        [Toggle] _TogglePulse ("Toggle Pulse?", Range(0.0, 1.0)) = 0.0
        _PulseSpeed ("Pulse Speed", Float) = 1.0
        _PulseMinStrength ("Minimum Pulse Strength", Range(0.0, 1.0)) = 0.0
        _PulseMaxStrength ("Maximum Pulse Strength", Range(0.0, 1.0)) = 1.0

        [Header(Diffuse or Lighting Options)] [Space(10)] _BumpScale ("Bump Scale", Range(0.0, 1.0)) = 0.2
        _LightArea ("Shadow Position", Range(0.0, 2.0)) = 0.55
        _ShadowRampWidth ("Ramp Width", Range(0.2, 3.0)) = 1.0
        _ShadowTransitionRange ("Shadow Transition Range 1", Range(0.0, 1.0)) = 0.01
        _ShadowTransitionRange2 ("Shadow Transition Range 2", Range(0.0, 1.0)) = 0.01
        _ShadowTransitionRange3 ("Shadow Transition Range 3", Range(0.0, 1.0)) = 0.01
        _ShadowTransitionRange4 ("Shadow Transition Range 4", Range(0.0, 1.0)) = 0.01
        _ShadowTransitionRange5 ("Shadow Transition Range 5", Range(0.0, 1.0)) = 0.01
        _ShadowTransitionSoftness ("Shadow Transition Softness 1", Range(0.0, 1.0)) = 0.5
        _ShadowTransitionSoftness2 ("Shadow Transition Softness 2", Range(0.0, 1.0)) = 0.5
        _ShadowTransitionSoftness3 ("Shadow Transition Softness 3", Range(0.0, 1.0)) = 0.5
        _ShadowTransitionSoftness4 ("Shadow Transition Softness 4", Range(0.0, 1.0)) = 0.5
        _ShadowTransitionSoftness5 ("Shadow Transition Softness 5", Range(0.0, 1.0)) = 0.5
        [HideInInspector] _TextureBiasWhenDithering ("Texture Dithering Bias", Float) = -1.0
        [HideInInspector] _TextureLineSmoothness ("Texture Line Smoothness", Range(0.0, 1.0)) = 0.15
        [HideInInspector] _TextureLineThickness ("Texture Line Thickness", Range(0.0, 1.0)) = 0.55
        [Toggle] [HideInInspector] _TextureLineUse ("Use Texture Line?", Range(0.0, 1.0)) = 1.0
        [Toggle] _UseBackFaceUV2 ("Use second UV for backfaces?", Float) = 1.0
        [Toggle] _UseBumpMap ("Use Normal Map?", Float) = 1.0
        [Toggle] _UseLightMapColorAO ("Use Lightmap Ambient Occlusion?", Range(0.0, 1.0)) = 1.0
        [Toggle] _UseMaterial2 ("Toggle Material 2", Float) = 1.0
        [Toggle] _UseMaterial3 ("Toggle Material 3", Float) = 1.0
        [Toggle] _UseMaterial4 ("Toggle Material 4", Float) = 1.0
        [Toggle] _UseMaterial5 ("Toggle Material 5", Float) = 1.0
        [Toggle] _UseShadowRamp ("Use Shadow Ramp Texture?", Float) = 1.0
        [Toggle] _UseVertexColorAO ("Use Vertex Color Ambient Occlusion?", Range(0.0, 1.0)) = 1.0
        [Gamma] _CoolShadowMultColor ("Nighttime Shadow Color 1", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _CoolShadowMultColor2 ("Nighttime Shadow Color 2", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _CoolShadowMultColor3 ("Nighttime Shadow Color 3", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _CoolShadowMultColor4 ("Nighttime Shadow Color 4", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _CoolShadowMultColor5 ("Nighttime Shadow Color 5", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _FirstShadowMultColor ("Daytime Shadow Color 1", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _FirstShadowMultColor2 ("Daytime Shadow Color 2", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _FirstShadowMultColor3 ("Daytime Shadow Color 3", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _FirstShadowMultColor4 ("Daytime Shadow Color 4", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _FirstShadowMultColor5 ("Daytime Shadow Color 5", Color) = (0.9, 0.7, 0.75, 1)
        [HideInInspector] _TextureLineDistanceControl ("Texture Line Distance Control", Vector) = (0.1, 0.6, 1.0, 1.0)
        [HideInInspector] _TextureLineMultiplier ("Texture Line Multiplier", Vector) = (0.6, 0.6, 0.6, 1.0)

        [Header(Specular Options)] [Space(10)] _Shininess ("Shininess 1", Float) = 10
        _Shininess2 ("Shininess 2", Float) = 10
        _Shininess3 ("Shininess 3", Float) = 10
        _Shininess4 ("Shininess 4", Float) = 10
        _Shininess5 ("Shininess 5", Float) = 10
        _SpecMulti ("Specular Multiplier 1", Float) = 0.1
        _SpecMulti2 ("Specular Multiplier 2", Float) = 0.1
        _SpecMulti3 ("Specular Multiplier 3", Float) = 0.1
        _SpecMulti4 ("Specular Multiplier 4", Float) = 0.1
        _SpecMulti5 ("Specular Multiplier 5", Float) = 0.1
        [Gamma] _SpecularColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)

        [Header(Metallic Options)] [Space(10)] _MTMapBrightness ("Metallic Matcap Brightness", Float) = 3.0
        _MTMapTileScale ("Metallic Matcap Tile Scale", Range(0.0, 2.0)) = 1.0
        _MTShininess ("Metallic Specular Shininess", Float) = 90.0
        _MTSpecularAttenInShadow ("Metallic Specular Attenuation in Shadow", Range(0.0, 1.0)) = 0.2
        _MTSpecularScale ("Metallic Specular Scale", Float) = 15.0
        [Toggle] _MTUseSpecularRamp ("Use Specular Ramp Texture?", Float) = 0.0
        [Toggle] _MetalMaterial ("Enable Metallic?", Range(0.0, 1.0)) = 1.0
        [Gamma] _MTMapDarkColor ("Metallic Matcap Dark Color", Color) = (0.51, 0.3, 0.19, 1.0)
        [Gamma] _MTMapLightColor ("Metallic Matcap Light Color", Color) = (1.0, 1.0, 1.0, 1.0)
        [Gamma] _MTShadowMultiColor ("Metallic Matcap Shadow Multiply Color", Color) = (0.78, 0.77, 0.82, 1.0)
        [Gamma] _MTSpecularColor ("Metallic Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)

        [Header(Outline Options)] [Space(10)] _MaxOutlineZOffset ("Max Z-Offset", Float) = 1.0
        [Toggle] [HideInInspector] _ClipPlaneWorld ("Clip Plane World", Range(0.0, 1.0)) = 1.0
        [KeywordEnum(None, Normal, Tangent)] _OutlineType ("Outline Type", Float) = 1.0
        _OutlineWidth ("Outline Width", Float) = 0.03
        _Scale ("Outline Scale", Float) = 0.01
        [Toggle] [HideInInspector] _UseClipPlane ("Use Clip Plane?", Range(0.0, 1.0)) = 0.0
        [HideInInspector] _ClipPlane ("Clip Plane", Vector) = (0.0, 0.0, 0.0, 0.0)
        [Gamma] _OutlineColor ("Outline Color 1", Color) = (0.0, 0.0, 0.0, 1.0)
        [Gamma] _OutlineColor2 ("Outline Color 2", Color) = (0.0, 0.0, 0.0, 1.0)
        [Gamma] _OutlineColor3 ("Outline Color 3", Color) = (0.0, 0.0, 0.0, 1.0)
        [Gamma] _OutlineColor4 ("Outline Color 4", Color) = (0.0, 0.0, 0.0, 1.0)
        [Gamma] _OutlineColor5 ("Outline Color 5", Color) = (0.0, 0.0, 0.0, 1.0)
        _OutlineWidthAdjustScales ("Outline Width Adjust Scales", Vector) = (0.01, 0.245, 0.6, 0.0)
        _OutlineWidthAdjustZs ("Outline Width Adjust Zs", Vector) = (0.001, 2.0, 6.0, 0.0)

        [Header(Debugging)] [Space(10)] [Toggle] _ReturnVertexColors ("Show Vertex Colors (RGB only)", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnVertexColorAlpha ("Show Vertex Color Alpha", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnRimLight ("Show Rim Light", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnNormals ("Show Normals", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnRawNormals ("Show Raw Normals", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnTangents ("Show Tangents", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnMetal ("Show Metal", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnEmissionFactor ("Show Emission Factor", Range(0.0, 1.0)) = 0.0
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

        #include "Genshin-Main_inputs.hlsli"


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


        #include "Genshin-Helpers.hlsl"

        ENDHLSL

        Pass{
            Name "ForwardBase"

            Tags{ "LightMode" = "ForwardBase" }

            Cull Off

            HLSLPROGRAM

            #pragma multi_compile_fwdbase

            #include "Genshin-Main.hlsl"

            ENDHLSL
        }
        Pass{
            Name "OutlinePass"
            
            Tags{
                "LightMode" = "ForwardBase" // i know, why two ForwardBase passes...
            }                               // ForwardAdd just doesn't work for me... :(

            Cull Front

            HLSLPROGRAM

            #pragma multi_compile_fwdbase

            #include "Genshin-Outlines.hlsl"

            ENDHLSL
        }
        UsePass "Standard/SHADOWCASTER"
    }
}
