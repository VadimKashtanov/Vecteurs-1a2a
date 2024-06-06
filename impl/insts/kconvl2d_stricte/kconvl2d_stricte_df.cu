#include "kconvl2d_stricte.cuh"

static __global__ void d_kerd__kconvl2d_stricte___simple(
	uint x0_t, uint X0, float * x0, float * dx0,
	//
	float * p, float * dp,
	//
	uint    Y,
	float * y, float * dy,
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
	uint   c0 = threadIdx.z + blockIdx.z * blockDim.z;
	//
	uint _x = _xy%im_X;
	uint _y = (_xy-_x)/im_X;
	//
	uint c1 = _c1t%C1;
	uint _t = (_c1t-c1)/C1;
	//
	if (_y < so_Y && _x < so_X && c1 < C1 && _t < GRAND_T && c0 < C0) {
		uint tx0 = t_MODE(_t, mega_t-x0_t);
		uint ty  = t_MODE(_t, mega_t     );
		//
		__shared__ float __dy[8][8];
		if (threadIdx.z == 0) __dy[threadIdx.y][threadIdx.x] = dy[ty*Y + c1*so_X*so_Y + _y*so_X + _x];
		__syncthreads();
		//float _dy = dy[ty*Y + c1*so_X*so_Y + _y*so_X + _x];
		float _dy = __dy[threadIdx.y][threadIdx.x];// / (float)C0;
		//
		//FOR(0, c0, C0) {
		for (int kx=-N; kx < N+1; kx++) {
			for (int ky=-N; ky < N+1; ky++) {
				int xx = _x + kx;
				int xy = _y + ky;
				if (0 <= xx && xx < im_X && 0 <= xy && xy < im_Y) {
					//s += x0[tx0*X0 + c0*im_X*im_Y + xy*im_X + xx] * p[c1*K*K*C0 + c0*K*K + (N+ky)*K + (N+kx)];
					uint pos_x0 = tx0*X0 + c0*im_X*im_Y + xy*im_X + xx;
					uint pos_p  = c1*K*K*C0 + c0*K*K + (N+ky)*K + (N+kx);
					atomicAdd(&dx0[pos_x0], _dy *      1     * p[pos_p]);
					atomicAdd(&dp [pos_p ], _dy * x0[pos_x0] *     1   );
				}
			}
		}
	}
};

void kconvl2d_stricte__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t) {
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
	//printf("### K=%i C0=%i C1=%i im_X=%i im_Y=%i\n", K, C0, C1, im_X, im_X);
	//
	if (x0_existe) {
		uint _KC0 = 8;
		if (C0 < _KC0) _KC0 = 1;
		//
		d_kerd__kconvl2d_stricte___simple<<<dim3(KERD((im_X*im_Y),8), KERD((C1*GRAND_T),8), KERD(C0,_KC0)), dim3(8,8,_KC0)>>>(
			inst->x_t[0], inst->x_Y[0], x__d[0], dx__d[0],
			//
			inst->p__d, inst->dp__d,
			//
			inst->Y,
			inst->y__d, inst->dy__d,
			//
			ts__d, mega_t,
			K, C0, C1, im_X, im_Y
		);
	} else {
		//	inst_zero_mega_t(inst, mega_t);
		//	rien
	}
};