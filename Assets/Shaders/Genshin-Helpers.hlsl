// helper functions
vector<half, 4> getlightDir(){ // light fallback
    vector<half, 4> lightDir = (_WorldSpaceLightPos0 != 0) ? _WorldSpaceLightPos0 :
                               vector<half, 4>(0, 0, 0, 0) + vector<half, 4>(1, 1, 0, 0);
    return lightDir;
}
