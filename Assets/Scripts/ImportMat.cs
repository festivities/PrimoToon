/* cursed code by yours truly, thanks to nitro bestie for some assistance with .json parsing

// I hardcode all objects inside m_Floats and m_Colors since Unity's dumb in-built .json library doesn't let you
// store an individual object's key and value - plz do a pull request if you have any improvements/rewrites owo
*/

using System.IO;
using UnityEngine;
using UnityEditor;
using System;

[System.Serializable]
internal class m_Floats{
    public float _BumpScale;
    public float _LightArea;
    public float _MTMapBrightness;
    public float _MTMapTileScale;
    public float _MTSharpLayerOffset;
    public float _MTShininess;
    public float _MTSpecularAttenInShadow;
    public float _MTSpecularScale;
    public float _MTUseSpecularRamp;
    public float _MainTexAlphaCutoff;
    public float _MainTexAlphaUse;
    public float _MaxOutlineZOffset;
    public float _MetalMaterial;
    public float _ShadowTransitionRange;
    public float _ShadowTransitionRange2;
    public float _ShadowTransitionRange3;
    public float _ShadowTransitionRange4;
    public float _ShadowTransitionRange5;
    public float _ShadowTransitionSoftness;
    public float _ShadowTransitionSoftness2;
    public float _ShadowTransitionSoftness3;
    public float _ShadowTransitionSoftness4;
    public float _ShadowTransitionSoftness5;
    public float _Shininess;
    public float _Shininess2;
    public float _Shininess3;
    public float _Shininess4;
    public float _Shininess5;
    public float _SpecMulti;
    public float _SpecMulti2;
    public float _SpecMulti3;
    public float _SpecMulti4;
    public float _SpecMulti5;
    public float _TextureLineSmoothness;
    public float _TextureLineThickness;
    public float _TextureLineUse;
    public float _UseBackFaceUV2;
    public float _UseBumpMap;
    public float _UseFaceMapNew;
    public float _UseLightMapColorAO;
    public float _UseMaterial2;
    public float _UseMaterial3;
    public float _UseMaterial4;
    public float _UseMaterial5;
    public float _UseShadowRamp;
    public float _UseVertexColorAO;
};

[System.Serializable]
internal class m_Colors{
    public Color _CoolShadowMultColor;
    public Color _CoolShadowMultColor2;
    public Color _CoolShadowMultColor3;
    public Color _CoolShadowMultColor4;
    public Color _CoolShadowMultColor5;
    public Color _EmissionColor_MHY;
    public Color _FirstShadowMultColor;
    public Color _FirstShadowMultColor2;
    public Color _FirstShadowMultColor3;
    public Color _FirstShadowMultColor4;
    public Color _FirstShadowMultColor5;
    public Color _MTMapDarkColor;
    public Color _MTMapLightColor;
    public Color _MTShadowMultiColor;
    public Color _MTSharpLayerColor;
    public Color _MTSpecularColor;
    public Color _OutlineColor;
    public Color _OutlineColor2;
    public Color _OutlineColor3;
    public Color _OutlineColor4;
    public Color _OutlineColor5;
    public Color _OutlineWidthAdjustScales;
    public Color _OutlineWidthAdjustZs;
    public Color _SpecularColor;
    public Color _TextureLineDistanceControl;
    public Color _TextureLineMultiplier;
}

[System.Serializable]
internal class m_SavedProperties{
    public m_Floats m_Floats;
    public m_Colors m_Colors;
};

[System.Serializable]
internal class GenshinMat{
    public m_SavedProperties m_SavedProperties;
    public string m_Name;
};

