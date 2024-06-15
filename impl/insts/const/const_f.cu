#include "const.cuh"

__global__
static void kerd__const(
	uint    Y,
	float * y,
	//
	uint mega_t,
	//
	float constante)
{
	uint thx = threadIdx.x + blockIdx.x * blockDim.x;
	uint thy = threadIdx.y + blockIdx.y * blockDim.y;
	//
#define _y thx
#define _t thy
	//
	if (_y < Y && _t < GRAND_T) {
		uint ty  = t_MODE(_t, mega_t);
		
		y[ty*Y + _y] = constante;
	};
};

void const__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t) {
	uint Y = inst->Y;
	//
	float constante = (float)inst->params[0];
	//
	kerd__const<<<dim3(KERD(Y,16), KERD(GRAND_T,16)), dim3(16,16)>>>(
		inst->Y,
		inst->y__d,
		//
		mega_t,
		//
		constante
	);
};