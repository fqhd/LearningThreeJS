#version 300 es

#if (GL_FRAGMENT_PRECISION_HIGH)
	precision highp float;
#else
	precision mediump float;
#endif

in vec2 uv;

out float scale;

uniform sampler2D sphere_texture;
uniform float test_value;

// Thanks to Patricio Gonzalez Vivo for making this noise function
// Source code can be found here: https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
// Github of author: https://github.com/patriciogonzalezvivo?tab=repositories
float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}
float noise(vec3 p){
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);

    vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
    vec4 k1 = perm(b.xyxy);
    vec4 k2 = perm(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm(c);
    vec4 k4 = perm(c + 1.0);

    vec4 o1 = fract(k3 * (1.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (1.0 - d.y);
}

float fractal_noise(vec3 pos){
	float total = 0.0;
	float amplitude = 1.0;
	float frequency = 1.0;

	for(int i = 1; i <= 5; i++){
		total += noise(pos * frequency) * amplitude;
		amplitude *= 0.5;
		frequency *= 2.0;
	}
	return total;
}

float warped_noise(vec3 pos, float factor){
	return fractal_noise(pos + vec3(fractal_noise(pos * factor)));
}

float rigid_noise(vec3 pos, float factor){
	return 1.0 - abs(warped_noise(pos, factor));
}


/*
	Sebastian Lague is the original author of the following smoothMin() and smoothMax() functions.
	Credit goes to him, the original source file containing these functions
	can be found here: https://github.com/SebLague/Solar-System/blob/Development/Assets/Scripts/Celestial/Shaders/Includes/Math.cginc
*/
// Smooth minimum of two values, controlled by smoothing factor k
// When k = 0, this behaves identically to min(a, b)
float smoothMin(float a, float b, float k) {
	k = max(0.0, k);
	// https://www.iquilezles.org/www/articles/smin/smin.htm
	float h = max(0.0, min(1.0, (b - a + k) / (2.0 * k)));
	return a * h + b * (1.0 - h) - k * h * (1.0 - h);
}

// Smooth maximum of two values, controlled by smoothing factor k
// When k = 0, this behaves identically to max(a, b)
float smoothMax(float a, float b, float k) {
	k = min(0.0, -k);
	float h = max(0.0, min(1.0, (b - a + k) / (2.0 * k)));
	return a * h + b * (1.0 - h) - k * h * (1.0 - h);
}

float planet_shape(vec3 pos){
	float height = fractal_noise(pos * 2.0);

	float ocean_floor = -0.125 + height * 0.15;
	height = smoothMax(height, ocean_floor, 0.0);
	height *= (height < 0.0) ? test_value * 0.2 : 0.5;

	return height;
}

void main() {
	vec3 pos = texture(sphere_texture, uv).rgb;

	float height = planet_shape(pos);

	scale = 1.0 + height;
}