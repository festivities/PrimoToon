/* helper functions */

// light fallback
vector<half, 4> getlightDir(){
    vector<half, 4> lightDir = (_WorldSpaceLightPos0 != 0) ? _WorldSpaceLightPos0 :
                               vector<half, 4>(0, 0, 0, 0) + vector<half, 4>(1, 1, 0, 0);
    return lightDir;
}

// map range function
float mapRange(const float min_in, const float max_in, const float min_out, const float max_out, const float value){
    float slope = (max_out - min_out) / (max_in - min_in);
    
    return min_out + slope * (value - min_in);
}

float lerpByZ(const float startScale, const float endScale, const float startZ, const float endZ, const float z){
   float t = (z - startZ) / max(endZ - startZ, 0.001);
   t = saturate(t);
   return lerp(startScale, endScale, t);
}

// environment lighting function
vector<fixed, 4> calculateEnvLighting(vector<float, 3> vertexWSInput){
    // get all the point light positions
    vector<half, 3> firstPointLightPos = { unity_4LightPosX0.x, unity_4LightPosY0.x, unity_4LightPosZ0.x };
    vector<half, 3> secondPointLightPos = { unity_4LightPosX0.y, unity_4LightPosY0.y, unity_4LightPosZ0.y };
    vector<half, 3> thirdPointLightPos = { unity_4LightPosX0.z, unity_4LightPosY0.z, unity_4LightPosZ0.z };
    vector<half, 3> fourthPointLightPos = { unity_4LightPosX0.w, unity_4LightPosY0.w, unity_4LightPosZ0.w };

    // get all the point light attenuations
    half firstPointLightAtten = 2 * rsqrt(unity_4LightAtten0.x);
    half secondPointLightAtten = 2 * rsqrt(unity_4LightAtten0.y);
    half thirdPointLightAtten = 2 * rsqrt(unity_4LightAtten0.z);
    half fourthPointLightAtten = 2 * rsqrt(unity_4LightAtten0.w);

    // first, get the distance between each vertex and all of the point light positions,
    // then invert the result and apply attenuation, saturate to prevent my guy from glowing
    // lastly, multiply it to the corresponding light's color
    vector<half, 3> firstPointLight = saturate(lerp(1, 0, distance(vertexWSInput, firstPointLightPos) - 
                                      firstPointLightAtten)) * unity_LightColor[0];
    vector<half, 3> secondPointLight = saturate(lerp(1, 0, distance(vertexWSInput, secondPointLightPos) - 
                                       secondPointLightAtten)) * unity_LightColor[1];
    vector<half, 3> thirdPointLight = saturate(lerp(1, 0, distance(vertexWSInput, thirdPointLightPos) - 
                                      thirdPointLightAtten)) * unity_LightColor[2];
    vector<half, 3> fourthPointLight = saturate(lerp(1, 0, distance(vertexWSInput, thirdPointLightPos) - 
                                       fourthPointLightAtten)) * unity_LightColor[3];

    // THIS COULD USE SOME IMPROVEMENTS, I DON'T KNOW HOW TO DISABLE THIS FOR SPOT LIGHTS
    // compare with all of the other point lights
    vector<half, 3> pointLightCalc = firstPointLight;
    pointLightCalc = max(pointLightCalc, secondPointLight);
    pointLightCalc = max(pointLightCalc, thirdPointLight);
    pointLightCalc = max(pointLightCalc, thirdPointLight);

    // get the color of whichever's greater between the light direction and the strongest nearby point light
    vector<fixed, 4> environmentLighting = max(_LightColor0, vector<fixed, 4>(pointLightCalc, 1));
    // now get whichever's greater than the result of the first and the nearest light probe
    vector<half, 3> ShadeSH9Alternative = vector<half, 3>(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w) + 
                                          vector<half, 3>(unity_SHBr.z, unity_SHBg.z, unity_SHBb.z) / 3.0;
    //environmentLighting = max(environmentLighting, vector<fixed, 4>(ShadeSH9(vector<half, 4>(0, 0, 0, 1)), 1));
    environmentLighting = max(environmentLighting, vector<fixed, 4>(ShadeSH9Alternative, 1));

    return environmentLighting;
}

// rim light function
vector<half, 4> calculateRimLight(const vector<float, 3> normalInput, const vector<float, 4> screenPosInput, 
                                  const float RimLightIntensityInput, const float RimLightThicknessInput, 
                                  const float factor){
    // basically view-space normals, except we cannot use the normal map so get mesh's raw normals
    vector<half, 3> rimNormals = UnityObjectToWorldNormal(normalInput);
    rimNormals = mul(UNITY_MATRIX_V, rimNormals);

    // https://github.com/TwoTailsGames/Unity-Built-in-Shaders/blob/master/CGIncludes/UnityDeferredLibrary.cginc#L152
    vector<half, 2> screenPos = screenPosInput.xy / screenPosInput.w;

    // sample depth texture and get it in linear form untouched
    half linearDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenPos);
    linearDepth = LinearEyeDepth(linearDepth);

    // now we modify screenPos to offset another sampled depth texture
    screenPos = screenPos + (rimNormals.x * (0.00125 * max(_ScreenParams.x * 
                0.00025, 1) + ((RimLightThicknessInput - 1) * 0.001)));
    screenPos = screenPos + rimNormals.y * 0.001;

    // sample depth texture again to another object with modified screenPos
    half rimDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenPos);
    rimDepth = LinearEyeDepth(rimDepth);

    // now compare the two
    half depthDiff = rimDepth - linearDepth;

    // finally, le rim light :)
    half rimLight = saturate(smoothstep(0, 1, depthDiff));
    // creative freedom from here on
    rimLight *= saturate(lerp(1, 0, linearDepth - 8));
    rimLight = rimLight * max(factor * 0.2, 0.1) * RimLightIntensityInput;

    return rimLight;
}

/* https://github.com/penandlim/JL-s-Unity-Blend-Modes/blob/master/John%20Lim's%20Blend%20Modes/CGIncludes/PhotoshopBlendModes.cginc */

// color dodge blend mode
vector<fixed, 3> ColorDodge(const vector<fixed, 3> s, const vector<fixed, 3> d){
    return d / (1.0 - min(s, 0.999));
}

vector<fixed, 4> ColorDodge(const vector<fixed, 4> s, const vector<fixed, 4> d){
    return vector<fixed, 4>(d.xyz / (1.0 - min(s.xyz, 0.999)), d.w);
}
