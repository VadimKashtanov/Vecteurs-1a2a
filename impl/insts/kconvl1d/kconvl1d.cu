#include "kconvl1d.cuh"

uint kconvl1d__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	uint \
		K   =params[0],
		C0  =params[1],
		C1  =params[2],
		im_X=params[3],
		im_Y=params[4];
	//
	return K * C0 * C1;
};

uint kconvl1d__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]) {
	return 0;
};

void kconvl1d__init_poids(Inst_t * inst) {
	uint * params = inst->params;
	uint \
		K   =params[0],
		C0  =params[1],
		C1  =params[2],
		im_X=params[3],
		im_Y=params[4];
	//
	uint N = (K-1)/2;
	//
	uint X=inst->x_Y[0], Y=inst->Y;
	//
	ASSERT(   N > 0);
	ASSERT(  C0 > 0);
	ASSERT(  C1 > 0);
	ASSERT(im_X > 0);
	//
	ASSERT(im_Y == im_X-N-N);
	//
	ASSERT(inst->x_Y[0] == C0*im_X);
	ASSERT(inst->Y      == C1*im_Y);
	//
	float p[inst->P];
	FOR(0, i, inst->P) p[i] = (1.0/(float)C0) * poid_1_1();
	//
	CONTROLE_CUDA(cudaMemcpy(inst->p__d, p, sizeof(float)*inst->P, cudaMemcpyHostToDevice));
};