#include "mdl.cuh"

#include "../impl_template/tmpl_etc.cu"

__global__
static void kerd_p1e5(float * p__d, uint p, float _1E5) {
	p__d[p] += _1E5;
};

static void plus_1e5(float * p__d, uint p, float _1E5) {
	kerd_p1e5<<<1,1>>>(p__d, p, _1E5);
	ATTENDRE_CUDA();
};

//	---------------------------------------------------

__global__
static void kerd_lire(float * p__d, uint p, float * val) {
	val[0] = p__d[p];
};

static float lire(float * p__d, uint p) {
	float * val = cudalloc<float>(1);
	kerd_lire<<<1,1>>>(p__d, p, val);
	ATTENDRE_CUDA();
	//
	float * _ret = gpu_vers_cpu<float>(val, 1);
	float ret = _ret[0];
	free(_ret);cudafree<float>(val);
	//
	return ret;
};

void tester_le_model(Mdl_t * mdl, BTCUSDT_t * btcusdt) {
	uint ts[GRAND_T];
	FOR(0, t, GRAND_T) ts[t] = rand() % (btcusdt->T - MEGA_T);
	uint * ts__d = cpu_vers_gpu<uint>(ts, GRAND_T);
	//
	mdl_verif(mdl, btcusdt);
	//
	//	mdl_plume_poid(mdl);
	//
	float * grad_1e5[mdl->insts];
	FOR(0, i, mdl->insts) grad_1e5[i] = alloc<float>(mdl->inst[i]->P);
	//
	//
	mdl_allez_retour(mdl, btcusdt, ts__d);
	//
	//
	INIT_CHRONO(s)
	DEPART_CHRONO(s)
	//
	uint testés = 1;
	//
	float S = mdl_S(mdl, btcusdt, ts__d);
	float _1E5 = 1e-2;//3e-3;
	uint lp = 0;
	FOR(0, i, mdl->insts) {
		printf("#### INSTRUCTION %i (%s Y=%i) ####\n",
			i, 
			inst_Nom[mdl->inst[i]->ID], mdl->inst[i]->Y
		);
		FOR(0, p, mdl->inst[i]->P) {
			plus_1e5(mdl->inst[i]->p__d, p, _1E5);
			float S1e5 = mdl_S(mdl, btcusdt, ts__d);
			plus_1e5(mdl->inst[i]->p__d, p, -_1E5);

			//
			grad_1e5[i][p] = (S1e5 - S)/_1E5;
			//printf("%i|%i| %f --- %f (%f)\n", );

			float a=grad_1e5[i][p], b=lire(mdl->inst[i]->dp__d, p);
			printf("%i| ", p);
			PLUME_CMP(a, b);
			if (b != 0) printf(" (x%+f) ", a/b);
			printf(" (%+fs)", (float)testés / VALEUR_CHRONO(s));
			printf(" |%i  inst=%i|\n", lp++, i);
			testés++;
		};
	};
	printf("1E5  === dp\n");
	//
	FOR(0, i, mdl->insts) free(grad_1e5[i]);
	cudafree<uint>(ts__d);
};