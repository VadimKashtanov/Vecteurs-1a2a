#include "somme3.cuh"

__global__
static void d_kerd__somme1(
	uint x0_t, uint X0, float * x0, float * dx0,
	//
	uint    Y,
	float * y, float * dy,
	//
	uint * ts__d, uint mega_t)
{
	//
	uint _y = threadIdx.x + blockIdx.x * blockDim.x;
	uint _t = threadIdx.y + blockIdx.y * blockDim.y;
	//
	if (_y < Y && _t < GRAND_T) {
		uint tx0 = t_MODE(_t, mega_t-x0_t);
		uint ty  = t_MODE(_t, mega_t     );
		//
		//y[ty*Y + _y] = x0[tx0*X0 + _y];
		float __dy = dy[ty*Y + _y];
		atomicAdd(&dx0[tx0*X0 + _y], 1 * __dy);
	}
};

__global__
static void d_kerd__somme2(
	uint x0_t, uint X0, float * x0, float * dx0,
	uint x1_t, uint X1, float * x1, float * dx1,
	//
	uint    Y,
	float * y, float * dy,
	//
	uint * ts__d, uint mega_t)
{
	//
	uint _y = threadIdx.x + blockIdx.x * blockDim.x;
	uint _t = threadIdx.y + blockIdx.y * blockDim.y;
	//
	if (_y < Y && _t < GRAND_T) {
		uint tx0 = t_MODE(_t, mega_t-x0_t);
		uint tx1 = t_MODE(_t, mega_t-x1_t);
		uint ty  = t_MODE(_t, mega_t     );
		//
		//y[ty*Y + _y] = x0[tx0*X0 + _y] + x1[tx1*X1 + _y];
		float __dy = dy[ty*Y + _y];
		atomicAdd(&dx0[tx0*X0 + _y], 1 * __dy);
		atomicAdd(&dx1[tx1*X1 + _y], 1 * __dy);
	}
};

__global__
static void d_kerd__somme3(
	uint x0_t, uint X0, float * x0, float * dx0,
	uint x1_t, uint X1, float * x1, float * dx1,
	uint x2_t, uint X2, float * x2, float * dx2,
	//
	uint    Y,
	float * y, float * dy,
	//
	uint * ts__d, uint mega_t)
{
	//
	uint _y = threadIdx.x + blockIdx.x * blockDim.x;
	uint _t = threadIdx.y + blockIdx.y * blockDim.y;
	//
	if (_y < Y && _t < GRAND_T) {
		uint tx0 = t_MODE(_t, mega_t-x0_t);
		uint tx1 = t_MODE(_t, mega_t-x1_t);
		uint tx2 = t_MODE(_t, mega_t-x2_t);
		uint ty  = t_MODE(_t, mega_t     );
		//
		//y[ty*Y + _y] = x0[tx0*X0 + _y] + x1[tx1*X1 + _y] + x2[tx2*X2 + _y];
		float __dy = dy[ty*Y + _y];
		atomicAdd(&dx0[tx0*X0 + _y], 1 * __dy);
		atomicAdd(&dx1[tx1*X1 + _y], 1 * __dy);
		atomicAdd(&dx2[tx2*X2 + _y], 1 * __dy);
	}
};

void somme3__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t) {
	uint X0 = inst->x_Y[0];	uint x0_t = inst->x_t[0];
	uint X1 = inst->x_Y[1];	uint x1_t = inst->x_t[1];
	uint X2 = inst->x_Y[2];	uint x2_t = inst->x_t[2];
	uint Y  = inst->Y;
	//
	bool x0_existe = (mega_t != 0 ? true : (x0_t != 1));
	bool x1_existe = (mega_t != 0 ? true : (x1_t != 1));
	bool x2_existe = (mega_t != 0 ? true : (x2_t != 1));
	//
	uint xs_existants = x0_existe + x1_existe + x2_existe;
	//
	if (xs_existants == 3) {
		uint existe[3] = {x0_existe, x1_existe, x2_existe};
		//
		uint _i0 = INDEX3(existe[0], existe[1], existe[2], 1);
		FOR(0, i, 3) if (i != _i0 && existe[i] != 0) existe[i] += 1;
		uint _i1 = INDEX3(existe[0], existe[1], existe[2], 2);
		FOR(0, i, 3) if (i != _i1 && existe[i] != 0) existe[i] += 1;
		uint _i2 = INDEX3(existe[0], existe[1], existe[2], 3);
		//
		d_kerd__somme3<<<dim3(KERD(Y,16), KERD(GRAND_T,16)), dim3(16,16)>>>(
			inst->x_t[_i0], inst->x_Y[_i0], x__d[_i0], dx__d[_i0],
			inst->x_t[_i1], inst->x_Y[_i1], x__d[_i1], dx__d[_i1],
			inst->x_t[_i2], inst->x_Y[_i2], x__d[_i2], dx__d[_i2],
			//
			inst->Y,
			inst->y__d, inst->dy__d,
			//
			ts__d, mega_t
		);
	} else if (xs_existants == 2) {
		uint existe[3] = {x0_existe, x1_existe, x2_existe};
		//
		uint _i0 = INDEX3(existe[0], existe[1], existe[2], 1);
		FOR(0, i, 3) if (i != _i0 && existe[i] != 0) existe[i] += 1;
		uint _i1 = INDEX3(existe[0], existe[1], existe[2], 2);
		//
		d_kerd__somme2<<<dim3(KERD(Y,16), KERD(GRAND_T,16)), dim3(16,16)>>>(
			inst->x_t[_i0], inst->x_Y[_i0], x__d[_i0], dx__d[_i0],
			inst->x_t[_i1], inst->x_Y[_i1], x__d[_i1], dx__d[_i1],
			//
			inst->Y,
			inst->y__d, inst->dy__d,
			//
			ts__d, mega_t
		);
	} else if (xs_existants == 1) {
		uint existe[3] = {x0_existe, x1_existe, x2_existe};
		//
		uint _i0 = INDEX3(existe[0], existe[1], existe[2], 1);
		//
		d_kerd__somme1<<<dim3(KERD(Y,16), KERD(GRAND_T,16)), dim3(16,16)>>>(
			inst->x_t[_i0], inst->x_Y[_i0], x__d[_i0], dx__d[_i0],
			//
			inst->Y,
			inst->y__d, inst->dy__d,
			//
			ts__d, mega_t
		);
	} else if (xs_existants == 0) {
		//	inst_zero_mega_t(inst, mega_t);
	}
};