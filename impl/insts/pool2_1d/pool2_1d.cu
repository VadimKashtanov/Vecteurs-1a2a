#include "pool2_1d.cuh"

uint pool2_1d__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	return 0;
};

uint pool2_1d__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	uint \
		C0  =params[0],	\
		im_X=params[1];
	//
	return 0;
};

void pool2_1d__init_poids(Inst_t * inst) {
	uint * params = inst->params;
	uint \
		C0  =params[0],	\
		im_X=params[1];
	//
	ASSERT(C0 > 0);
	ASSERT(im_X > 0);
	//
	ASSERT(inst->x_Y[0] == (C0 * im_X));
	ASSERT(im_X % 2 == 0);
	ASSERT(inst->Y == (int)(C0 * im_X/2));
};