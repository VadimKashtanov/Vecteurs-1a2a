#include "vect_div_unitair.cuh"

uint vect_div_unitair__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	return 0;
};

uint vect_div_unitair__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	return 0;
};

void vect_div_unitair__init_poids(Inst_t * inst) {
	uint C0 = inst->params[0];
	//
	ASSERT(inst->Y == inst->x_Y[0]);
	ASSERT(inst->x_Y[1] == C0);
	ASSERT(C0 > 0);
};