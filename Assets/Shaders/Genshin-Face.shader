Shader "festivity/Genshin-Face"{
    Properties{
        [Header(Textures)] [MainTex] [NoScaleOffset] _DiffuseTex ("Diffuse", 2D) = "white"{}
        [NoScaleOffset] _LightmapTex ("Lightmap", 2D) = "white"{}
        [NoScaleOffset] _FaceShadowTex ("Face Shadow", 2D) = "white"{}
        [NoScaleOffset] _DiffuseRampTex ("Diffuse Ramp", 2D) = "white"{}

        [Header(Miscellaneous and Lighting Options)] [Toggle] _UseDiffuseRampTex ("Use Diffuse Ramp Texture?", Float) = 1.0
        [Toggle] [HideInInspector] _ToggleFaceShader ("Use Face Shader?", Range(0.0, 1.0)) = 1.0
        _MaterialID ("Material ID", Range(0.0, 5.0)) = 2.0
        _LightArea ("Shadow Position", Range(0.0, 2.0)) = 0.55
        _DayOrNight ("Nighttime?", Range(0.0, 1.0)) = 0.0

        [Header(Outline Options)] _OutlineWidth ("Outline Width", Float) = 0.03
        [Gamma] _OutlineColor ("Outline Color 1", Color) = (0.0, 0.0, 0.0, 0.0)
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
    }
}
