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

// https://gist.github.com/shakesoda/1dcb3e159f586995ca076c8b21f05a67
float GTTonemap(const float x){
	float m = 0.22; // linear section start
	float a = 1.0;  // contrast
	float c = 1.33; // black brightness
	float P = 1.0;  // maximum brightness
	float l = 0.4;  // linear section length
	float l0 = ((P-m)*l) / a; // 0.312
	float S0 = m + l0; // 0.532
	float S1 = m + a * l0; // 0.532
	float C2 = (a*P) / (P - S1); // 2.13675213675
	float L = m + a * (x - m);
	float T = m * pow(x/m, c);
	float S = P - (P - S1) * exp(-C2*(x - S0)/P);
	float w0 = 1 - smoothstep(0.0, m, x);
	float w2 = (x < m+l)?0:1;
	float w1 = 1 - w0 - w2;
	return float(T * w0 + L * w1 + S * w2);
}

// this costs about 0.2-0.3ms more than aces, as-is
vector<float, 3> GTTonemap(const vector<float, 3> x){
	return vector<float, 3>(GTTonemap(x.x), GTTonemap(x.y), GTTonemap(x.z));
}

vector<float, 4> GTTonemap(const vector<float, 4> x){
	return vector<float, 4>(GTTonemap(x.x), GTTonemap(x.y), GTTonemap(x.z), x.w);
}

/* https://github.com/penandlim/JL-s-Unity-Blend-Modes/blob/master/John%20Lim's%20Blend%20Modes/CGIncludes/PhotoshopBlendModes.cginc */

// color dodge blend mode
vector<fixed, 3> ColorDodge(const vector<fixed, 3> s, const vector<fixed, 3> d){
    return d / (1.0 - min(s, 0.999));
}

vector<fixed, 4> ColorDodge(const vector<fixed, 4> s, const vector<fixed, 4> d){
    return vector<fixed, 4>(d.xyz / (1.0 - min(s.xyz, 0.999)), d.w);
}
