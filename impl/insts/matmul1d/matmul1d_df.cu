#include "matmul1d.cuh"

static __global__ void d_kerd__matmul1d_simple_dXdP(
	uint x0_t, uint X0, float * x0, float * dx0,
	//
	float * p, float * dp,
	//
	uint    Y,
	float * y, float * dy,
	//
	uint * ts__d, uint mega_t,
	//
	uint BLOQUE_X0)
{
	//dx = (p @ ((y-_y)*dtanh(x@p)).T).T
	uint _y = threadIdx.x + blockIdx.x * blockDim.x;
	uint _t = threadIdx.y + blockIdx.y * blockDim.y;
	uint __x0 = threadIdx.z + blockIdx.z * blockDim.z;

	if (_y < Y && _t < GRAND_T) {
		uint tx0 = t_MODE(_t, mega_t-x0_t);
		uint ty  = t_MODE(_t, mega_t     );
		//
		float _dy = dy[ty*Y + _y];
		//
		/*__shared__ float __dy__[16][16];
		if (threadIdx.z == 0) __dy__[threadIdx.y][threadIdx.x] = dy[ty*Y + _y];
		__syncthreads();
		//
		float _dy = __dy__[threadIdx.y][threadIdx.x];*/
		//
		FOR(0, i, X0 / BLOQUE_X0) {
			uint depart_x0 = __x0*(X0/BLOQUE_X0);
			//	s += x0[i]*p[y*X+i]
			atomicAdd(&dx0[tx0*X0 + depart_x0+i], _dy * p [ _y*X0 + depart_x0+i]);
			atomicAdd(&dp [ _y*X0 + depart_x0+i], _dy * x0[tx0*X0 + depart_x0+i]);
		}
	}
};

//	================================================================================
//	================================================================================
//	================================================================================

template <uint BLOQUE>
static __global__ void d_kerd__matmul1d_stricte__dX(
	uint x0_t, uint X0, float * x0, float * dx0,
	//
	float * p, float * dp,
	//
	uint    Y,
	float * y, float * dy,
	//
	uint * ts__d, uint mega_t)
{
	//dx = (p @ ((y-_y)*dtanh(x@p)).T).T
	uint _x = threadIdx.x + blockIdx.x * blockDim.x;
	uint _t = threadIdx.y + blockIdx.y * blockDim.y;
	
	uint tx0 = t_MODE(_t, mega_t-x0_t);
	uint ty  = t_MODE(_t, mega_t     );

	__shared__ float __partage__x[BLOQUE][BLOQUE];
	__shared__ float __partage__p[BLOQUE][BLOQUE];

	float s = 0;

	FOR(0, d, Y/BLOQUE) {
		__partage__x[threadIdx.y][threadIdx.x] = dy[ty*Y + (d*BLOQUE+threadIdx.x)        ];
		__partage__p[threadIdx.y][threadIdx.x] =  p[       (d*BLOQUE+threadIdx.y)*X0 + _x];
		__syncthreads();
	
	#pragma unroll
		FOR(0, i, BLOQUE) {
			s += __partage__x[threadIdx.y][i] * __partage__p[i][threadIdx.x];
		}
		__syncthreads();
	};

	atomicAdd(&dx0[tx0*X0 + _x], s);
};

template <uint BLOQUE>
static __global__ void d_kerd__matmul1d_stricte__dP(
	uint x0_t, uint X0, float * x0, float * dx0,
	//
	float * p, float * dp,
	//
	uint    Y,
	float * y, float * dy,
	//
	uint * ts__d, uint mega_t)
{
	//dp = x.T @ ((y-_y)*dtanh(x@p))
	
	uint _x = threadIdx.x + blockIdx.x * blockDim.x;
	uint _y = threadIdx.y + blockIdx.y * blockDim.y;
	
	__shared__ float __partage__x[BLOQUE][BLOQUE];
	__shared__ float __partage__p[BLOQUE][BLOQUE];

	float s = 0;

	uint d = blockIdx.z;
	//FOR(0, d, T/BLOQUE) {
		uint tx0 = t_MODE((d*BLOQUE+threadIdx.y), (mega_t-x0_t));
		uint ty  = t_MODE((d*BLOQUE+threadIdx.x), (mega_t     ));
		__partage__x[threadIdx.y][threadIdx.x] = dy[ty *Y  + _y];
		__partage__p[threadIdx.y][threadIdx.x] = x0[tx0*X0 + _x];
		__syncthreads();

	#pragma unroll
		FOR(0, i, BLOQUE) {
			s += __partage__x[threadIdx.y][i] * __partage__p[i][threadIdx.x];
		}
		__syncthreads();
	//};

	atomicAdd(&dp[_y*X0 + _x], s);
};

//	-------------------------------------------------------------------------

void matmul1d__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t) {
	uint X0 = inst->x_Y[0];	uint x0_t = inst->x_t[0];
	uint Y  = inst->Y;
	//
	bool x0_existe = (mega_t != 0 ? true : (x0_t != 1));
	//
	if (x0_existe) {
		if (GRAND_T%16 == 0 && X0%16 == 0 && Y%16==0) {
			d_kerd__matmul1d_stricte__dX<16><<<dim3(KERD(X0, 16), KERD(GRAND_T, 16)), dim3(16, 16)>>>(
				inst->x_t[0], inst->x_Y[0], x__d[0], dx__d[0],
				//
				inst->p__d, inst->dp__d,
				//
				inst->Y,
				inst->y__d, inst->dy__d,
				//
				ts__d, mega_t
			);
			d_kerd__matmul1d_stricte__dP<16><<<dim3(KERD(X0, 16), KERD(Y, 16), DIV(GRAND_T,16)), dim3(16, 16)>>>(
				inst->x_t[0], inst->x_Y[0], x__d[0], dx__d[0],
				//
				inst->p__d, inst->dp__d,
				//
				inst->Y,
				inst->y__d, inst->dy__d,
				//
				ts__d, mega_t
			);
		} else {
			uint BLOQUE_X0 = 1;
			//
			//if (X0 % 16 == 0)     BLOQUE_X0 = 8;
			//else if (X0 % 8 == 0) BLOQUE_X0 = 8;
			if (X0 % 4 == 0) BLOQUE_X0 = 4;
			else if (X0 % 2 == 0) BLOQUE_X0 = 2;
			//
			d_kerd__matmul1d_simple_dXdP<<<dim3(KERD(Y, 16), KERD(GRAND_T, 16), BLOQUE_X0), dim3(16, 16)>>>(
				inst->x_t[0], inst->x_Y[0], x__d[0], dx__d[0],
				//
				inst->p__d, inst->dp__d,
				//
				inst->Y,
				inst->y__d, inst->dy__d,
				//
				ts__d, mega_t,
				//
				BLOQUE_X0
			);
		}
	} else {
		//	rien
	}
};