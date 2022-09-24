struct vsIn{
    vector<float, 3> vertex : POSITION;
    vector<float, 3> normal : NORMAL;
    vector<float, 4> tangent : TANGENT;
    vector<float, 2> uv0 : TEXCOORD0;
    vector<float, 2> uv1 : TEXCOORD1;
    vector<float, 4> vertexcol : COLOR0;
};

struct vsOut{
    vector<float, 4> position : SV_POSITION;
    vector<float, 3> normal : NORMAL; // object space
    vector<float, 4> tangent : TANGENT;
    vector<float, 4> uv : TEXCOORD0; // first 2 elements of vector for UV0, last 2 for UV1
    vector<float, 3> TtoW0 : TEXCOORD1;
    vector<float, 3> TtoW1 : TEXCOORD2;
    vector<float, 3> TtoW2 : TEXCOORD3;
    vector<float, 3> vertexWS : TEXCOORD4;
    vector<float, 4> screenPos : TEXCOORD5;
    UNITY_FOG_COORDS(6)
    vector<float, 4> vertexcol : COLOR0;
};
