#include "cadrans_pondérés.cuh"

uint cadrans_pondérés__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	uint \
		Cx=params[0],	\
		C0=params[1],	\
		C1=params[2];
	//
	return C1 * C0 * Cx;
};

uint cadrans_pondérés__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	uint \
		Cx=params[0],	\
		C0=params[1],	\
		C1=params[2];
	return 0;//2 * Cx * C1;
};

void cadrans_pondérés__init_poids(Inst_t * inst) {
	uint * params = inst->params;
	uint \
		Cx=params[0],	\
		C0=params[1],	\
		C1=params[2];
	//
	ASSERT(inst->Y == C1 * Cx);
	ASSERT(inst->x_Y[0] == C0 * Cx);
	//
	float p[inst->P];
	FOR(0, i, inst->P) p[i] = (1.0/(float)C0) * poid_1_1();
	//
	CONTROLE_CUDA(cudaMemcpy(inst->p__d, p, sizeof(float)*inst->P, cudaMemcpyHostToDevice));
};