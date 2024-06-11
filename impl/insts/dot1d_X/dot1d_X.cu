#include "dot1d_X.cuh"

uint dot1d_X__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	uint \
		C0   =params[0], \
		activ=params[1];
	//
	uint v_x0 = X[0] / C0;
	uint v_y  = Y    / C0;
	//
	return (v_x0*v_y + v_y) * C0;
};

uint dot1d_X__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	uint \
		C0   =params[0], \
		activ=params[1];
	//
	uint v_x0 = X[0] / C0;
	uint v_y  = Y    / C0;
	//
	return C0 * v_y;
};

void dot1d_X__init_poids(Inst_t * inst) {
	uint * params = inst->params;
	uint \
		C0   =params[0], \
		activ=params[1];
	//
	uint v_x0 = inst->x_Y[0] / C0;
	uint v_y  = inst->Y      / C0;
	//
	float p[inst->P];
	uint X=inst->x_Y[0], Y=inst->Y;
	FOR(0, i, inst->P) p[i] = sqrtf( 6.0 / (float)(v_x0)) * poid_1_1();

	CONTROLE_CUDA(cudaMemcpy(inst->p__d, p, sizeof(float)*inst->P, cudaMemcpyHostToDevice));
};