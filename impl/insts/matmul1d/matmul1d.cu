#include "matmul1d.cuh"

uint matmul1d__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	return X[0] * Y;
};

uint matmul1d__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	return 0;
};

void matmul1d__init_poids(Inst_t * inst) {
	float p[inst->P];
	uint X=inst->x_Y[0], Y=inst->Y;
	FOR(0, i, inst->P) p[i] = sqrtf( 6.0 / (float)(X)) * poid_1_1();

	CONTROLE_CUDA(cudaMemcpy(inst->p__d, p, sizeof(float)*inst->P, cudaMemcpyHostToDevice));
};