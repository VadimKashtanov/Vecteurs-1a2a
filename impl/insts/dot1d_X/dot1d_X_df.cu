#include "dot1d_X.cuh"

template <uint BLOQUE>
static __global__ void d_kerd_f_ax_b__shared_16___dX(
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
	uint v_x0, uint v_y, uint C0,
	//
	uint activ)
{
	//dx = (p @ ((y-_y)*dtanh(x@p)).T).T

	__shared__ float __partage__x[BLOQUE][BLOQUE];
	__shared__ float __partage__p[BLOQUE][BLOQUE];

	uint thx = threadIdx.x;
	uint thy = threadIdx.y;

	uint _x = thx + blockIdx.x * blockDim.x;
	//uint _tc0 = thy + blockIdx.y * blockDim.y;
	uint _t = thy + blockIdx.y * blockDim.y;

	//uint _t = _tc0 % GRAND_T;
	//uint c0 = (_tc0 - _t)/GRAND_T;
	
	uint depart_a0 = c0*(v_x0*v_y + v_y) + 0;
	uint depart__b = c0*(v_x0*v_y + v_y) + v_x0*v_y;
	uint depart__y = c0*v_y;
	uint depart__l = c0*v_y;
	uint depart_x0 = c0*v_x0;

 	//
	uint tx0 = t_MODE(_t, mega_t-x0_t);
	uint ty  = t_MODE(_t, mega_t     );

	float s = 0;

	FOR(0, d, Y/BLOQUE) {
		float _l  =  l[ty*L__vars + depart__l + (d*BLOQUE+thx)];
		float _dy = dy[ty*Y__vars + depart__y + (d*BLOQUE+thx)];
		__partage__x[thy][thx] =  _l * _dy;
		__partage__p[thy][thx] = p[depart_a0 + (d*BLOQUE+thy)*X0 + _x];
		__syncthreads();

#pragma unroll
		FOR(0, i, BLOQUE) s += __partage__x[thy][i] * __partage__p[i][thx];
		__syncthreads();
	};

	atomicAdd(&dx0[tx0*X0_vars + depart_x0 + _x], s);
};

template <uint BLOQUE>
static __global__ void d_kerd_f_ax_b__shared_16___dA(
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
	uint v_x0, uint v_y, uint C0,
	//
	uint activ)
{
	//dp = x.T @ ((y-_y)*dtanh(x@p))

	__shared__ float __partage__x[BLOQUE][BLOQUE];
	__shared__ float __partage__p[BLOQUE][BLOQUE];

	uint thx = threadIdx.x;
	uint thy = threadIdx.y;

	uint _x = thx + blockIdx.x * blockDim.x;
	//uint _xc0 = thx + blockIdx.x * blockDim.x;
	uint _y = thy + blockIdx.y * blockDim.y;

	//uint _x = _xc0 % X0;
	//uint c0 = (_xc0 - _x)/X0;
	
	uint depart_a0 = c0*(v_x0*v_y + v_y) + 0;
	uint depart__b = c0*(v_x0*v_y + v_y) + v_x0*v_y;
	uint depart__y = c0*v_y;
	uint depart__l = c0*v_y;
	uint depart_x0 = c0*v_x0;

 	//
	float s = 0;

	uint d = blockIdx.z;
	//FOR(0, d, T/BLOQUE) {
	//assert((d*BLOQUE+thy) < GRAND_T);
		uint tx0 = t_MODE((d*BLOQUE+thy), mega_t-x0_t);
		uint ty  = t_MODE((d*BLOQUE+thx), mega_t     );
		//
		float __l =  l[ty*L__vars + depart__l + _y];
		float _dy = dy[ty*Y__vars + depart__y + _y];
		__partage__x[thy][thx] = __l * _dy;
		__partage__p[thy][thx] = x0[tx0*X0_vars + depart_x0 + _x];
		__syncthreads();

	#pragma unroll
		FOR(0, i, BLOQUE) {
			s += __partage__x[thy][i] * __partage__p[i][thx];
		}
		__syncthreads();
	//};

	atomicAdd(&dp[depart_a0 + _y*X0 + _x], s);
};

