#include "opti.cuh"

#define adam_beta1 0.9
#define adam_beta2 0.99

__global__ static void kerd_adam(
	float * p, float * dp,
	float * v, float * s,
	float alpha,
	uint POIDS)
{
	uint thx = threadIdx.x + blockIdx.x * blockDim.x;

	if (thx < POIDS) {
		float _grad = dp[thx];
		float _v = adam_beta1*v[thx] + (1-adam_beta1)*_grad;
		float _s = adam_beta2*s[thx] + (1-adam_beta2)*_grad*_grad;
		//
		float corr_v = _v / (1 - adam_beta1);
		float corr_s = _s / (1 - adam_beta2);
		//
		float ch  = alpha * _grad * corr_v / (sqrtf(corr_s) + 1e-8);
		float reg = alpha * L2_regularisation * p[thx];
		//
		p[thx] -= alpha * _grad/*(ch + reg)*/;
		v[thx] = _v;
		s[thx] = _s;
	}
};

void adam(
	Mdl_t   * mdl,
	float *** hist,
	uint         i,
	float    alpha
) {
	FOR(0, i, mdl->insts) {
		Inst_t * inst = mdl->inst[i];
		//
		if (inst->P != 0) {
			kerd_adam<<<dim3(KERD(mdl->inst[i]->P, 256)),dim3(256)>>>(
				inst->p__d, inst->dp__d,
				hist[0][i], hist[1][i],
				alpha,
				inst->P
			);
		}
	}
	ATTENDRE_CUDA();
};