#include "btcusdt.cuh"

#include "../impl_template/tmpl_etc.cu"

static __global__ void k__df_btcusdt(
	float * y, float * p1p0, float * dy,
	uint * ts__d,
	uint P)
{
	uint t      = threadIdx.x + blockIdx.x * blockDim.x;
	uint mega_t = threadIdx.y + blockIdx.y * blockDim.y;
	uint p      = threadIdx.z + blockIdx.z * blockDim.z;
	//
	if (t < GRAND_T && mega_t < MEGA_T && p < P) {
		uint ty        = t_MODE(t, mega_t);
		uint t_btcusdt = ts__d[t] + mega_t;
		//
		float _y = y[ty*P + p];
		//
		assert(_y >= -1 && _y <= +1);
		//
		atomicAdd(&dy[ty*P + p], dS(_y, p1p0[t_btcusdt*P + p]) / (float)(P * MEGA_T * GRAND_T));
	}
};

void df_btcusdt(BTCUSDT_t * btcusdt, float * y__d, float * dy__d, uint * ts__d) {
	uint P = btcusdt->Y;
	//
	k__df_btcusdt<<<dim3(KERD(GRAND_T, 16), KERD(MEGA_T, 8), KERD(P, 4)), dim3(16,8,4)>>>(
		y__d, btcusdt->sorties__d, dy__d,
		ts__d,
		P
	);
	ATTENDRE_CUDA();
};