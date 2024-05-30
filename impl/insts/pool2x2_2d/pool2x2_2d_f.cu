#include "pool2x2_2d.cuh"

__global__
static void kerd__pool2x2_2d(
	uint x0_t, uint X0, float * x0,
	//
	uint Y,
	float * y,
	//
	uint * ts__d, uint mega_t,
	//
	uint C0, uint im_X, uint im_Y)
{
	//
	uint _x = threadIdx.x + blockIdx.x * blockDim.x;
	uint _y = threadIdx.y + blockIdx.y * blockDim.y;
	uint _t = threadIdx.z + blockIdx.z * blockDim.z;
	//
	uint Y_x = im_X / 2;
	uint Y_y = im_Y / 2;
	//
	if (_y < Y_y && _x < Y_x && _t < GRAND_T) {
		uint tx0 = t_MODE(_t, mega_t-x0_t);
		uint ty  = t_MODE(_t, mega_t     );
		//
		FOR(0, c0, C0) {
			float a = x0[tx0*X0 + c0*im_X*im_Y + (_y*2 + 0)*im_X + (_x*2 + 0)];
			float b = x0[tx0*X0 + c0*im_X*im_Y + (_y*2 + 0)*im_X + (_x*2 + 1)];
			float c = x0[tx0*X0 + c0*im_X*im_Y + (_y*2 + 1)*im_X + (_x*2 + 0)];
			float d = x0[tx0*X0 + c0*im_X*im_Y + (_y*2 + 1)*im_X + (_x*2 + 1)];
			y[ty*Y + c0*Y_x*Y_y + _y*Y_x + _x] = (a+b+c+d) / 4;
		}
	}
};

#define BLK 8

__global__
static void kerd__pool2x2_2d__shared(
	uint x0_t, uint X0, float * x0,
	//
	uint Y,
	float * y,
	//
	uint * ts__d, uint mega_t,
	//
	uint C0, uint im_X, uint im_Y)
{
	//
	uint thx = threadIdx.x + blockIdx.x * blockDim.x;
	uint thy = threadIdx.y + blockIdx.y * blockDim.y;
	//
	uint _x = thx % im_X;	// .x
	uint c0 = (thx-_x)/im_X;// .x
	//
	uint _y = thy % im_Y;	// .y
	uint _t = (thy-_y)/im_Y;// .y
	//
	if (_x < im_X && c0 < C0 && _y < im_Y && _t < GRAND_T) {
		uint tx0 = t_MODE(_t, mega_t-x0_t);
		uint ty  = t_MODE(_t, mega_t     );
		//
		__shared__ float im[BLK][BLK];
		//
		im[threadIdx.y][threadIdx.x] = x0[tx0*X0 + c0*im_X*im_Y + _y*im_X + _x];
		__syncthreads();

		if (threadIdx.x % 2 == 0) {
			im[threadIdx.y][threadIdx.x] = im[threadIdx.y][threadIdx.x] + im[threadIdx.y][threadIdx.x+1];
		}
		__syncthreads();

		if (threadIdx.x % 2 == 0 && threadIdx.y % 2 == 0) {
			float res = im[threadIdx.y][threadIdx.x] + im[threadIdx.y+1][threadIdx.x];
			y[ty*Y + c0*im_X/2*im_Y/2 + (_y/2)*im_X/2 + (_x/2)] = res / 4;
		}
		__syncthreads();
	}
};

void pool2x2_2d__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t) {
	uint * params = inst->params;
	uint \
		C0  =params[0],	\
		im_X=params[1],	\
		im_Y=params[2];
	//
	uint Y_x = im_X / 2;
	uint Y_y = im_Y / 2;
	//
	uint X0 = inst->x_Y[0];	uint x0_t = inst->x_t[0];
	uint Y  = inst->Y;
	//
	bool x0_existe = (mega_t != 0 ? true : (x0_t != 1));
	//
	uint xs_existants = x0_existe;
	//
	if (xs_existants == 1) {
		if (true) {
			kerd__pool2x2_2d__shared<<<dim3(KERD(C0*im_X,BLK), KERD(im_Y*GRAND_T,BLK)), dim3(BLK,BLK)>>>(
				x0_t, X0, x__d[0],
				//
				inst->Y,
				inst->y__d,
				//
				ts__d, mega_t,
				//
				C0, im_X, im_Y
			);
		} else {
			kerd__pool2x2_2d<<<dim3(KERD(Y_x,8), KERD(Y_y,8), KERD(GRAND_T,8)), dim3(8,8,8)>>>(
				x0_t, X0, x__d[0],
				//
				inst->Y,
				inst->y__d,
				//
				ts__d, mega_t,
				//
				C0, im_X, im_Y
			);
		}
	} else {
		inst_zero_mega_t(inst, mega_t);
	}
};