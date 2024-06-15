#include "btcusdt.cuh"

#include "../impl_template/tmpl_etc.cu"

static __global__ void k__df_btcusdt(
	float * y, float * p1p0, float * dy,
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
		float A = y[ty*Y + 0];
		assert(A >= 0 && A <= +1);
		float _da = 0;
		//
		FOR(0, p, P) {
			float _y = y[ty*Y + 1+p];
			assert(_y >= -1 && _y <= +1);
			//
			float _p1p0 = p1p0[t_btcusdt*P + p];
			//
			//
			float _dSdy = dSdy(A, _y, _p1p0) / (float)(P * MEGA_T * GRAND_T);
			float _dSdA = dSdA(A, _y, _p1p0) / (float)(P * MEGA_T * GRAND_T);
			//
			//printf("%f %f\n", _y, p1p0[t_btcusdt*P + p]);
			//if (t==0 && mega_t==0 && p==0) printf("%f %f\n", _y, _p1p0);
			//
			atomicAdd(&dy[ty*Y + 1+p], _dSdy);
			_da += _dSdA;
		}
		//
		atomicAdd(&dy[ty*Y + 0], _da);
	}
};

void df_btcusdt(BTCUSDT_t * btcusdt, float * y__d, float * dy__d, uint * ts__d) {
	uint P = btcusdt->P;
	uint Y = btcusdt->P + btcusdt->A;
	//
	k__df_btcusdt<<<dim3(KERD(GRAND_T, 16), KERD(MEGA_T, 8)), dim3(16,8)>>>(
		y__d, btcusdt->sorties__d, dy__d,
		ts__d,
		P, Y
	);
	ATTENDRE_CUDA();
};