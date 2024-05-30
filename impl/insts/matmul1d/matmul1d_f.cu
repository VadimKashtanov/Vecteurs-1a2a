#include "matmul1d.cuh"

static __global__ void kerd__matmul1d___version_simple(
	uint x0_t, uint X0, float * x0,
	//
	float * p,
	//
	uint    Y,
	float * y,
	//
	uint * ts__d, uint mega_t)
{
	//dx = (p @ ((y-_y)*dtanh(x@p)).T).T
	uint _y = threadIdx.x + blockIdx.x * blockDim.x;
	uint _t = threadIdx.y + blockIdx.y * blockDim.y;

	if (_y < Y && _t < GRAND_T) {
		uint tx0 = t_MODE(_t, mega_t-x0_t);
		uint ty  = t_MODE(_t, mega_t     );
		//
		float s = 0;
		FOR(0, i, X0) {
			//	s += x0[i]
			s += x0[tx0*X0 + i] * p [_y*X0 + i];
		}
		y[ty*Y + _y] = s;
	}
};

//	=========================== Version BLOQUE ==========================

template <uint BLOQUE>
__global__ static void kerd__matmul1d___version_stricte(
	uint x0_t, uint X0, float * x0,
	//
	float * p,
	//
	uint    Y,
	float * y,
	//
	uint * ts__d, uint mega_t)
{
	//
	uint _y = threadIdx.x + blockIdx.x * blockDim.x;
	uint _t = threadIdx.y + blockIdx.y * blockDim.y;
	//
	uint tx0 = t_MODE(_t, mega_t-x0_t);
	uint ty  = t_MODE(_t, mega_t     );
	//
	__shared__ float __partage__x[BLOQUE][BLOQUE];
	__shared__ float __partage__p[BLOQUE][BLOQUE];

	float s = 0;
	//
	FOR(0, d, X0/BLOQUE) {
		__partage__x[threadIdx.y][threadIdx.x] = x0[tx0*X0 + (d*BLOQUE + threadIdx.x)];
		__partage__p[threadIdx.y][threadIdx.x] =  p[ _y*X0 + (d*BLOQUE + threadIdx.y)];
		__syncthreads();

	#pragma unroll
		FOR(0, i, BLOQUE) s += __partage__x[threadIdx.y][i] * __partage__p[i][threadIdx.x];
		__syncthreads();
	};

	y[ty*Y + _y] = s;
};

void matmul1d__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t) {
	uint X0 = inst->x_Y[0];	uint x0_t = inst->x_t[0];
	uint Y  = inst->Y;
	//
	bool x0_existe = (mega_t != 0 ? true : (x0_t != 1));
	//
	if (x0_existe) {
		if (GRAND_T%16 == 0 && X0%16 == 0 && Y%16==0) {
			kerd__matmul1d___version_stricte<16><<<dim3(KERD(Y,16), KERD(GRAND_T,16)), dim3(16,16)>>>(
				inst->x_t[0], inst->x_Y[0], x__d[0],
				//
				inst->p__d,
				//
				inst->Y,
				inst->y__d,
				//
				ts__d, mega_t
			);
		} else {
			kerd__matmul1d___version_simple<<<dim3(KERD(Y,16), KERD(GRAND_T,16)), dim3(16,16)>>>(
				inst->x_t[0], inst->x_Y[0], x__d[0],
				//
				inst->p__d,
				//
				inst->Y,
				inst->y__d,
				//
				ts__d, mega_t
			);
		}
	} else {
		inst_zero_mega_t(inst, mega_t);
	}
};