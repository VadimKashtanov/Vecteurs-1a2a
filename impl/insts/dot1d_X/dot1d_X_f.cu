#include "dot1d_X.cuh"

template <uint BLOQUE>
static __global__ void kerd_f_ax_b__t(
	uint c0,
	//
	float * x0, uint X0_vars, uint X0, uint x0_t,
	//
	float *  y, uint Y__vars, uint  Y,
	float *  l, uint L__vars,
	//
	float * p,
	//
	uint mega_t,
	//
	uint v_x0, uint v_y, uint C0,
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

	if (_y < Y) {
		//
		uint tx0 = t_MODE(_t, mega_t-x0_t);
		uint ty  = t_MODE(_t, mega_t     );

		float s = p[depart__b + _y];
		//
		FOR(0, i, v_x0) {
			s += x0[tx0*X0_vars + depart_x0 + i] * p[depart_a0 + _y*X0 + i];
		}
		//
		f2 a_da = ACTIVATION_f_df(activ, s);
		float a  = a_da.f0;
		float da = a_da.f1;
		//
		y[ty*Y__vars + depart__y + _y] =  a;
		l[ty*L__vars + depart__l + _y] = da;
	}
};

template <uint BLOQUE>
static __global__ void kerd_f_ax_b__shared_16__t(
	float * x0, uint X0_vars, uint X0, uint x0_t,
	//
	float *  y, uint Y__vars, uint  Y,
	float *  l, uint L__vars,
	//
	float * p,
	//
	uint mega_t,
	//
	uint v_x0, uint v_y, uint C0,
	//
	uint activ)
{
	// <KERD(T, BLOQUE), KERD(Y,BLOQUE)>
	// <         BLOQUE,         BLOQUE>

	__shared__ float __partage__x[BLOQUE][BLOQUE];
	__shared__ float __partage__p[BLOQUE][BLOQUE];

	uint thx = threadIdx.x;
	uint thy = threadIdx.y;

	uint _y   = thx + blockIdx.x * blockDim.x;
	uint _tc0 = thy + blockIdx.y * blockDim.y;

	uint _t = _tc0 % GRAND_T;
	uint c0 = (_tc0 - _t)/GRAND_T;

	uint depart_a0 = c0*(v_x0*v_y + v_y) + 0;
	uint depart__b = c0*(v_x0*v_y + v_y) + v_x0*v_y;
	uint depart__y = c0*v_y;
	uint depart__l = c0*v_y;
	uint depart_x0 = c0*v_x0;

	//
	uint tx0 = t_MODE(_t, mega_t-x0_t);
	uint ty  = t_MODE(_t, mega_t     );

	float s = 0;

	//	+a0@x0
	FOR(0, d, X0/BLOQUE) {
		__partage__x[thy][thx] = x0[tx0*X0_vars + depart_x0 + (d*BLOQUE + thx)];
		__partage__p[thy][thx] = p[depart_a0 + _y*X0 + (d*BLOQUE + thy)];
		__syncthreads();

	#pragma unroll
			FOR(0, i, BLOQUE) s += __partage__x[thy][i] * __partage__p[i][thx];
			__syncthreads();
		};

	//	+b
	#define __partage__b __partage__x[0]
	if (thy == 0) {
		__partage__b[thx] = p[depart__b + _y];
	}
	__syncthreads();
	
	s = (s + __partage__b[thx]);
	//
	f2 a_da = ACTIVATION_f_df(activ, s);
	float a  = a_da.f0;
	float da = a_da.f1;
	//
	y[ty*Y__vars + depart__y + _y] =  a;
	l[ty*L__vars + depart__l + _y] = da;
};

void dot1d_X__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t) {
	uint * params = inst->params;
	//
	uint \
		C0   =params[0], \
		activ=params[1];
	//
	uint v_x0 = inst->x_Y[0] / C0;
	uint v_y  = inst->Y      / C0;
	//
	uint x0_t = inst->x_t[0];
	uint Y    = inst->Y;
	//
	bool x0_existe = (mega_t != 0 ? true : (x0_t != 1));
	//
	uint xs_existants = x0_existe;
	//
	if (xs_existants == 1) {
		if (v_y % 16 == 0 && GRAND_T % 16 == 0) {
			kerd_f_ax_b__shared_16__t<16><<<dim3(KERD(v_y, 16), KERD(GRAND_T*C0, 16)), dim3(16, 16)>>>(
				x__d[0], inst->x_Y[0], v_x0, x0_t,
				//
				inst->y__d, inst->Y, v_y,
				inst->l__d, inst->L,
				//
				inst->p__d,
				//
				mega_t,
				//
				v_x0, v_y, C0,
				//
				activ);
		} else {
			FOR(0, c0, C0)
				kerd_f_ax_b__t<16><<<dim3(KERD(v_y, 16), KERD(GRAND_T*C0, 16)), dim3(16, 16)>>>(
					c0,
					//
					x__d[0], inst->x_Y[0], v_x0, x0_t,
					//
					inst->y__d, inst->Y, v_y,
					inst->l__d, inst->L,
					//
					inst->p__d,
					//
					mega_t,
					//
					v_x0, v_y, C0,
					//
					activ);
		};
	} else {
		inst_zero_mega_t(inst, mega_t);
	}
};