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
        [Toggle] _ToggleTonemapper ("Toggle Enhancement Tonemapper? *DISABLES BLOOM*", Range(0.0, 1.0)) = 0.0
        [Toggle] [HideInInspector] _UseTangents ("Use Tangents for Outlines (placeholder)", Range(0.0, 1.0)) = 0.0
        [KeywordEnum(Add, Color Dodge)] _RimLightType ("Rim Light Blend Mode", Float) = 0.0
        _RimLightIntensity ("Rim Light Intensity", Float) = 1.0
        _RimLightThickness ("Rim Light Thickness", Range(0.0, 10.0)) = 1.0

        [Header(Face Blush)] [Space(10)] _FaceBlushStrength ("Face Blush Strength", Range(0.0, 1.0)) = 0.0
        [Gamma] _FaceBlushColor ("Face Blush Color", Color) = (1.0, 0.8, 0.7, 1.0)

        [Header(Diffuse or Lighting Options)] [Space(10)] _FaceMapSoftness ("Face Lighting Softness", Range(0.0, 1.0)) = 0.001
        _LightArea ("Shadow Position", Range(0.0, 2.0)) = 0.55
        [Toggle] _UseShadowRampTex ("Use Shadow Ramp Texture?", Float) = 1.0

        [Header(Outline Options)] [Space(10)] [KeywordEnum(None, Normal, Tangent)] _OutlineType ("Outline Type", Float) = 1.0
        _OutlineWidth ("Outline Width", Float) = 0.03
        [Gamma] _OutlineColor ("Outline Color 1", Color) = (0.0, 0.0, 0.0, 1.0)
        _MaxOutlineZOffset ("Z-Offset", Float) = 1.0

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

        Stencil{
            Ref [_Stencil]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
            Comp [_StencilComp]
            Pass [_StencilPass]
            Fail [_StencilFail]
            ZFail [_StencilZFail]
            CompBack [_StencilCompBack]
            PassBack [_StencilPassBack]
            FailBack [_StencilFailBack]
            ZFailBack [_StencilZFailBack]
            CompFront [_StencilCompFront]
            PassFront [_StencilPassFront]
            FailFront [_StencilFailFront]
            ZFailFront [_StencilZFailFront]
        }

        HLSLINCLUDE

        #include "UnityCG.cginc"
        #include "UnityLightingCommon.cginc"

        #pragma multi_compile _ UNITY_HDR_ON
        #pragma multi_compile_fog

        ENDHLSL

        Pass{
            Name "ForwardBase"

            Tags{
                "LightMode" = "ForwardBase"
            }

            Cull Off

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase

            #include "Genshin-Face.hlsl"

            ENDHLSL
        }
        Pass{
            Name "OutlinePass"

            Tags{
                "LightMode" = "ForwardBase" // i know, why two ForwardBase passes...
            }                               // ForwardAdd just doesn't work for me... :(

            Cull Front

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase

            #include "Genshin-Outlines.hlsl"

            ENDHLSL
        }
        UsePass "Standard/SHADOWCASTER"
    }
}
