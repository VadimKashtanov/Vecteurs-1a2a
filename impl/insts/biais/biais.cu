#include "biais.cuh"

uint biais__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	return Y;
};

uint biais__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	return 0;
};

void biais__init_poids(Inst_t * inst) {
	float p[inst->P];
	uint Y=inst->Y;
	FOR(0, i, inst->P) p[i] = sqrtf( 6.0 / (float)(Y)) * poid_1_1();//(2*rnd()-1);

	CONTROLE_CUDA(cudaMemcpy(inst->p__d, p, sizeof(float)*inst->P, cudaMemcpyHostToDevice));
};