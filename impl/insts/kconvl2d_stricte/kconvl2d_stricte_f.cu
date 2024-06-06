#include "kconvl2d_stricte.cuh"

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
	uint K, uint C0, uint C1, uint im_X, uint im_Y)
{
	uint so_X = im_X;
	uint so_Y = im_Y;
	//
	int N = ((int)(K-1))/2;
	//
	uint _xy  = threadIdx.x + blockIdx.x * blockDim.x;
	uint _c1t = threadIdx.y + blockIdx.y * blockDim.y;
	//
	uint _x = _xy%im_X;
	uint _y = (_xy-_x)/im_X;
	//
	uint c1 = _c1t%C1;
	uint _t = (_c1t-c1)/C1;
	//
	if (_y < so_Y && _x < so_X && c1 < C1 && _t < GRAND_T) {
		uint tx0 = t_MODE(_t, mega_t-x0_t);
		uint ty  = t_MODE(_t, mega_t     );
		//
		float s = 0;
		//
		FOR(0, c0, C0) {
			for (int kx=-N; kx < N+1; kx++) {
				for (int ky=-N; ky < N+1; ky++) {
					int xx = _x + kx;
					int xy = _y + ky;
					if (0 <= xx && xx < im_X && 0 <= xy && xy < im_Y) {
						s += x0[tx0*X0 + c0*im_X*im_Y + xy*im_X + xx] * p[c1*C0*K*K + c0*K*K + (N+ky)*K + (N+kx)];
					}
				}
			}
		}
		y[ty*Y + c1*so_X*so_Y + _y*so_X + _x] = s;// / C0;
	}
};

static __global__ void kerd__kconvl2d_stricte___c0_thz_8(
	uint x0_t, uint X0, float * x0,
	//
	float * p,
	//
	uint    Y,
	float * y,
	//
	uint * ts__d, uint mega_t,
	//
	uint K, uint C0, uint C1, uint im_X, uint im_Y)
{
	uint so_X = im_X;
	uint so_Y = im_Y;
	//
	int N = ((int)(K-1))/2;
	//
	uint _xy  = threadIdx.x + blockIdx.x * blockDim.x;
	uint _c1t = threadIdx.y + blockIdx.y * blockDim.y;
	uint thz  = threadIdx.z;
	//
	uint _x = _xy%im_X;
	uint _y = (_xy-_x)/im_X;
	//
	uint c1 = _c1t%C1;
	uint _t = (_c1t-c1)/C1;
	//
	if (_y < so_Y && _x < so_X && c1 < C1 && _t < GRAND_T) {
		uint tx0 = t_MODE(_t, mega_t-x0_t);
		uint ty  = t_MODE(_t, mega_t     );
		//
		float s = 0;
		//
		__shared__ float __y[16][8];
		if (thz == 0) __y[threadIdx.y][threadIdx.x] = 0;
		__syncthreads();
		//
		FOR(0, _c0, C0/8) {
			uint c0 = _c0*8 + thz;
			for (int kx=-N; kx < N+1; kx++) {
				for (int ky=-N; ky < N+1; ky++) {
					int xx = _x + kx;
					int xy = _y + ky;
					if (0 <= xx && xx < im_X && 0 <= xy && xy < im_Y) {
						s += x0[tx0*X0 + c0*im_X*im_Y + xy*im_X + xx] * p[c1*K*K*C0 + c0*K*K + (N+ky)*K + (N+kx)];
					}
				}
			}
			atomicAdd(&__y[threadIdx.y][threadIdx.x], s);
			__syncthreads();
		}

		if (thz == 0) y[ty*Y + c1*so_X*so_Y + _y*so_X + _x] = __y[threadIdx.y][threadIdx.x];
	}
};

void kconvl2d_stricte__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t) {
	uint * params = inst->params;
	uint \
		K   =params[0],
		C0  =params[1],
		C1  =params[2],
		im_X=params[3],
		im_Y=params[4];
	//
	uint N = (K-1)/2;
	//
	uint x0_t = inst->x_t[0];
	uint Y  = inst->Y;
	//
	bool x0_existe = (mega_t != 0 ? true : (x0_t != 1));
	//
	if (x0_existe) {
		if (C0 % 8 == 0 && false) {
			kerd__kconvl2d_stricte___c0_thz_8<<<dim3(KERD((im_X*im_Y),16), KERD((C1*GRAND_T),8), 1), dim3(16,8,8)>>>(
				inst->x_t[0], inst->x_Y[0], x__d[0],
				//
				inst->p__d,
				//é
				inst->Y,
				inst->y__d,
				//
				ts__d, mega_t,
				K, C0, C1, im_X, im_Y);
		} else {
			kerd__kconvl2d_stricte___simple<<<dim3(KERD((im_X*im_Y),16), KERD((C1*GRAND_T),8)), dim3(16,8)>>>(
				inst->x_t[0], inst->x_Y[0], x__d[0],
				//
				inst->p__d,
				//
				inst->Y,
				inst->y__d,
				//
				ts__d, mega_t,
				K, C0, C1, im_X, im_Y);
		}
	} else {
		inst_zero_mega_t(inst, mega_t);
	}
};