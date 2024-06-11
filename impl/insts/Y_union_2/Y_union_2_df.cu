#include "Y.cuh"

__global__
static void d_kerd__Y_union_2(
	uint x0_t, uint X0, float * x0, float * dx0,
	uint x1_t, uint X1, float * x1, float * dx1,
	//
	uint    Y,
	float * y, float * dy,
	//
	uint mega_t)
{
	uint _y = threadIdx.x + blockIdx.x * blockDim.x;
	uint _t = threadIdx.y + blockIdx.y * blockDim.y;
	//
	if (_y < Y && _t < GRAND_T) {
		uint tx0 = t_MODE(_t, mega_t-x0_t);
		uint tx1 = t_MODE(_t, mega_t-x1_t);
		uint ty  = t_MODE(_t, mega_t     );
		//
		if (_y < X0) {
			atomicAdd(&dx0[tx0*X0 + _y], dy[ty*Y + _y]);
		} else {
			atomicAdd(&dx1[tx1*X1 + _y-X0], dy[ty*Y + _y]);
		}
	};
};

void Y_union_2__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t) {
	uint x0_t = inst->x_t[0];
	uint x1_t = inst->x_t[1];	
	uint Y  = inst->Y;
	//
	bool x0_existe = (mega_t != 0 ? true : (x0_t != 1));
	//
	if (x0_existe) {
		d_kerd__Y_union_2<<<dim3(KERD(Y,16), KERD(GRAND_T,8)), dim3(16,8)>>>(
			inst->x_t[0], inst->x_Y[0], x__d[0], dx__d[0],
			inst->x_t[1], inst->x_Y[1], x__d[1], dx__d[1],
			//
			inst->Y,
			inst->y__d, inst->dy__d,
			//
			mega_t
		);
	} else {
		//	rien
	}
};