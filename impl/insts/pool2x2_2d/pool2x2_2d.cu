#include "pool2x2_2d.cuh"

uint pool2x2_2d__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	return 0;
};

uint pool2x2_2d__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	uint \
		C0  =params[0],	\
		im_X=params[1],	\
		im_Y=params[2];
	//
	return 0;//L = (im_X/2) * (im_Y/2) * C0;
};

void pool2x2_2d__init_poids(Inst_t * inst) {
	uint * params = inst->params;
	uint \
		C0  =params[0],	\
		im_X=params[1],	\
		im_Y=params[2];
	//
	ASSERT(C0 > 0);
	ASSERT(im_X > 0);
	ASSERT(im_Y > 0);
	//
	//
	ASSERT(inst->x_Y[0] == (C0 * im_X * im_Y));
	ASSERT(im_X % 2 == 0);
	ASSERT(im_Y % 2 == 0);
	ASSERT(inst->Y == (int)(C0 * im_X/2 * im_Y/2));
};