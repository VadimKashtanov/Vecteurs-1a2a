#pragma once

#include "meta.cuh"

__device__
static float ACTIVATION(uint activ, float s) {
	float a;
	//
	if      (activ == 0) a = tanh(s);
	else if (activ == 1) a = 1 / (1 + expf(-s));
	else if (activ == 2) a = expf(-s*s);
	else if (activ == 3) a = (s > 0 ? s : 0.0);
	else if (activ == 4) a = powf(tanh(s), 3);
	else if (activ == 5) a = tanh(s) * powf(1 + expf(-s), -1);
	else if (activ == 6) a = expf(s);
	else assert(0);
	//
	return a;
};

__device__
static float d_ACTIVATION(uint activ, float s, float a) {
	float da;
	//
	if      (activ == 0) da = 1 - a*a;
	else if (activ == 1) da = a * (1 - a);
	else if (activ == 2) da = -2*s * a;
	else if (activ == 3) da = (s>0);
	else if (activ == 4) da = 3*powf(tanh(s),2) * (1-a*a);
	else if (activ == 5) da = (1-tanh(s)*tanh(s))/(1+expf(-s)) + tanh(s)*powf(1+expf(-s),-1-1)*(-1)*expf(-s)*(-1);
	else if (activ == 6) da = a;
	else assert(0);
	//
	return da;
};

__device__
static f2 ACTIVATION_f_df(uint activ, float s) {
	float  a =   ACTIVATION(activ, s   );
	float da = d_ACTIVATION(activ, s, a);
	//
	f2 ret = {a, da};
	//
	return ret;
};