#include "btcusdt.cuh"

#include "../impl_template/tmpl_etc.cu"

static __global__ void k__f_btcusdt(
	float * somme_score,
	float * y, float * p1p0,
	uint * ts__d,
	uint P, uint Y,
	uint T)
{
	uint t      = threadIdx.x + blockIdx.x * blockDim.x;
	uint mega_t = threadIdx.y + blockIdx.y * blockDim.y;
	//
	if (t < GRAND_T && mega_t < MEGA_T) {
		uint ty        = t_MODE(t, mega_t);
		uint t_btcusdt = ts__d[t] + mega_t;
		assert(t_btcusdt < T);
		//
		float A = y[ty*Y + 0];
		assert(A >= 0 && A <= +1);
		//
		FOR(0, p, P) {
			float _y = y[ty*Y + 1+p];
			assert(_y >= -1 && _y <= +1);
			//
			float _p1p0 = p1p0[t_btcusdt*P + p];
			//
			float _S = S(A, _y, _p1p0);
			

			assert(_S >= 0);


			//printf(">> %f %f\n", _y, p1p0[t_btcusdt*P + p]);
			//if (t==0 && mega_t==0 && p==0) printf("%f %f\n", _y, _p1p0);
			//
			atomicAdd(&somme_score[0], _S);
		}
	}
};

float f_btcusdt(BTCUSDT_t * btcusdt, float * y__d, uint * ts__d) {
	uint P = btcusdt->P;
	uint Y = btcusdt->P + btcusdt->A;
	//
	float * somme__d = cudalloc<float>(1);
	//
	k__f_btcusdt<<<dim3(KERD(GRAND_T, 16), KERD(MEGA_T, 8)/*, KERD(P, 4)*/), dim3(16,8/*,4*/)>>>(
		somme__d,
		y__d, btcusdt->sorties__d,
		ts__d,
		P, Y,
		btcusdt->T
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