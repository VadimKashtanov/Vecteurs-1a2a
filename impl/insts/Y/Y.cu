#include "Y.cuh"

uint Y__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	return 0;
};

uint Y__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	return 0;
};

void Y__init_poids(Inst_t * inst) {
	ASSERT(inst->Y == inst->x_Y[0]);
	//inst->p__d;
};