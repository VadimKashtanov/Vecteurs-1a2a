#include "somme.cuh"

uint somme__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	return 0;
};

uint somme__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	return 0;
};

void somme__init_poids(Inst_t * inst) {
	uint C0 = inst->params[0];
	//
	ASSERT(inst->Y == C0);
	ASSERT(C0 > 0);
	//inst->p__d;
};