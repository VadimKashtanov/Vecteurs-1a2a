#include "kconvl1d_stricte.cuh"

static __global__ void kerd__kconvl2d_stricte___simple(
	uint x0_t, uint X0, float * x0,
	//
	float * p,
	//
	uint    Y,
	float * y,
	//
	uint * ts__d, uint mega_t,
	//
	uint K, uint C0, uint C1, uint im_X)
{
	uint so_X = im_X;
	//
	int N = ((int)(K-1))/2;
	//
	uint _x  = threadIdx.x + blockIdx.x * blockDim.x;
	uint _c1t = threadIdx.y + blockIdx.y * blockDim.y;
	//
	uint c1 = _c1t%C1;
	uint _t = (_c1t-c1)/C1;
	//
	if (_x < so_X && c1 < C1 && _t < GRAND_T) {
		uint tx0 = t_MODE(_t, mega_t-x0_t);
		uint ty  = t_MODE(_t, mega_t     );
		//
		float s = 0;
		//
		FOR(0, c0, C0) {
			for (int kx=-N; kx < N+1; kx++) {
				int xx = _x + kx;
				if (0 <= xx && xx < im_X) {
					s += x0[tx0*X0 + c0*im_X + xx] * p[c1*C0*K + c0*K + (N+kx)];
				}
			}
		}
		y[ty*Y + c1*so_X + _x] = s;// / (float)C0;
	}
};

void kconvl1d_stricte__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t) {
	uint * params = inst->params;
	uint \
		K   =params[0],
		C0  =params[1],
		C1  =params[2],
		im_X=params[3];
	//
	uint N = (K-1)/2;
	//
	uint x0_t = inst->x_t[0];
	uint Y  = inst->Y;
	//
	bool x0_existe = (mega_t != 0 ? true : (x0_t != 1));
	//
	if (x0_existe) {
		kerd__kconvl2d_stricte___simple<<<dim3(KERD((im_X),16), KERD((C1*GRAND_T),8)), dim3(16,8)>>>(
			inst->x_t[0], inst->x_Y[0], x__d[0],
			//
			inst->p__d,
			//
			inst->Y,
			inst->y__d,
			//
			ts__d, mega_t,
			K, C0, C1, im_X);
	} else {
		inst_zero_mega_t(inst, mega_t);
	}
};