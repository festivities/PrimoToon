struct appdata{
    vector<float, 4> vertex : POSITION;
    vector<float, 3> normal : NORMAL;
    vector<float, 2> uv0 : TEXCOORD0;
    vector<float, 2> uv1 : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f{
    vector<float, 4> pos : SV_POSITION;
    vector<float, 4> uv : TEXCOORD0;
    vector<float, 4> vertexOS : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID 
    UNITY_VERTEX_OUTPUT_STEREO
};

v2f vert (appdata v){
    v2f o = (v2f)0;
    o.uv.xy = v.uv0;
    o.uv.zw = v.uv1;
    o.vertexOS = v.vertex;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
    return o;
}

vector<float, 4> frag (v2f i) : SV_Target{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

    // sample textures to objects
    vector<fixed, 4> mainTex = _MainTex.Sample(sampler_MainTex, vector<half, 2>(i.uv.xy));

    /* WEAPON */

    if(_UseWeapon != 0.0){
        vector<half, 2> weaponUVs = (_ProceduralUVs != 0.0) ? (i.vertexOS.zx + 0.25) * 1.5 : i.uv.zw;

        vector<fixed, 3> dissolve = 0.0;

        /* DISSOLVE */

        calculateDissolve(dissolve, weaponUVs.xy, 1.0);

        /*buf = dissolveTex < 0.99;

        dissolveTex.x -= 0.001;
        dissolveTex.x = dissolveTex.x < 0.0;
        dissolveTex.x = (buf) ? dissolveTex.x : 0.0;*/

        /* END OF DISSOLVE */

        // apply dissolve
        //globalOutlineColor.w = dissolve.x;
        clip(dissolve.x - _ClipAlphaThreshold);
    }

    /* END OF WEAPON */


    /* CUTOUT TRANSPARENCY */

    if(_ToggleCutout != 0.0) clip(mainTex.w - 0.03 - _TransparencyCutoff);

    /* END OF CUTOUT TRANSPARENCY */


    return 0;
}
