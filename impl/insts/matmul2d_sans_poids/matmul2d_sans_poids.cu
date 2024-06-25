#include "matmul2d_sans_poids.cuh"

uint matmul2d_sans_poids__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	return 0;
};

uint matmul2d_sans_poids__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	return 0;
};

void matmul2d_sans_poids__init_poids(Inst_t * inst) {
	uint * params = inst->params;
	uint \
		Ax =params[0],	\
		Ay =params[1],	\
		Bx =params[2],	\
		C0 =params[3];
	//
	ASSERT(inst->Y == C0 * Bx * Ay);
	ASSERT(inst->x_Y[0] == C0 * Ax*Ay);
	ASSERT(inst->x_Y[1] == C0 * Bx*Ax);
};