#include "pool2_1d.cuh"

__global__
static void d_kerd__pool2_1d(
	uint x0_t, uint X0, float * x0, float * dx0,
	//
	uint Y,
	float * y, float * dy,
	//
	uint * ts__d, uint mega_t,
	//
	uint C0, uint im_X)
{
	//
	uint _x = threadIdx.x + blockIdx.x * blockDim.x;
	uint _t = threadIdx.y + blockIdx.y * blockDim.y;
	//
	uint Y_x = im_X / 2;
	//
	if (_x < Y_x && _t < GRAND_T) {
		uint tx0 = t_MODE(_t, mega_t-x0_t);
		uint ty  = t_MODE(_t, mega_t     );
		//
		FOR(0, c0, C0) {
			//float a = x0[tx0*X0 + c0*im_X + (_x*2 + 0)];
			//float b = x0[tx0*X0 + c0*im_X + (_x*2 + 1)];
			float ds = dy[ty*Y + c0*Y_x + _x] / 2;
			atomicAdd(&dx0[tx0*X0 + c0*im_X + (_x*2 + 0)], ds);
			atomicAdd(&dx0[tx0*X0 + c0*im_X + (_x*2 + 1)], ds);
		}
	}
};

void pool2_1d__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t) {
	uint * params = inst->params;
	uint \
		C0  =params[0],	\
		im_X=params[1];
	//
	uint Y_x = im_X / 2;
	//
	uint X0 = inst->x_Y[0];	uint x0_t = inst->x_t[0];
	uint Y  = inst->Y;
	//
	bool x0_existe = (mega_t != 0 ? true : (x0_t != 1));
	//
	uint xs_existants = x0_existe;
	//
	if (x0_existe) {
		d_kerd__pool2_1d<<<dim3(KERD(Y_x,16), KERD(GRAND_T,16)), dim3(16,16)>>>(
			x0_t, X0, x__d[0], dx__d[0],
			//
			inst->Y,
			inst->y__d, inst->dy__d,
			//
			ts__d, mega_t,
			//
			C0, im_X
		);
	} else {
		//	rien
	}
};