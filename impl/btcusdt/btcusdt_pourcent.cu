#include "btcusdt.cuh"

#include "../impl_template/tmpl_etc.cu"

static __global__ void k__pourcent_btcusdt(
	float * somme, float * potentiel,
	float * y, float * p1p0,
	float coef_puissance,
	uint * ts__d,
	uint P, uint Y)
{
	uint t      = threadIdx.x + blockIdx.x * blockDim.x;
	uint mega_t = threadIdx.y + blockIdx.y * blockDim.y;
	//
	if (t < GRAND_T && mega_t < MEGA_T) {
		uint ty        = t_MODE(t, mega_t);
		uint t_btcusdt = ts__d[t] + mega_t;
		//
		FOR(0, p, P) {
			uint a_t_il_predit = (sng(p1p0[t_btcusdt*P + p]) == sng(y[ty*Y + 1+p]));
			//
			float _____somme = powf(fabs(p1p0[t_btcusdt*P + p]), coef_puissance) * a_t_il_predit;
			float _potentiel = powf(fabs(p1p0[t_btcusdt*P + p]), coef_puissance) * true         ;
			//
			atomicAdd(&somme    [p], _____somme);
			atomicAdd(&potentiel[p], _potentiel);
		}
	}
};

float *  pourcent_btcusdt(BTCUSDT_t * btcusdt, float * y__d, uint * ts__d, float coef_puissance) {
	uint P = btcusdt->Y;
	uint Y = btcusdt->P + btcusdt->A;
	//
	float *     somme__d = cudalloc<float>(P);
	float * potentiel__d = cudalloc<float>(P);
	//
	k__pourcent_btcusdt<<<dim3(KERD(GRAND_T, 16), KERD(MEGA_T, 8)), dim3(16,8)>>>(
		somme__d, potentiel__d,
		y__d, btcusdt->sorties__d,
		coef_puissance,
		ts__d,
		P, Y
	);
	ATTENDRE_CUDA();
	//
	float * somme     = gpu_vers_cpu<float>(    somme__d, P);
	float * potentiel = gpu_vers_cpu<float>(potentiel__d, P);
	//
	float * ret = alloc<float>(P);
	FOR(0, p, P) ret[p] = somme[p] / potentiel[p];
	//
	cudafree<float>(    somme__d);
	cudafree<float>(potentiel__d);
	    free(           somme   );
	    free(       potentiel   );
	//
	return ret;
};
