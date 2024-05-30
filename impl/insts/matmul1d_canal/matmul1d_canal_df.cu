#include "matmul1d_canal.cuh"

static __global__ void d_kerd__matmul1d_canal__simple(
	uint x0_t, uint X0, float * x0, float * dx0,
	//
	float * p, float * dp,
	//
	uint    Y,
	float * y, float * dy,
	//
	uint * ts__d, uint mega_t,
	//
	uint _c0, uint _c1, uint v_x, uint v_y, uint M, uint C0, uint C1)
{
	uint thx = threadIdx.x + blockIdx.x * blockDim.x;
	uint thy = threadIdx.y + blockIdx.y * blockDim.y;

	//	v_y*_c1
	uint __v_y = thx % v_y;
	uint ___c1 = (thx-__v_y)/v_y;

	//	GRAND_T*M
	uint _t = thy % GRAND_T;
	uint _m = (thy-_t)/GRAND_T;

	if (__v_y < v_y && ___c1 < _c1 && _t < GRAND_T && _m < M) {
		uint tx0 = t_MODE(_t, mega_t-x0_t);
		uint ty  = t_MODE(_t, mega_t     );
		//
		uint pos_y = _m*_c1*v_y + ___c1*v_y + __v_y;
		//
		float _dy = dy[ty*Y + pos_y];
		//
		FOR(0, __c0, _c0) {
			//	mat mul v_x;v_y
			FOR(0, i, v_x) {
				//	s += x0[i]
				//s += x0[tx0*X0 + _m*_c0*v_x + __c0*v_x + i] * p[(_m*_c1*v_y + ___c1*v_y + __v_y)*v_x + __c0*v_x + i];
				uint pos_x0 = tx0*X0 + _m*_c0*v_x + __c0*v_x + i;
				uint pos_p  = pos_y*v_x*_c0 + __c0*v_x + i;
				//
				atomicAdd(&dx0[pos_x0], _dy *  p[pos_p ]);
				atomicAdd(&dp [pos_p ], _dy * x0[pos_x0]);
			}

		}
	}
};

//	====================================================================================

/*template <uint BLOQUE>
static __global__ void d_kerd__matmul1d_canal_stricte__dX(
	uint _m, uint ___c1, uint ___c0,
	//
	uint x0_t, uint X0, float * x0, float * dx0,
	//
	float * p, float * dp,
	//
	uint    Y,
	float * y, float * dy,
	//
	uint * ts__d, uint mega_t,
	//
	uint _c0, uint _c1, uint v_x, uint v_y, uint M, uint C0, uint C1)
{
	//dx = (p @ ((y-_y)*dtanh(x@p)).T).T
	uint _x = threadIdx.x + blockIdx.x * blockDim.x;
	uint _t = threadIdx.y + blockIdx.y * blockDim.y;
	
	uint tx0 = t_MODE(_t, mega_t-x0_t);
	uint ty  = t_MODE(_t, mega_t     );

	__shared__ float __partage__x[BLOQUE][BLOQUE];
	__shared__ float __partage__p[BLOQUE][BLOQUE];

	float s = 0;

	FOR(0, d, v_y/BLOQUE) {
		__partage__x[threadIdx.y][threadIdx.x] = dy[ty*Y + _m*_c1*v_y + ___c1*v_y + (d*BLOQUE+threadIdx.x)];
		__partage__p[threadIdx.y][threadIdx.x] =  p[(_m*_c1*v_y + ___c1*v_y + (d*BLOQUE+threadIdx.y))* + v_x*_c0 + ___c0*v_x + _x];
		__syncthreads();
	
	#pragma unroll
		FOR(0, i, BLOQUE) {
			s += __partage__x[threadIdx.y][i] * __partage__p[i][threadIdx.x];
		}
		__syncthreads();
	};

	atomicAdd(&dx0[tx0*X0 + _m*_c0*v_x + ___c0*v_x + _x], s);
};

template <uint BLOQUE>
static __global__ void d_kerd__matmul1d_canal_stricte__dP(
	uint _m, uint ___c1, uint ___c0,
	//
	uint x0_t, uint X0, float * x0, float * dx0,
	//
	float * p, float * dp,
	//
	uint    Y,
	float * y, float * dy,
	//
	uint * ts__d, uint mega_t,
	//
	uint _c0, uint _c1, uint v_x, uint v_y, uint M, uint C0, uint C1)
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
		//
		__partage__x[threadIdx.y][threadIdx.x] = dy[ty * Y  + _m*_c1*v_y + ___c1*v_y + _y];
		__partage__p[threadIdx.y][threadIdx.x] = x0[tx0*X0 + _m*_c0*v_x + ___c0*v_x + _x];
		__syncthreads();

	#pragma unroll
		FOR(0, i, BLOQUE) {
			s += __partage__x[threadIdx.y][i] * __partage__p[i][threadIdx.x];
		}
		__syncthreads();
	//};

	uint pos_y = _m*_c1*v_y + ___c1*v_y + _y;
	uint pos_p = pos_y*v_x*_c0 + ___c0*v_x + _x;
	atomicAdd(&dp[pos_p], s);
};*/

//	------------------------------------------------------------------------------------

void matmul1d_canal__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t) {
	uint * params = inst->params;
	uint \
		C0=params[0],	\
		C1=params[1],	\
		M =params[2];
	//
	uint _c0 = C0 / M;
	uint _c1 = C1 / M;
	//
	uint v_x = inst->x_Y[0] / C0;
	uint v_y = inst->Y      / C1;
	//
	uint x0_t = inst->x_t[0];
	uint Y    = inst->Y;
	//
	bool x0_existe = (mega_t != 0 ? true : (x0_t != 1));
	//
	if (x0_existe) {
		/*if (v_x%16==0 && v_y%16==0 && GRAND_T%16==0) {
			FOR(0, ___c0, _c0) {
				FOR(0, ___c1, _c1) {
					FOR(0, _m, M) {
						d_kerd__matmul1d_canal_stricte__dX<16><<<dim3(KERD(v_x, 16), KERD(GRAND_T, 16)), dim3(16, 16)>>>(
							_m, ___c1, ___c0,
							//
							inst->x_t[0], inst->x_Y[0], x__d[0], dx__d[0],
							//
							inst->p__d, inst->dp__d,
							//
							inst->Y,
							inst->y__d, inst->dy__d,
							//
							ts__d, mega_t,
							//
							_c0, _c1, v_x, v_y, M, C0, C1
						);
						d_kerd__matmul1d_canal_stricte__dP<16><<<dim3(KERD(v_x, 16), KERD(v_y, 16), DIV(GRAND_T,16)), dim3(16, 16)>>>(
							_m, ___c1, ___c0,
							//
							inst->x_t[0], inst->x_Y[0], x__d[0], dx__d[0],
							//
							inst->p__d, inst->dp__d,
							//
							inst->Y,
							inst->y__d, inst->dy__d,
							//
							ts__d, mega_t,
							//
							_c0, _c1, v_x, v_y, M, C0, C1
						);
					}
				}
			}
		} else*/if (true) {
			d_kerd__matmul1d_canal__simple<<<dim3(KERD((v_y*_c1),16), KERD((GRAND_T*M),16)), dim3(16,16)>>>(
				inst->x_t[0], inst->x_Y[0], x__d[0], dx__d[0],
				//
				inst->p__d, inst->dp__d,
				//
				inst->Y,
				inst->y__d, inst->dy__d,
				//
				ts__d, mega_t,
				//
				_c0, _c1, v_x, v_y, M, C0, C1
			);
		}
	} else {
		//	inst_zero_mega_t(inst, mega_t);
	}
};