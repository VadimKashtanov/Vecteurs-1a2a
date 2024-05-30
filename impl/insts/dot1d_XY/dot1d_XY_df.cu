#include "dot1d_XY.cuh"

template <uint BLOQUE>
static __global__ void d_kerd_f_ax_b__t(
	uint c0,
	//
	float * x0, uint X0_vars, uint X0, uint x0_t, float * dx0,
	//
	float *  y, uint Y__vars, uint  Y, float * dy,
	float *  l, uint L__vars,
	//
	float * p, float * dp,
	//
	uint mega_t,
	//
	uint v_x0, uint v_x1, uint v_y, uint C0,
	//
	uint activ)
{
	// <KERD(T, BLOQUE), KERD(Y,BLOQUE)>
	// <         BLOQUE,         BLOQUE>

	uint thx = threadIdx.x;
	uint thy = threadIdx.y;

	uint _y   = thx + blockIdx.x * blockDim.x;
	uint /*_tc0*/_t = thy + blockIdx.y * blockDim.y;

	//uint _t = _tc0 % GRAND_T;
	//uint c0 = (_tc0 - _t)/GRAND_T;

	uint depart_a0 = c0*(v_x0*v_y + v_y) + 0;
	uint depart__b = c0*(v_x0*v_y + v_y) + v_x0*v_y;
	uint depart__y = c0*v_y;
	uint depart__l = c0*v_y;
	uint depart_x0 = c0*v_x0;

	if (_y < Y && _t < GRAND_T) {
		//
		uint tx0 = t_MODE(_t, mega_t-x0_t);
		uint ty  = t_MODE(_t, mega_t     );
		//
		float _dy = dy[ty*Y__vars + depart__y + _y];
		float  _l =  l[ty*L__vars + depart__l + _y];
		//
		float ds = _dy * _l;
		//
		atomicAdd(&dp[depart__b + _y], ds);
		//
		FOR(0, i, v_x0) {
			//s += x0[tx0*X0_vars + depart_x0 + i] * p[depart_a0 + _y*X0 + i];
			atomicAdd(&dx0[tx0*X0_vars + depart_x0 + i], ds*p[depart_a0 + _y*X0 + i]);
			atomicAdd(&dp [depart_a0  + _y*X0      + i], ds*x0[tx0*X0_vars + depart_x0 + i]);
		}
	}
};

template <uint BLOQUE>
static __global__ void d_kerd_f_ax_bx_c__t(
	uint c0,
	//
	float * x0, uint X0_vars, uint X0, uint x0_t, float * dx0,
	float * x1, uint X1_vars, uint X1, uint x1_t, float * dx1,
	//
	float *  y, uint Y__vars, uint  Y, float * dy,
	float *  l, uint L__vars,
	//
	float * p, float * dp,
	//
	uint mega_t,
	//
	uint v_x0, uint v_x1, uint v_y, uint C0,
	//
	uint activ)
{
	// <KERD(T, BLOQUE), KERD(Y,BLOQUE)>
	// <         BLOQUE,         BLOQUE>

	uint thx = threadIdx.x;
	uint thy = threadIdx.y;

	uint _y = thx + blockIdx.x * blockDim.x;
	uint _t = thy + blockIdx.y * blockDim.y;

	uint depart_a0 = c0*(v_x0*v_y + v_x1*v_y + v_y) + 0;
	uint depart_a1 = c0*(v_x0*v_y + v_x1*v_y + v_y) + v_x0*v_y;
	//
	uint depart__b = c0*(v_x0*v_y + v_x1*v_y + v_y) + v_x0*v_y + v_x1*v_y;
	//
	uint depart__y = c0*v_y;
	uint depart__l = c0*v_y;
	//
	uint depart_x0 = c0*v_x0;
	uint depart_x1 = c0*v_x1;

	if (_y < Y && _t < GRAND_T) {
		//
		uint tx0 = t_MODE(_t, mega_t-x0_t);
		uint tx1 = t_MODE(_t, mega_t-x1_t);
		uint ty  = t_MODE(_t, mega_t     );
		//
		float _dy = dy[ty*Y__vars + depart__y + _y];
		float  _l =  l[ty*L__vars + depart__l + _y];
		//
		float ds = _dy * _l;
		//
		atomicAdd(&dp[depart__b + _y], ds);
		//
		FOR(0, i, v_x0) {
			//s += x0[tx0*X0_vars + depart_x0 + i] * p[depart_a0 + _y*X0 + i];
			atomicAdd(&dx0[tx0*X0_vars + depart_x0 + i], ds*p[depart_a0 + _y*X0 + i]);
			atomicAdd(&dp [depart_a0  + _y*X0      + i], ds*x0[tx0*X0_vars + depart_x0 + i]);
		}

		FOR(0, i, v_x1) {
			//s += x1[tx1*X1_vars + depart_x1 + i] * p[depart_a1 + _y*X1 + i];
			atomicAdd(&dx1[tx1*X1_vars + depart_x1 + i], ds*p[depart_a1 + _y*X1 + i]);
			atomicAdd(&dp [depart_a1  + _y*X1      + i], ds*x1[tx1*X1_vars + depart_x1 + i]);
		}
	}
};

void dot1d_XY__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t) {
	uint * params = inst->params;
	//
	uint \
		C0   =params[0], \
		activ=params[1];
	//
	uint v_x0 = inst->x_Y[0] / C0;
	uint v_x1 = inst->x_Y[1] / C0;
	uint v_y  = inst->Y      / C0;
	//
	uint x0_t = inst->x_t[0];
	uint x1_t = inst->x_t[1];
	uint Y    = inst->Y;
	//
	bool x0_existe = (mega_t != 0 ? true : (x0_t != 1));
	bool x1_existe = (mega_t != 0 ? true : (x1_t != 1));
	//
	uint xs_existants = x0_existe + x1_existe;
	//
	if (xs_existants == 2) {
		FOR(0, c0, C0)
			d_kerd_f_ax_bx_c__t<16><<<dim3(KERD(v_y, 16), KERD(GRAND_T, 16)), dim3(16, 16)>>>(
				c0,
				//
				x__d[0], inst->x_Y[0], v_x0, x0_t, dx__d[0],
				x__d[1], inst->x_Y[1], v_x1, x1_t, dx__d[1],
				//
				inst->y__d, inst->Y, v_y, inst->dy__d,
				inst->l__d, inst->L,
				//
				inst->p__d, inst->dp__d,
				//
				mega_t,
				//
				v_x0, v_x1, v_y, C0,
				//
				activ);
	} else if (xs_existants == 1) {
		uint i0 = (x0_existe ? 0 : 1);
		//
		FOR(0, c0, C0) {
			d_kerd_f_ax_b__t<16><<<dim3(KERD(v_y, 16), KERD(GRAND_T, 16)), dim3(16, 16)>>>(
				c0,
				//
				x__d[i0], inst->x_Y[i0], inst->x_Y[i0]/C0, inst->x_t[i0], dx__d[i0],
				//
				inst->y__d, inst->Y, v_y, inst->dy__d,
				inst->l__d, inst->L,
				//
				inst->p__d, inst->dp__d,
				//
				mega_t,
				//
				v_x0, v_x1, v_y, C0,
				//
				activ);
		}
	} else {
		//	rien
	}
};