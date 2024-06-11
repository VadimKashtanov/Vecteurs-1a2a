#include "Y_union_2.cuh"

uint Y_union_2__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	return 0;
};

uint Y_union_2__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	return 0;
};

void Y_union_2__init_poids(Inst_t * inst) {
	ASSERT(inst->Y == inst->x_Y[0]+inst->x_Y[1]);
	//inst->p__d;
};