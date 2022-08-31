Shader "festivity/Genshin-Main"{
    Properties{
        [Header(Textures)] [MainTex] [NoScaleOffset] _DiffuseTex ("Diffuse", 2D) = "white"{}
        [NoScaleOffset] _LightmapTex ("Lightmap", 2D) = "white"{}
        [NoScaleOffset] _FaceShadowTex ("Face Shadow [IF USING FACE SHADER]", 2D) = "white"{}
        [NoScaleOffset] _NormalTex ("Normal Map", 2D) = "bump"{}
        [NoScaleOffset] _ShadowRampTex ("Shadow Ramp", 2D) = "white"{}
        [NoScaleOffset] _SpecularRampTex ("Specular Ramp", 2D) = "white"{}
        [NoScaleOffset] [HDR] _MetalMapTex ("Metallic Matcap", 2D) = "white"{}

        [Header(Miscellaneous and Lighting Options)] [Toggle] _UseShadowRampTex ("Use Shadow Ramp Texture?", Float) = 1.0
        [Toggle] _UseSpecularRampTex ("Use Specular Ramp Texture?", Float) = 0.0
        _LightArea ("Shadow Position", Range(0.0, 2.0)) = 0.55
        _ShadowRampWidth ("Ramp Width", Range(0.2, 3.0)) = 1.0
        _DayOrNight ("Nighttime?", Range(0.0, 1.0)) = 0.0
        [Toggle] _UseMaterial2 ("Toggle Material 2", Float) = 1.0
        [Toggle] _UseMaterial3 ("Toggle Material 3", Float) = 1.0
        [Toggle] _UseMaterial4 ("Toggle Material 4", Float) = 1.0
        [Toggle] _UseMaterial5 ("Toggle Material 5", Float) = 1.0

        [Header(Specular Options)] _Shininess ("Shininess 1", Float) = 10
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

        [Header(Metallic Options)]_MTMapBrightness ("Metallic Matcap Brightness", Float) = 3.0
        _MTMapTileScale ("Metallic Matcap Tile Scale", Range(0.0, 2.0)) = 1.0
        _MTShininess ("Metallic Specular Shininess", Float) = 90.0
        _MTSpecularAttenInShadow ("Metallic Specular Attenuation in Shadow", Range(0.0, 1.0)) = 0.2
        _MTSpecularScale ("Metallic Specular Scale", Float) = 15.0
        [Gamma] _MTMapDarkColor ("Metallic Matcap Dark Color", Color) = (0.51, 0.3, 0.19, 1.0)
        [Gamma] _MTMapLightColor ("Metallic Matcap Light Color", Color) = (1.0, 1.0, 1.0, 1.0)
        [Gamma] _MTShadowMultiColor ("Metallic Matcap Shadow Multiply Color", Color) = (0.78, 0.77, 0.82, 1.0)
        [Gamma] _MTSpecularColor ("Metallic Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)

        [Header(Outline Options)] _OutlineWidth ("Outline Width", Float) = 0.03
        [Gamma] _OutlineColor ("Outline Color 1", Color) = (0.0, 0.0, 0.0, 0.0)
        [Gamma] _OutlineColor2 ("Outline Color 2", Color) = (0.0, 0.0, 0.0, 0.0)
        [Gamma] _OutlineColor3 ("Outline Color 3", Color) = (0.0, 0.0, 0.0, 0.0)
        [Gamma] _OutlineColor4 ("Outline Color 4", Color) = (0.0, 0.0, 0.0, 0.0)
        [Gamma] _OutlineColor5 ("Outline Color 5", Color) = (0.0, 0.0, 0.0, 0.0)
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

            #include "Genshin-Main.hlsl"

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
