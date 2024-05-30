#include "btcusdt.cuh"

#include "../impl_template/tmpl_etc.cu"

static __global__ void k__f_btcusdt(
	float * somme_score,
	float * y, float * p1p0,
	uint * ts__d,
	uint P, uint T)
{
	uint t      = threadIdx.x + blockIdx.x * blockDim.x;
	uint mega_t = threadIdx.y + blockIdx.y * blockDim.y;
	uint p      = threadIdx.z + blockIdx.z * blockDim.z;
	//
	if (t < GRAND_T && mega_t < MEGA_T && p < P) {
		uint ty        = t_MODE(t, mega_t);
		uint t_btcusdt = ts__d[t] + mega_t;
		assert(t_btcusdt < T);
		//
		float _y = y[ty*P + p];
		//
		assert(_y >= -1 && _y <= +1);
		atomicAdd(&somme_score[0], S(_y, p1p0[t_btcusdt*P + p]));
		assert(S(_y, p1p0[t_btcusdt*P + p]) >= 0);
	}
};

float f_btcusdt(BTCUSDT_t * btcusdt, float * y__d, uint * ts__d) {
	uint P = btcusdt->Y;
	//
	float * somme__d = cudalloc<float>(1);
	//
	k__f_btcusdt<<<dim3(KERD(GRAND_T, 16), KERD(MEGA_T, 8), KERD(P, 4)), dim3(16,8,4)>>>(
		somme__d,
		y__d, btcusdt->sorties__d,
		ts__d,
		P, btcusdt->T
	);
	ATTENDRE_CUDA();
	//
	float * somme = gpu_vers_cpu<float>(somme__d, 1);
	//
	float score = somme[0] / ((float)(P * GRAND_T * MEGA_T));
	//
	cudafree<float>(somme__d);
	    free       (somme   );
	//
	return score;
};