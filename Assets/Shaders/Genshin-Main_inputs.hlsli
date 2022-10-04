struct vsIn{
    vector<float, 4> vertex : POSITION;
    vector<float, 3> normal : NORMAL;
    vector<float, 4> tangent : TANGENT;
    vector<float, 2> uv0 : TEXCOORD0;
    vector<float, 2> uv1 : TEXCOORD1;
    vector<float, 4> vertexcol : COLOR0;
};

struct vsOut{
    vector<float, 4> pos : SV_POSITION;
    vector<float, 3> normal : NORMAL; // object space
    vector<float, 4> tangent : TANGENT;
    vector<float, 4> uv : TEXCOORD0; // first 2 elements of vector for UV0, last 2 for UV1
    vector<float, 4> vertexWS : TEXCOORD1;
    vector<float, 4> screenPos : TEXCOORD2;
    vector<float, 4> vertexOS : TEXCOORD3;
    UNITY_FOG_COORDS(4)
    vector<float, 4> vertexcol : COLOR0;
};
