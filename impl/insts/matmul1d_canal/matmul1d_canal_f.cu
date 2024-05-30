#include "matmul1d_canal.cuh"

static __global__ void kerd__matmul1d_canal__simple(
	uint x0_t, uint X0, float * x0,
	//
	float * p,
	//
	uint    Y,
	float * y,
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
		float s = 0;
		uint pos_y = _m*_c1*v_y + ___c1*v_y + __v_y;
		FOR(0, __c0, _c0) {
			//	mat mul v_x;v_y
			FOR(0, i, v_x) {
				//	s += x0[i]
				uint pos_x0 = tx0*X0 + _m*_c0*v_x + __c0*v_x + i;
				uint pos_p  = pos_y*v_x*_c0 + __c0*v_x + i;
				//
				s += x0[pos_x0] * p[pos_p];
			}

		}
		//printf("%i %f\n", ty*Y + _m*_c1*v_y + ___c1*v_y + __v_y, s);
		y[ty*Y + pos_y] = s;
	}
};

//	---------------------------------------------------------------------------------

void matmul1d_canal__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t) {
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
		if (true) {
			kerd__matmul1d_canal__simple<<<dim3(KERD((v_y*_c1),16), KERD((GRAND_T*M),16)), dim3(16,16)>>>(
				inst->x_t[0], inst->x_Y[0], x__d[0],
				//
				inst->p__d,
				//
				inst->Y,
				inst->y__d,
				//
				ts__d, mega_t,
				//
				_c0, _c1, v_x, v_y, M, C0, C1
			);
		}
	} else {
		inst_zero_mega_t(inst, mega_t);
	}
};