[System.Serializable]
public class ImportMat : EditorWindow{
    [MenuItem("Assets/Genshin Impact/Import Material Properties From .json")]
    public static void ImportMatFile(){
        string path = EditorUtility.OpenFilePanel("Select a Genshin Impact material .json file", "", "json");
        if(path.Length == 0){
            EditorUtility.DisplayDialog("Error", "Select a valid Genshin Impact material .json file.", "OK");
            return;
        }

        TextAsset buf = new TextAsset(File.ReadAllText(path));
        GenshinMat materialProp = JsonUtility.FromJson<GenshinMat>(buf.text);

        if(Selection.activeObject is Material){
            Material selectedMaterial = Selection.activeObject as Material;

            // can't believe I did this wtf

            /* FLOATS */
            selectedMaterial.SetFloat("_BumpScale", materialProp.m_SavedProperties.m_Floats._BumpScale);
            selectedMaterial.SetFloat("_LightArea", materialProp.m_SavedProperties.m_Floats._LightArea);
            selectedMaterial.SetFloat("_MTMapBrightness", materialProp.m_SavedProperties.m_Floats._MTMapBrightness);
            selectedMaterial.SetFloat("_MTMapTileScale", materialProp.m_SavedProperties.m_Floats._MTMapTileScale);
            selectedMaterial.SetFloat("_MTSharpLayerOffset", materialProp.m_SavedProperties.m_Floats._MTSharpLayerOffset);
            selectedMaterial.SetFloat("_MTShininess", materialProp.m_SavedProperties.m_Floats._MTShininess);
            selectedMaterial.SetFloat("_MTSpecularAttenInShadow", materialProp.m_SavedProperties.m_Floats._MTSpecularAttenInShadow);
            selectedMaterial.SetFloat("_MTSpecularScale", materialProp.m_SavedProperties.m_Floats._MTSpecularScale);
            selectedMaterial.SetFloat("_MTUseSpecularRamp", materialProp.m_SavedProperties.m_Floats._MTUseSpecularRamp);
            /*switch(materialProp.m_SavedProperties.m_Floats._MainTexAlphaUse){
                case 1:
                    selectedMaterial.SetFloat("_ToggleEmission", 0.0f);
                    selectedMaterial.SetFloat("_ToggleCutout", 1.0f);
                    break;
                case 2:
                    selectedMaterial.SetFloat("_ToggleEmission", 1.0f);
                    selectedMaterial.SetFloat("_ToggleCutout", 0.0f);
                    break;
                default:
                    selectedMaterial.SetFloat("_ToggleEmission", 0.0f);
                    selectedMaterial.SetFloat("_ToggleCutout", 0.0f);
                    break;
            }*/
            selectedMaterial.SetFloat("_MainTexAlphaCutoff", materialProp.m_SavedProperties.m_Floats._MainTexAlphaCutoff);
            selectedMaterial.SetFloat("_MainTexAlphaUse", materialProp.m_SavedProperties.m_Floats._MainTexAlphaUse);
            selectedMaterial.SetFloat("_MaxOutlineZOffset", materialProp.m_SavedProperties.m_Floats._MaxOutlineZOffset);
            selectedMaterial.SetFloat("_MetalMaterial", materialProp.m_SavedProperties.m_Floats._MetalMaterial);
            selectedMaterial.SetFloat("_ShadowTransitionRange", materialProp.m_SavedProperties.m_Floats._ShadowTransitionRange);
            selectedMaterial.SetFloat("_ShadowTransitionRange2", materialProp.m_SavedProperties.m_Floats._ShadowTransitionRange2);
            selectedMaterial.SetFloat("_ShadowTransitionRange3", materialProp.m_SavedProperties.m_Floats._ShadowTransitionRange3);
            selectedMaterial.SetFloat("_ShadowTransitionRange4", materialProp.m_SavedProperties.m_Floats._ShadowTransitionRange4);
            selectedMaterial.SetFloat("_ShadowTransitionRange5", materialProp.m_SavedProperties.m_Floats._ShadowTransitionRange5);
            selectedMaterial.SetFloat("_ShadowTransitionSoftness", materialProp.m_SavedProperties.m_Floats._ShadowTransitionSoftness);
            selectedMaterial.SetFloat("_ShadowTransitionSoftness2", materialProp.m_SavedProperties.m_Floats._ShadowTransitionSoftness2);
            selectedMaterial.SetFloat("_ShadowTransitionSoftness3", materialProp.m_SavedProperties.m_Floats._ShadowTransitionSoftness3);
            selectedMaterial.SetFloat("_ShadowTransitionSoftness4", materialProp.m_SavedProperties.m_Floats._ShadowTransitionSoftness4);
            selectedMaterial.SetFloat("_ShadowTransitionSoftness5", materialProp.m_SavedProperties.m_Floats._ShadowTransitionSoftness5);
            selectedMaterial.SetFloat("_Shininess", materialProp.m_SavedProperties.m_Floats._Shininess);
            selectedMaterial.SetFloat("_Shininess2", materialProp.m_SavedProperties.m_Floats._Shininess2);
            selectedMaterial.SetFloat("_Shininess3", materialProp.m_SavedProperties.m_Floats._Shininess3);
            selectedMaterial.SetFloat("_Shininess4", materialProp.m_SavedProperties.m_Floats._Shininess4);
            selectedMaterial.SetFloat("_Shininess5", materialProp.m_SavedProperties.m_Floats._Shininess5);
            selectedMaterial.SetFloat("_SpecMulti", materialProp.m_SavedProperties.m_Floats._SpecMulti);
            selectedMaterial.SetFloat("_SpecMulti2", materialProp.m_SavedProperties.m_Floats._SpecMulti2);
            selectedMaterial.SetFloat("_SpecMulti3", materialProp.m_SavedProperties.m_Floats._SpecMulti3);
            selectedMaterial.SetFloat("_SpecMulti4", materialProp.m_SavedProperties.m_Floats._SpecMulti4);
            selectedMaterial.SetFloat("_SpecMulti5", materialProp.m_SavedProperties.m_Floats._SpecMulti5);
            selectedMaterial.SetFloat("_TextureLineSmoothness", materialProp.m_SavedProperties.m_Floats._TextureLineSmoothness);
            selectedMaterial.SetFloat("_TextureLineThickness", materialProp.m_SavedProperties.m_Floats._TextureLineThickness);
            selectedMaterial.SetFloat("_TextureLineUse", materialProp.m_SavedProperties.m_Floats._TextureLineUse);
            selectedMaterial.SetFloat("_UseBackFaceUV2", materialProp.m_SavedProperties.m_Floats._UseBackFaceUV2);
            selectedMaterial.SetFloat("_UseBumpMap", materialProp.m_SavedProperties.m_Floats._UseBumpMap);
            selectedMaterial.SetFloat("_UseFaceMapNew", materialProp.m_SavedProperties.m_Floats._UseFaceMapNew);
            selectedMaterial.SetFloat("_UseLightMapColorAO", materialProp.m_SavedProperties.m_Floats._UseLightMapColorAO);
            selectedMaterial.SetFloat("_UseMaterial2", materialProp.m_SavedProperties.m_Floats._UseMaterial2);
            selectedMaterial.SetFloat("_UseMaterial3", materialProp.m_SavedProperties.m_Floats._UseMaterial3);
            selectedMaterial.SetFloat("_UseMaterial4", materialProp.m_SavedProperties.m_Floats._UseMaterial4);
            selectedMaterial.SetFloat("_UseMaterial5", materialProp.m_SavedProperties.m_Floats._UseMaterial5);
            selectedMaterial.SetFloat("_UseShadowRamp", materialProp.m_SavedProperties.m_Floats._UseShadowRamp);
            selectedMaterial.SetFloat("_UseVertexColorAO", materialProp.m_SavedProperties.m_Floats._UseVertexColorAO);
            /* FLOATS */

            /* COLORS/VECTORS */
            selectedMaterial.SetColor("_CoolShadowMultColor", materialProp.m_SavedProperties.m_Colors._CoolShadowMultColor);
            selectedMaterial.SetColor("_CoolShadowMultColor2", materialProp.m_SavedProperties.m_Colors._CoolShadowMultColor2);
            selectedMaterial.SetColor("_CoolShadowMultColor3", materialProp.m_SavedProperties.m_Colors._CoolShadowMultColor3);
            selectedMaterial.SetColor("_CoolShadowMultColor4", materialProp.m_SavedProperties.m_Colors._CoolShadowMultColor4);
            selectedMaterial.SetColor("_CoolShadowMultColor5", materialProp.m_SavedProperties.m_Colors._CoolShadowMultColor5);
            selectedMaterial.SetColor("_EmissionColor", materialProp.m_SavedProperties.m_Colors._EmissionColor_MHY);
            selectedMaterial.SetColor("_FirstShadowMultColor", materialProp.m_SavedProperties.m_Colors._FirstShadowMultColor);
            selectedMaterial.SetColor("_FirstShadowMultColor2", materialProp.m_SavedProperties.m_Colors._FirstShadowMultColor2);
            selectedMaterial.SetColor("_FirstShadowMultColor3", materialProp.m_SavedProperties.m_Colors._FirstShadowMultColor3);
            selectedMaterial.SetColor("_FirstShadowMultColor4", materialProp.m_SavedProperties.m_Colors._FirstShadowMultColor4);
            selectedMaterial.SetColor("_FirstShadowMultColor5", materialProp.m_SavedProperties.m_Colors._FirstShadowMultColor5);
            selectedMaterial.SetColor("_MTMapDarkColor", materialProp.m_SavedProperties.m_Colors._MTMapDarkColor);
            selectedMaterial.SetColor("_MTMapLightColor", materialProp.m_SavedProperties.m_Colors._MTMapLightColor);
            selectedMaterial.SetColor("_MTShadowMultiColor", materialProp.m_SavedProperties.m_Colors._MTShadowMultiColor);
            selectedMaterial.SetColor("_MTSharpLayerColor", materialProp.m_SavedProperties.m_Colors._MTSharpLayerColor);
            selectedMaterial.SetColor("_MTSpecularColor", materialProp.m_SavedProperties.m_Colors._MTSpecularColor);
            selectedMaterial.SetColor("_OutlineColor", materialProp.m_SavedProperties.m_Colors._OutlineColor);
            selectedMaterial.SetColor("_OutlineColor2", materialProp.m_SavedProperties.m_Colors._OutlineColor2);
            selectedMaterial.SetColor("_OutlineColor3", materialProp.m_SavedProperties.m_Colors._OutlineColor3);
            selectedMaterial.SetColor("_OutlineColor4", materialProp.m_SavedProperties.m_Colors._OutlineColor4);
            selectedMaterial.SetColor("_OutlineColor5", materialProp.m_SavedProperties.m_Colors._OutlineColor5);
            selectedMaterial.SetVector("_OutlineWidthAdjustScales", materialProp.m_SavedProperties.m_Colors._OutlineWidthAdjustScales);
            selectedMaterial.SetVector("_OutlineWidthAdjustZs", materialProp.m_SavedProperties.m_Colors._OutlineWidthAdjustZs);
            selectedMaterial.SetColor("_SpecularColor", materialProp.m_SavedProperties.m_Colors._SpecularColor);
            selectedMaterial.SetVector("_TextureLineDistanceControl", materialProp.m_SavedProperties.m_Colors._TextureLineDistanceControl);
            selectedMaterial.SetColor("_TextureLineMultiplier", materialProp.m_SavedProperties.m_Colors._TextureLineMultiplier);
            /* COLORS/VECTORS */
        }
        else{
            EditorUtility.DisplayDialog("Error", "Please right-click a material asset when using the script.", "OK");
            return;
        }
    }
};
