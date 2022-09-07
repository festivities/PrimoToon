Shader "festivity/Genshin-Face"{
    Properties{
        [Header(Textures)] [MainTex] [NoScaleOffset] [HDR] [Space(10)] _DiffuseTex ("Diffuse", 2D) = "white"{}
        [NoScaleOffset] _LightmapTex ("Lightmap", 2D) = "white"{}
        [NoScaleOffset] _FaceShadowTex ("Face Shadow", 2D) = "white"{}
        [NoScaleOffset] [HDR] _ShadowRampTex ("Shadow Ramp", 2D) = "white"{}

        [Header(Miscellaneous and Lighting Options)] [Toggle] [Space(10)] [HideInInspector] _UseShadowRampTex ("Use Shadow Ramp Texture?", Float) = 1.0
        [Toggle] [HideInInspector] _ToggleFaceShader ("Use Face Shader?", Range(0.0, 1.0)) = 1.0
        _headForwardVector ("Forward Vector, ignore the last element", Vector) = (0, 1, 0, 0)
        _headRightVector ("Right Vector, ignore the last element", Vector) = (0, 0, -1, 0)
        [Toggle] _flipFaceLighting ("Flip Face Lighting?", Range(0.0, 1.0)) = 0.0
        [IntRange] _MaterialID ("Material ID", Range(1.0, 5.0)) = 2.0
        _LightArea ("Shadow Position", Range(0.0, 2.0)) = 0.55
        _DayOrNight ("Nighttime?", Range(0.0, 1.0)) = 0.0
        [Toggle] _ToggleTonemapper ("Toggle Enhancement Tonemapper?", Range(0.0, 1.0)) = 1.0
        [Toggle] [HideInInspector] _UseTangents ("Use Tangents for Outlines (placeholder)", Range(0.0, 1.0)) = 0.0
        _RimLightIntensity ("Rim Light Intensity", Float) = 1.0
        _RimLightThickness ("Rim Light Thickness", Range(0.0, 10.0)) = 1.0

        [Header(Outline Options)] [Space(10)] _OutlineWidth ("Outline Width", Float) = 0.03
        [Gamma] _OutlineColor ("Outline Color 1", Color) = (0.0, 0.0, 0.0, 1.0)
        _ZOffset ("Z-Offset", Float) = 1
    }
    SubShader{
        Tags{ "RenderType"="Opaque" }

        Pass{
            Name "ForwardBase"
            Cull Off

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            #include "Genshin-Face.hlsl"

            ENDHLSL
        }
        Pass{
            Name "OutlinePass"
            Cull Front

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #include "Genshin-Outlines.hlsl"

            ENDHLSL
        }
        UsePass "Standard/SHADOWCASTER"
    }
}
