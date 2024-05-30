#include "biais.cuh"

__global__
static void kerd__biais(
	float * p,
	//
	uint    Y,
	float * y,
	//
	uint mega_t)
{
	uint thx = threadIdx.x + blockIdx.x * blockDim.x;
	uint thy = threadIdx.y + blockIdx.y * blockDim.y;
	//
#define _y thx
#define _t thy
	//
	if (_y < Y && _t < GRAND_T) {
		uint ty  = t_MODE(_t, mega_t);
		
		y[ty*Y + _y] = p[_y];
	};
};

void biais__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t) {
	uint Y = inst->Y;
	kerd__biais<<<dim3(KERD(Y,16), KERD(GRAND_T,16)), dim3(16,16)>>>(
		inst->p__d,
		//
		inst->Y,
		inst->y__d,
		//
		mega_t
	);
};