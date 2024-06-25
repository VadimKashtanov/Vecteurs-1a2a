#include "cadrans_pondérés.cuh"

static __global__ void d_kerd__cadrans_ponderes__simple(
	uint x0_t, uint X0, float * x0, float * dx0,
	//
	float * p, float * dp,
	//
	uint    Y,             uint    L,
	float * y, float * dy, float * l,
	//
	uint * ts__d, uint mega_t,
	//
	uint Cx, uint C0, uint C1)
{
	uint thx = threadIdx.x + blockIdx.x * blockDim.x;
	uint thy = threadIdx.y + blockIdx.y * blockDim.y;

	//	thx = Cx*C1
	uint _cx = thx % Cx;
	uint _c1 = (thx-_cx)/Cx;

	//	thy = GRAND_T
	uint _t = thy;

	if (_cx < Cx && _c1 < C1 && _t < GRAND_T) {
		uint tx0 = t_MODE(_t, mega_t-x0_t);
		uint ty  = t_MODE(_t, mega_t     );
		//
		uint pos_y = ty*Y + _c1*Cx + _cx;
		//
		//float normalisation =  l[2*pos_y+0];
		//float s             =  l[2*pos_y+1];
		//
		float _dy           = dy[pos_y];
		//
		float ds = _dy;// / normalisation;
		//float dn = -_dy * s / (normalisation*normalisation);
		//
		FOR(0, _c0, C0) {
			uint pos_x0 = tx0*C0*Cx + _c0*Cx + _cx;
			uint pos_p  = _c1*C0*Cx + _cx*C0 + _c0;
			//
			//normalisation += p[pos_p];
			//atomicAdd(&dp[pos_p], dn);
			//
			//s += x0[pos_x0] * p[pos_p];
			atomicAdd(&dx0[pos_x0],  p[pos_p ] * ds);
			atomicAdd(&dp [pos_p ], x0[pos_x0] * ds);
		};
	}
};

//	---------------------------------------------------------------------------------

void cadrans_pondérés__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t) {
	uint * params = inst->params;
	uint \
		Cx=params[0],	\
		C0=params[1],	\
		C1=params[2];
	//
	uint x0_t = inst->x_t[0];
	uint Y    = inst->Y;
	//
	bool x0_existe = (mega_t != 0 ? true : (x0_t != 1));
	//
	if (x0_existe) {
		d_kerd__cadrans_ponderes__simple<<<dim3(KERD((Cx*C1),16), KERD(GRAND_T,16)), dim3(16,16)>>>(
			inst->x_t[0], inst->x_Y[0], x__d[0], dx__d[0],
			//
			inst->p__d, inst->dp__d,
			//
			inst->Y,                 inst->L,
			inst->y__d, inst->dy__d, inst->l__d,
			//
			ts__d, mega_t,
			//
			Cx, C0, C1
		);
	} else {
		//inst_zero_mega_t(inst, mega_t);
	}
};