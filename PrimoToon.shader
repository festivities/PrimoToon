Shader ".festivity/PrimoToon"{
    Properties 
  { 
        //Header
        [HideInInspector] shader_master_label ("✧<b><i><color=#C69ECE>PrimoToon 2.0</color></i></b>✧", Float) = 0
		[HideInInspector] shader_is_using_thry_editor ("", Float) = 0
		[HideInInspector] footer_github ("{texture:{name:github},action:{type:URL,data:https://github.com/festivities/PrimoToon},hover:GITHUB}", Float) = 0
		[HideInInspector] footer_discord ("{texture:{name:discord},action:{type:URL,data:https://discord.gg/85rP9SpAkF},hover:GITHUB}", Float) = 0
        //Header End
        

        //Material Type
        [ThryWideEnum(Base, 0, Face, 1, Weapon, 2)]variant_selector("Material Type--{on_value_actions:[
		{value:0,actions:[{type:SET_PROPERTY,data:_UseFaceMapNew=0.0}, {type:SET_PROPERTY,data:_UseWeapon=0.0}]},
		{value:1,actions:[{type:SET_PROPERTY,data:_UseFaceMapNew=1.0}, {type:SET_PROPERTY,data:_UseWeapon=0.0}]},
        {value:2,actions:[{type:SET_PROPERTY,data:_UseFaceMapNew=0.0}, {type:SET_PROPERTY,data:_UseWeapon=1.0}
		}]}]}", Int) = 0
        //Material Type End


        //Main
        [HideInInspector] m_start_main ("Main", Float) = 0
        [SmallTexture]_MainTex("Main Texture",2D)= "white" { }
        [SmallTexture]_LightMapTex("Lightmap",2D)= "white" { }
        [Enum(UV0, 0, UV1, 1)] _UseBackFaceUV2("Backface UV", int) = 1.0
        [Toggle] _VertexColorLinear ("Enable Linear Vertex Colors", Range(0.0, 1.0)) = 0.0
        [Toggle]_DayOrNight ("Enable Nighttime", Range(0.0, 1.0)) = 0.0
        [HideInInspector] m_start_mainalpha ("Alpha Options", Float) = 0
        [Enum(Off, 0, Transparency, 1, Glow, 2)] _MainTexAlphaUse("Diffuse Alpha Channel", Int) = 0
        _MainTexAlphaCutoff("Alpha Cuttoff", Range(0, 1.0)) = 0.5
        [HideInInspector] m_end_mainalpha ("", Float) = 0
        [HideInInspector] m_start_maindetail ("Details", Float) = 0
        [Toggle] _TextureLineUse ("Texture Line", Range(0.0, 1.0)) = 0.0
        _TextureLineSmoothness ("Texture Line Smoothness", Range(0.0, 1.0)) = 0.15
        _TextureLineThickness ("Texture Line Thickness", Range(0.0, 1.0)) = 0.55
        _TextureLineDistanceControl ("Texture Line Distance Control", Vector) = (0.1, 0.6, 1.0, 1.0)
        [Gamma] [HDR] _TextureLineMultiplier ("Texture Line Multiplier", Color) = (0.6, 0.6, 0.6, 1.0)
        [HideInInspector] _TextureBiasWhenDithering ("Texture Dithering Bias", Float) = -1.0
        [HideInInspector] m_end_maindetail ("", Float) = 0
        [HideInInspector] m_start_matid ("Material IDs", Float) = 0
        [Toggle] _UseMaterial2 ("Enable Material 2", Float) = 1.0
        [Toggle] _UseMaterial3 ("Enable Material 3", Float) = 1.0
        [Toggle] _UseMaterial4 ("Enable Material 4", Float) = 1.0
        [Toggle] _UseMaterial5 ("Enable Material 5", Float) = 1.0
        [HideInInspector] m_end_matid ("", Float) = 0
        [HideInInspector] m_end_main ("", Float) = 0
        //Main End

        //Normal Map
        [HideInInspector] m_start_normalmap ("Normal Map", Float) = 0
        [Toggle] _UseBumpMap("Normal Map", Float) = 0.0
        [SmallTexture]_BumpMap("Normal Map",2D)= "white"{ }
        _BumpScale ("Normal Map Scale", Range(0.0, 1.0)) = 0.2
        [HideInInspector] m_end_normalmap ("", Float) = 0
        //Normal Map End


        //Face Shading
        [HideInInspector] m_start_faceshading("Face--{condition_show:{type:PROPERTY_BOOL,data:_UseFaceMapNew==1.0}}", Float) = 0
        [Toggle] _flipFaceLighting ("Flip Face Lighting", Range(0.0, 1.0)) = 0.0
        [SmallTexture]_FaceMap ("Face Shadow",2D)= "white"{ }
        [HideInInspector] _UseFaceMapNew ("Enable Face Shader", Range(0.0, 1.0)) = 0.0
        _FaceMapSoftness ("Face Lighting Softness", Range(0.0, 1.0)) = 0.001
        [IntRange] _MaterialID ("Face Material ID", Range(1.0, 5.0)) = 2.0
        _headForwardVector ("Forward Vector", Vector) = (0, 1, 0, 0)
        _headRightVector ("Right Vector, ignore the last element", Vector) = (0, 0, -1, 0)
        [HideInInspector] m_start_faceblush ("Blush", Float) = 0
        _NoseBlushStrength ("Nose Blush Strength", Range(0.0, 1.0)) = 0.0
        _FaceBlushStrength ("Face Blush Strength", Range(0.0, 1.0)) = 0.0
        [Gamma] _NoseBlushColor ("Nose Blush Color", Color) = (1.0, 0.8, 0.7, 1.0)
        [Gamma] _FaceBlushColor ("Face Blush Color", Color) = (1.0, 0.8, 0.7, 1.0)
        [HideInInspector] m_end_faceblush ("", Float) = 0
        [HideInInspector] m_end_faceshading ("", Float) = 0
        //Face Shading End

        //Weapon Shading
        [HideInInspector] m_start_weaponshading("Weapon--{condition_show:{type:PROPERTY_BOOL,data:_UseWeapon==1.0}}", Float) = 0
        [HideInInspector]_UseWeapon ("Weapon Shader", Range(0.0, 1.0)) = 0.0
        [Toggle] _UsePattern ("Enable Weapon Pattern", Range(0.0, 1.0)) = 1.0
        [Toggle] _ProceduralUVs ("Disable UV1", Range(0.0, 1.0)) = 0.0
        [SmallTexture]_WeaponDissolveTex("Weapon Dissolve",2D)= "white"{ }
        [SmallTexture]_WeaponPatternTex("Weapon Pattern",2D)= "white"{ }
        [SmallTexture]_ScanPatternTex("Scan Pattern",2D)= "black"{ }
        _ClipAlphaThreshold ("Dissolve Clipping Threshold", Range(0, 1)) = 1.0
        _WeaponDissolveValue ("Weapon Dissolve Value", Range(-1.0, 2.0)) = 1.0
        [Toggle] _DissolveDirection_Toggle ("Dissolve Direction Toggle", Range(0.0, 1.0)) = 0.0
        [Gamma] [HDR] _WeaponPatternColor ("Weapon Pattern Color", Color) = (1.682, 1.568729, 0.6554853, 1.0)
        _Pattern_Speed ("Pattern Speed", Float) = -0.033
        [HideInInspector] _SkillEmisssionPower ("Skill Emisssion Power", Float) = 0.6
        [Gamma] [HideInInspector] _SkillEmisssionColor ("Skill Emisssion Color", Vector) = (0.0, 0.0, 0.0, 0.0)
        [HideInInspector] _SkillEmissionScaler ("Skill Emission Scaler", Float) = 3.2
        [HideInInspector] m_start_weaponscan ("Scan", Float) = 0
        _ScanColorScaler ("Scan Color Scaler", Float) = 0.0
        [Gamma] _ScanColor ("Scan Color", Color) = (0.8970588, 0.8970588, 0.8970588, 1.0)
        [Toggle] _ScanDirection_Switch ("Scan Direction Switch", Range(0.0, 1.0)) = 0.0
        _ScanSpeed ("Scan Speed", Float) = 0.8
        [HideInInspector] m_end_weaponscan ("", Float) = 0
        [HideInInspector] m_end_weaponshading ("", Float) = 0
        //Weapon Shading End


        //Lightning Options
        [HideInInspector] m_start_lighting("Lighting Options", Float) = 0
        [HideInInspector] g_start_light("", Int) = 0
        [HideInInspector] m_start_lightandshadow("Shadow", Float) = 0
        [SmallTexture]_PackedShadowRampTex("Shadow Ramp",2D)= "white"{ }
        [Toggle] _UseLightMapColorAO ("Use Lightmap Ambient Occlusion?", Range(0.0, 1.0)) = 1.0
        [Toggle] _UseShadowRamp ("Use Shadow Ramp Texture?", Float) = 1.0
        [Toggle] _UseVertexColorAO ("Use Vertex Color Ambient Occlusion?", Range(0.0, 1.0)) = 1.0
        _EnvironmentLightingStrength ("Environment Lighting Strength", Range(0.0, 1.0)) = 1.0

        _LightArea ("Shadow Position", Range(0.0, 2.0)) = 0.55
        _ShadowRampWidth ("Ramp Width", Range(0.2, 3.0)) = 1.0
        [HideInInspector] m_start_shadowtransitions("Shadow Transition", Float) = 0
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
        [HideInInspector] m_end_shadowtransitions ("", Float) = 0
        [HideInInspector] m_start_shadowcolorsday("DayTime Colors", Float) = 0
        [Gamma] _FirstShadowMultColor ("Daytime Shadow Color 1", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _FirstShadowMultColor2 ("Daytime Shadow Color 2", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _FirstShadowMultColor3 ("Daytime Shadow Color 3", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _FirstShadowMultColor4 ("Daytime Shadow Color 4", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _FirstShadowMultColor5 ("Daytime Shadow Color 5", Color) = (0.9, 0.7, 0.75, 1)
        [HideInInspector] m_end_shadowcolorsday ("", Float) = 0
        [HideInInspector] m_start_shadowcolorsnight("NightTime Colors", Float) = 0
        [Gamma] _CoolShadowMultColor ("Nighttime Shadow Color 1", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _CoolShadowMultColor2 ("Nighttime Shadow Color 2", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _CoolShadowMultColor3 ("Nighttime Shadow Color 3", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _CoolShadowMultColor4 ("Nighttime Shadow Color 4", Color) = (0.9, 0.7, 0.75, 1)
        [Gamma] _CoolShadowMultColor5 ("Nighttime Shadow Color 5", Color) = (0.9, 0.7, 0.75, 1)
        [HideInInspector] m_end_shadowcolorsnight ("", Float) = 0
        [HideInInspector] m_end_lightandshadow ("", Float) = 0
        [HideInInspector] m_start_rimlight("Rim Light", Float) = 0
        [Enum(Add, 0, Color Dodge, 1)] _RimLightType ("Rim Light Blend Mode", Float) = 0.0
        _RimLightIntensity ("Rim Light Intensity", Float) = 1.0
        _RimLightThickness ("Rim Light Thickness", Range(0.0, 10.0)) = 1.0
        [HideInInspector] m_end_rimlight ("", Float) = 0
        [HideInInspector] g_end_light("", Int) = 0
        [HideInInspector] m_end_lightning ("", Float) = 0
        //Lightning Options End


         //Reflections
        [HideInInspector] m_start_reflections("Reflections", Float) = 0
        [HideInInspector] m_start_metallics("Metallics", Int) = 0
        [Toggle] _MetalMaterial ("Enable Metallic", Range(0.0, 1.0)) = 1.0
        [SmallTexture]_MTMap("Metallic Matcap--{condition_show:{type:PROPERTY_BOOL,data:_MetalMaterial==1.0}}",2D)= "white"{ }
        _MTMapBrightness ("Metallic Matcap Brightness--{condition_show:{type:PROPERTY_BOOL,data:_MetalMaterial==1.0}}", Float) = 3.0
        _MTShininess ("Metallic Specular Shininess--{condition_show:{type:PROPERTY_BOOL,data:_MetalMaterial==1.0}}", Float) = 90.0
        _MTSpecularScale ("Metallic Specular Scale--{condition_show:{type:PROPERTY_BOOL,data:_MetalMaterial==1.0}}", Float) = 15.0 
        _MTMapTileScale ("Metallic Matcap Tile Scale--{condition_show:{type:PROPERTY_BOOL,data:_MetalMaterial==1.0}}", Range(0.0, 2.0)) = 1.0
        _MTSpecularAttenInShadow ("Metallic Specular Attenuation in Shadow--{condition_show:{type:PROPERTY_BOOL,data:_MetalMaterial==1.0}}", Range(0.0, 1.0)) = 0.2
        _MTSharpLayerOffset ("Metallic Sharp Layer Offset--{condition_show:{type:PROPERTY_BOOL,data:_MetalMaterial==1.0}}", Range(0.001, 1.0)) = 1.0
        [HideInInspector] m_start_metallicscolor("Metallic Colors--{condition_show:{type:PROPERTY_BOOL,data:_MetalMaterial==1.0}}", Int) = 0
        [Gamma] [HDR] _MTMapDarkColor ("Metallic Matcap Dark Color", Color) = (0.51, 0.3, 0.19, 1.0)
        [Gamma] [HDR] _MTMapLightColor ("Metallic Matcap Light Color", Color) = (1.0, 1.0, 1.0, 1.0)
        [Gamma] _MTShadowMultiColor ("Metallic Matcap Shadow Multiply Color", Color) = (0.78, 0.77, 0.82, 1.0)
        [Gamma] [HDR] _MTSpecularColor ("Metallic Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
        [Gamma] _MTSharpLayerColor ("Metallic Sharp Layer Color", Color) = (1.0, 1.0, 1.0, 1.0)
        [HideInInspector] m_end_metallicscolor ("", Int) = 0
        [HideInInspector] m_end_metallics("", Int) = 0
        [HideInInspector] m_start_specular("Specular Reflections", Int) = 0
        [Toggle] _MTUseSpecularRamp ("Enable Specular", Float) = 0.0
        [SmallTexture]_MTSpecularRamp("Specular Ramp--{condition_show:{type:PROPERTY_BOOL,data:_MTUseSpecularRamp==1.0}}",2D)= "white"{ }
        _Shininess ("Shininess 1--{condition_show:{type:PROPERTY_BOOL,data:_MTUseSpecularRamp==1.0}}", Float) = 10
        _Shininess2 ("Shininess 2--{condition_show:{type:PROPERTY_BOOL,data:_MTUseSpecularRamp==1.0}}", Float) = 10
        _Shininess3 ("Shininess 3--{condition_show:{type:PROPERTY_BOOL,data:_MTUseSpecularRamp==1.0}}", Float) = 10
        _Shininess4 ("Shininess 4--{condition_show:{type:PROPERTY_BOOL,data:_MTUseSpecularRamp==1.0}}", Float) = 10
        _Shininess5 ("Shininess 5--{condition_show:{type:PROPERTY_BOOL,data:_MTUseSpecularRamp==1.0}}", Float) = 10
        _SpecMulti ("Specular Multiplier 1--{condition_show:{type:PROPERTY_BOOL,data:_MTUseSpecularRamp==1.0}}", Float) = 0.1
        _SpecMulti2 ("Specular Multiplier 2--{condition_show:{type:PROPERTY_BOOL,data:_MTUseSpecularRamp==1.0}}", Float) = 0.1
        _SpecMulti3 ("Specular Multiplier 3--{condition_show:{type:PROPERTY_BOOL,data:_MTUseSpecularRamp==1.0}}", Float) = 0.1
        _SpecMulti4 ("Specular Multiplier 4--{condition_show:{type:PROPERTY_BOOL,data:_MTUseSpecularRamp==1.0}}", Float) = 0.1
        _SpecMulti5 ("Specular Multiplier 5--{condition_show:{type:PROPERTY_BOOL,data:_MTUseSpecularRamp==1.0}}", Float) = 0.1
        [Gamma] _SpecularColor ("Specular Color--{condition_show:{type:PROPERTY_BOOL,data:_MTUseSpecularRamp==1.0}}", Color) = (1.0, 1.0, 1.0, 1.0)
        [HideInInspector] m_end_specular("", Int) = 0
        [HideInInspector] m_end_reflections ("", Float) = 0
        //Reflections End
        
        //Outlines
        [HideInInspector] m_start_outlines("Outlines", Float) = 0
        [Enum(None, 0, Normal, 1,  Tangent, 2)] _OutlineType ("Outline Type", Float) = 1.0
        [Toggle] _FallbackOutlines ("Enable Fallback Outlines", Range(0.0, 1.0)) = 1.0
        [Toggle] [HideInInspector] _ClipPlaneWorld ("Clip Plane World", Range(0.0, 1.0)) = 1.0
        _OutlineWidth ("Outline Width", Float) = 0.03
        _Scale ("Outline Scale", Float) = 0.01
        [Toggle] [HideInInspector] _UseClipPlane ("Use Clip Plane?", Range(0.0, 1.0)) = 0.0
        [HideInInspector] _ClipPlane ("Clip Plane", Vector) = (0.0, 0.0, 0.0, 0.0)
        [HideInInspector] m_start_outlinescolor("Outline Colors", Float) = 0
        [Gamma] _OutlineColor ("Outline Color 1", Color) = (0.0, 0.0, 0.0, 1.0)
        [Gamma] _OutlineColor2 ("Outline Color 2", Color) = (0.0, 0.0, 0.0, 1.0)
        [Gamma] _OutlineColor3 ("Outline Color 3", Color) = (0.0, 0.0, 0.0, 1.0)
        [Gamma] _OutlineColor4 ("Outline Color 4", Color) = (0.0, 0.0, 0.0, 1.0)
        [Gamma] _OutlineColor5 ("Outline Color 5", Color) = (0.0, 0.0, 0.0, 1.0)
        [HideInInspector] m_end_outlinescolor ("", Float) = 0
        [HideInInspector] m_start_outlinesoffset("Outline Offset & Adjustments", Float) = 0
        _OutlineWidthAdjustScales ("Outline Width Adjust Scales", Vector) = (0.01, 0.245, 0.6, 0.0)
        _OutlineWidthAdjustZs ("Outline Width Adjust Zs", Vector) = (0.001, 2.0, 6.0, 0.0)
        _MaxOutlineZOffset ("Max Z-Offset", Float) = 1.0
        [HideInInspector] m_end_outlinesoffset ("", Float) = 0
        [HideInInspector] m_end_outlines ("", Float) = 0
        //Outlines End

        //Special Effects
        [HideInInspector] m_start_specialeffects("Special Effects", Float) = 0
        [HideInInspector] m_start_emissionglow("Emission / Archon Glow", Float) = 0
        [Enum(Default, 0, Custom, 1)] _EmissionType("Emission Type", Float) = 0.0
        [Gamma] _EmissionColor ("Emission Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        [NoScaleOffset] [HDR] _CustomEmissionTex ("Custom Emission Texture--{condition_show:{type:PROPERTY_BOOL,data:_EmissionType==1}}", 2D) = "black"{}
        [NoScaleOffset] _CustomEmissionAOTex ("Custom Emission Factor--{condition_show:{type:PROPERTY_BOOL,data:_EmissionType==1}}", 2D) = "black"{}
        _EmissionStrength ("Emission Strength", Float) = 1.0
        [HideInInspector] m_start_emissioneyeglow("Eye & Archon Glow", Float) = 0
        [Toggle] _ToggleEyeGlow ("Enable Eye & Archon Glow", Range(0.0, 1.0)) = 1.0
        _EyeGlowStrength ("Eye & Archon Glow Strength", Float) = 1.0
        [HideInInspector] m_end_emissioneyeglow ("", Float) = 0
        [HideInInspector] m_start_emissionpulse("Pulsing Emission", Float) = 0
        [Toggle] _TogglePulse ("Enable Pulse", Range(0.0, 1.0)) = 0.0
        _PulseSpeed ("Pulse Speed", Float) = 1.0
        _PulseMinStrength ("Minimum Pulse Strength", Range(0.0, 1.0)) = 0.0
        _PulseMaxStrength ("Maximum Pulse Strength", Range(0.0, 1.0)) = 1.0
        [HideInInspector] m_end_emissionpulse ("", Float) = 0
        [HideInInspector] m_end_emissionglow ("", Float) = 0

        [HideInInspector] m_start_fresnel("Fresnel", Float) = 0
        [Toggle] _UseFresnel ("Enable Fresnel", Range(0.0, 1.0)) = 1.0
        [Gamma] _HitColor ("Fresnel Color", Color) = (0.0, 0.0, 0.0, 1.0)
        [Gamma] _ElementRimColor ("Element Rim Color", Color) = (0.0, 0.0, 0.0, 1.0)
        _HitColorScaler ("Fresnel Color Scaler", Float) = 6
        _HitColorFresnelPower ("Fresnel Power", Float) = 1.5
        [HideInInspector] m_end_fresnel ("", Float) = 0
        [HideInInspector] m_end_specialeffects ("", Float) = 0
        //Special Effects End

        //Rendering Options
        [HideInInspector] m_start_renderingOptions("Rendering Options", Float) = 0
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull", Float) = 0
        [Enum(Off, 0, On, 1)] _ZWrite("ZWrite", Int) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Float) = 4
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Source Blend", Int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Destination Blend", Int) = 0
        [HideInInspector] m_start_debugOptions("Debug", Float) = 0
        [Toggle] _ReturnDiffuseRGB ("Show Diffuse", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnDiffuseA ("Show Diffuse Alpha", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnLightmapR ("Show Lightmap Red", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnLightmapG ("Show Lightmap Green", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnLightmapB ("Show Lightmap Blue", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnLightmapA ("Show Lightmap Alpha", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnFaceMap ("Show Face Shadow", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnNormalMap ("Show Normal Map", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnTextureLineMap ("Show Texture Line Map", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnVertexColorR ("Show Vertex Color Red", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnVertexColorG ("Show Vertex Color Green", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnVertexColorB ("Show Vertex Color Blue", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnVertexColorA ("Show Vertex Color Alpha", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnRimLight ("Show Rim Light", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnNormals ("Show Normals", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnRawNormals ("Show Raw Normals", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnTangents ("Show Tangents", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnMetal ("Show Metal", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnEmissionFactor ("Show Emission Factor", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnForwardVector ("Show Forward Vector (it should look blue)", Range(0.0, 1.0)) = 0.0
        [Toggle] _ReturnRightVector ("Show Right Vector (it should look red)", Range(0.0, 1.0)) = 0.0
        [HideInInspector] m_end_debugOptions("Debug", Float) = 0
        //[Enum(Thry.ColorMask)] _ColorMask ("Color Mask", Int) = 15
        //_OffsetFactor ("Offset Factor", Float) = 0.0
        //_OffsetUnits ("Offset Units", Float) = 0.0
        //[ToggleUI]_RenderingReduceClipDistance ("Reduce Clip Distance", Float) = 0
        //[ToggleUI]_IgnoreFog ("Ignore Fog", Float) = 0
        //[HideInInspector] Instancing ("Instancing", Float) = 0 //add this property for instancing variants settings to be shown
        
        //[Enum(Thry.BlendOp)]_BlendOpAlpha ("Alpha Blend Op", Int) = 0
        //[Space][ThryHeaderLabel(Additive Blending, 13)]
        //[Enum(Thry.BlendOp)]_AddBlendOp ("RGB Blend Op", Int) = 0
        //[Enum(Thry.BlendOp)]_AddBlendOpAlpha ("Alpha Blend Op", Int) = 0
        //[Enum(UnityEngine.Rendering.BlendMode)] _AddSrcBlend ("Source Blend", Int) = 1
        //[Enum(UnityEngine.Rendering.BlendMode)] _AddDstBlend ("Destination Blend", Int) = 1
        [HideInInspector] m_end_renderingOptions("Rendering Options", Float) = 0
        //Rendering Options End
    }
    SubShader{
        Tags{ "RenderType"="Opaque" "Queue"="Geometry" }

        ZWrite [_ZWrite]

        HLSLINCLUDE

        #pragma vertex vert
        #pragma fragment frag

        #pragma multi_compile _ UNITY_HDR_ON
        #pragma multi_compile_fog

        #include "UnityCG.cginc"
        #include "UnityLightingCommon.cginc"
        #include "UnityShaderVariables.cginc"

        #include "PrimoToon-inputs.hlsli"


        /* properties */

        Texture2D _MainTex;                 SamplerState sampler_MainTex;                 const vector<float, 4> _MainTex_TexelSize;
        Texture2D _LightMapTex;             SamplerState sampler_LightMapTex;             const vector<float, 4> _LightMapTex_TexelSize;
        Texture2D _FaceMap;                 SamplerState sampler_FaceMap;                 const vector<float, 4> _FaceMap_TexelSize;
        Texture2D _BumpMap;                 SamplerState sampler_BumpMap;                 const vector<float, 4> _BumpMap_TexelSize;
        Texture2D _PackedShadowRampTex;     SamplerState sampler_PackedShadowRampTex;
        Texture2D _MTSpecularRamp;          SamplerState sampler_MTSpecularRamp;
        Texture2D _MTMap;                   SamplerState sampler_MTMap;
        Texture2D _WeaponDissolveTex;       SamplerState sampler_WeaponDissolveTex;
        Texture2D _WeaponPatternTex;        SamplerState sampler_WeaponPatternTex;        const vector<float, 4> _WeaponPatternTex_TexelSize;
        Texture2D _ScanPatternTex;          SamplerState sampler_ScanPatternTex;

        Texture2D _CustomEmissionTex;       SamplerState sampler_CustomEmissionTex;
        Texture2D _CustomEmissionAOTex;     SamplerState sampler_CustomEmissionAOTex;

        UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

        float _DayOrNight;
        float _EnvironmentLightingStrength;
        float _RimLightType;
        float _RimLightIntensity;
        float _RimLightThickness;
        float _VertexColorLinear;

        float _UseFresnel;
        vector<float, 4> _HitColor;
        vector<float, 4> _ElementRimColor;
        float _HitColorScaler;
        float _HitColorFresnelPower;

        float _UseFaceMapNew;
        vector<float, 4> _headForwardVector;
        vector<float, 4> _headRightVector;
        float _FaceMapSoftness;
        float _flipFaceLighting;
        float _MaterialID;
        float _NoseBlushStrength;
        vector<float, 4> _NoseBlushColor;
        float _FaceBlushStrength;
        vector<float, 4> _FaceBlushColor;

        float _UseWeapon;
        float _UsePattern;
        float _ProceduralUVs;
        float _ClipAlphaThreshold;
        float _WeaponDissolveValue;
        float _DissolveDirection_Toggle;
        vector<float, 4> _WeaponPatternColor;
        float _Pattern_Speed;
        float _SkillEmisssionPower;
        float4 _SkillEmisssionColor;
        float _SkillEmissionScaler;
        float _ScanColorScaler;
        vector<float, 4> _ScanColor;
        float _ScanDirection_Switch;
        float _ScanSpeed;

        float _MainTexAlphaUse;

        float _ToggleEyeGlow;
        float _EmissionType;
        vector<float, 4> _EmissionColor;
        float _EyeGlowStrength;
        float _EmissionStrength;
        float _TogglePulse;
        float _PulseSpeed;
        float _PulseMinStrength;
        float _PulseMaxStrength;

        float _MainTexAlphaCutoff;

        float _BumpScale;
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
        float _MTSharpLayerOffset;
        float _MTUseSpecularRamp;
        float _MetalMaterial;
        vector<float, 4> _MTMapDarkColor;
        vector<float, 4> _MTMapLightColor;
        vector<float, 4> _MTShadowMultiColor;
        vector<float, 4> _MTSpecularColor;
        vector<float, 4> _MTSharpLayerColor;

        float _TextureBiasWhenDithering;
        float _TextureLineSmoothness;
        float _TextureLineThickness;
        float _TextureLineUse;
        vector<float, 4> _TextureLineDistanceControl;
        vector<float, 4> _TextureLineMultiplier;

        float _ClipPlaneWorld;
        float _MaxOutlineZOffset;
        float _OutlineType; // cb0[13]
        float _FallbackOutlines;
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

        float _ReturnDiffuseRGB;
        float _ReturnDiffuseA;
        float _ReturnLightmapR;
        float _ReturnLightmapG;
        float _ReturnLightmapB;
        float _ReturnLightmapA;
        float _ReturnFaceMap;
        float _ReturnNormalMap;
        float _ReturnTextureLineMap;
        float _ReturnVertexColorR;
        float _ReturnVertexColorG;
        float _ReturnVertexColorB;
        float _ReturnVertexColorA;
        float _ReturnRimLight;
        float _ReturnNormals;
        float _ReturnRawNormals;
        float _ReturnTangents;
        float _ReturnMetal;
        float _ReturnEmissionFactor;
        float _ReturnForwardVector;
        float _ReturnRightVector;

        /* end of properties */


        #include "PrimoToon-helpers.hlsl"

        ENDHLSL

        Pass{
            Name "ForwardBase"

            Tags{ "LightMode" = "ForwardBase" }

            Cull [_Cull]

            Blend [_SrcBlend] [_DstBlend]

            HLSLPROGRAM

            #pragma multi_compile_fwdbase

            #include "PrimoToon-main.hlsl"

            ENDHLSL
        }
        Pass{
            Name "OutlinePass"
            
            Tags{ "LightMode" = "ForwardBase" }

            Cull Front

            Blend [_SrcBlend] [_DstBlend]

            HLSLPROGRAM

            #pragma multi_compile_fwdbase

            #include "PrimoToon-outlines.hlsl"

            ENDHLSL
        }
        Pass{
            Name "ShadowCaster"

            Tags{ "LightMode" = "ShadowCaster" }
            
            HLSLPROGRAM

            #pragma multi_compile_instancing
		    #pragma multi_compile_shadowcaster

            // template by mochie bestie: https://github.com/cnlohr/shadertrixx/blob/main/README.md#shadowcasting
            #include "PrimoToon-shadows.hlsl"

            ENDHLSL
        }
    }
    CustomEditor "Thry.ShaderEditor"
}
