#include "matmul1d_canal.cuh"

uint matmul1d_canal__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	uint \
		C0=params[0],	\
		C1=params[1],	\
		M =params[2];
	//
	uint v_x = X[0] / C0;
	uint v_y = Y / C1;
	//
	return v_x * v_y * (C0/M) * (C1/M)*M;
};

uint matmul1d_canal__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	//uint \
		C0 =params[0],	\
		C1=params[1],	\
		M =params[2];
	return 0;
};

void matmul1d_canal__init_poids(Inst_t * inst) {
	uint * params = inst->params;
	uint \
		C0 =params[0],	\
		C1=params[1],	\
		M =params[2];
	//
	uint v_x = inst->x_Y[0] / C0;
	uint v_y = inst->Y / C1;
	//
	float p[inst->P];
	FOR(0, i, inst->P) p[i] = sqrtf( 6.0 / (float)(v_x*C0/M)) * poid_1_1();
	//
	CONTROLE_CUDA(cudaMemcpy(inst->p__d, p, sizeof(float)*inst->P, cudaMemcpyHostToDevice));
};