template <uint BLOQUE>
static __global__ void d_kerd_f_ax_b__shared_16___db(
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
	uint v_x0, uint v_y, uint C0,
	//
	uint activ)
{
	uint _y = threadIdx.x + blockIdx.x * blockDim.x;
	//uint _tc0 = threadIdx.y + blockIdx.y * blockDim.y;
	uint _t = threadIdx.y + blockIdx.y * blockDim.y;

	//uint _t = _tc0 % GRAND_T;
	//uint c0 = (_tc0 - _t)/GRAND_T;
	
	uint depart_a0 = c0*(v_x0*v_y + v_y) + 0;
	uint depart__b = c0*(v_x0*v_y + v_y) + v_x0*v_y;
	uint depart__y = c0*v_y;
	uint depart__l = c0*v_y;
	uint depart_x0 = c0*v_x0;

 	//
	uint tx0 = t_MODE(_t, mega_t-x0_t);
	uint ty  = t_MODE(_t, mega_t     );

	float _l  =  l[ty*L__vars + depart__l + _y];
	float _dy = dy[ty*Y__vars + depart__y + _y];
	atomicAdd(&dp[depart__b + _y], _l * _dy);
};

//	==========================================================

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

void dot1d_X__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t) {
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
	if (x0_existe) {
		if (v_y % 16 == 0 && GRAND_T % 16 == 0) {
			FOR(0, c0, C0) {
				d_kerd_f_ax_b__shared_16___dX<16><<<dim3(KERD(v_x0, 16), KERD(GRAND_T, 16)), dim3(16, 16)>>>(
					c0,
					//
					x__d[0], inst->x_Y[0], v_x0, x0_t, dx__d[0],
					//
					inst->y__d, inst->Y, v_y, inst->dy__d,
					inst->l__d, inst->L,
					//
					inst->p__d, inst->dp__d,
					//
					mega_t,
					//
					v_x0, v_y, C0,
					//
					activ);
				d_kerd_f_ax_b__shared_16___dA<16><<<dim3(KERD(v_x0, 16), KERD(v_y, 16), DIV(GRAND_T,16)), dim3(16, 16, 1)>>>(
					c0,
					//
					x__d[0], inst->x_Y[0], v_x0, x0_t, dx__d[0],
					//
					inst->y__d, inst->Y, v_y, inst->dy__d,
					inst->l__d, inst->L,
					//
					inst->p__d, inst->dp__d,
					//
					mega_t,
					//
					v_x0, v_y, C0,
					//
					activ);
				d_kerd_f_ax_b__shared_16___db<16><<<dim3(KERD(v_y, 16), KERD(GRAND_T,16)), dim3(16, 16)>>>(
					c0,
					//
					x__d[0], inst->x_Y[0], v_x0, x0_t, dx__d[0],
					//
					inst->y__d, inst->Y, v_y, inst->dy__d,
					inst->l__d, inst->L,
					//
					inst->p__d, inst->dp__d,
					//
					mega_t,
					//
					v_x0, v_y, C0,
					//
					activ);
			}
		} else {
			FOR(0, c0, C0) {
				d_kerd_f_ax_b__t<16><<<dim3(KERD(v_y, 16), KERD(GRAND_T, 16)), dim3(16, 16)>>>(
					c0,
					x__d[0], inst->x_Y[0], v_x0, x0_t, dx__d[0],
					//
					inst->y__d, inst->Y, v_y, inst->dy__d,
					inst->l__d, inst->L,
					//
					inst->p__d, inst->dp__d,
					//
					mega_t,
					//
					v_x0, v_y, C0,
					//
					activ);
			}
		}
	} else {
		//	rien
	}
};