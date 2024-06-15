#include "insts.cuh"

#include "../../impl_template/tmpl_etc.cu"

//	------- Instructions ---------
#include "insts/_entree.cuh"
//
#include "insts/activation.cuh"
#include "insts/biais.cuh"
#include "insts/const.cuh"
//
#include "insts/dot1d_X.cuh"
#include "insts/dot1d_XY.cuh"
//
#include "insts/kconvl1d.cuh"
#include "insts/kconvl1d_stricte.cuh"
#include "insts/kconvl2d_stricte.cuh"
//
#include "insts/matmul1d.cuh"
#include "insts/matmul1d_canal.cuh"
//
#include "insts/mul2.cuh"
#include "insts/mul3.cuh"
//
#include "insts/pool2_1d.cuh"
#include "insts/pool2x2_2d.cuh"
//
#include "insts/softmax.cuh"
//
#include "insts/somme2.cuh"
#include "insts/somme3.cuh"
#include "insts/somme4.cuh"
//
#include "insts/sub2.cuh"
//
#include "insts/Y.cuh"
#include "insts/Y_canalisation.cuh"
#include "insts/Y_union_2.cuh"

uint inst_Xs[INSTS] = {
	_entree__Xs,
	activation__Xs,
	biais__Xs,
	const__Xs,
	dot1d_X__Xs,
	dot1d_XY__Xs,
	kconvl1d__Xs,
	kconvl1d_stricte__Xs,
	kconvl2d_stricte__Xs,
	matmul1d__Xs,
	matmul1d_canal__Xs,
	mul2__Xs,
	mul3__Xs,
	pool2_1d__Xs,
	pool2x2_2d__Xs,
	softmax__Xs,
	somme2__Xs,
	somme3__Xs,
	somme4__Xs,
	sub2__Xs,
	Y__Xs,
	Y_canalisation__Xs,
	Y_union_2__Xs
};

uint inst_PARAMS[INSTS] = {
	_entree__PARAMS,
	activation__PARAMS,
	biais__PARAMS,
	const__PARAMS,
	dot1d_X__PARAMS,
	dot1d_XY__PARAMS,
	kconvl1d__PARAMS,
	kconvl1d_stricte__PARAMS,
	kconvl2d_stricte__PARAMS,
	matmul1d__PARAMS,
	matmul1d_canal__PARAMS,
	mul2__PARAMS,
	mul3__PARAMS,
	pool2_1d__PARAMS,
	pool2x2_2d__PARAMS,
	softmax__PARAMS,
	somme2__PARAMS,
	somme3__PARAMS,
	somme4__PARAMS,
	sub2__PARAMS,
	Y__PARAMS,
	Y_canalisation__PARAMS,
	Y_union_2__PARAMS
};

dimention_f calculer_P[INSTS] = {
	_entree__calculer_P,
	activation__calculer_P,
	biais__calculer_P,
	const__calculer_P,
	dot1d_X__calculer_P,
	dot1d_XY__calculer_P,
	kconvl1d__calculer_P,
	kconvl1d_stricte__calculer_P,
	kconvl2d_stricte__calculer_P,
	matmul1d__calculer_P,
	matmul1d_canal__calculer_P,
	mul2__calculer_P,
	mul3__calculer_P,
	pool2_1d__calculer_P,
	pool2x2_2d__calculer_P,
	softmax__calculer_P,
	somme2__calculer_P,
	somme3__calculer_P,
	somme4__calculer_P,
	sub2__calculer_P,
	Y__calculer_P,
	Y_canalisation__calculer_P,
	Y_union_2__calculer_P
};

dimention_f calculer_L[INSTS] = {
	_entree__calculer_L,
	activation__calculer_L,
	biais__calculer_L,
	const__calculer_L,
	dot1d_X__calculer_L,
	dot1d_XY__calculer_L,
	kconvl1d__calculer_L,
	kconvl1d_stricte__calculer_L,
	kconvl2d_stricte__calculer_L,
	matmul1d__calculer_L,
	matmul1d_canal__calculer_L,
	mul2__calculer_L,
	mul3__calculer_L,
	pool2_1d__calculer_L,
	pool2x2_2d__calculer_L,
	softmax__calculer_L,
	somme2__calculer_L,
	somme3__calculer_L,
	somme4__calculer_L,
	sub2__calculer_L,
	Y__calculer_L,
	Y_canalisation__calculer_L,
	Y_union_2__calculer_L
};

inst__f_f __f_inst[INSTS] = {
	_entree__f,
	activation__f,
	biais__f,
	const__f,
	dot1d_X__f,
	dot1d_XY__f,
	kconvl1d__f,
	kconvl1d_stricte__f,
	kconvl2d_stricte__f,
	matmul1d__f,
	matmul1d_canal__f,
	mul2__f,
	mul3__f,
	pool2_1d__f,
	pool2x2_2d__f,
	softmax__f,
	somme2__f,
	somme3__f,
	somme4__f,
	sub2__f,
	Y__f,
	Y_canalisation__f,
	Y_union_2__f
};

inst_df_f _df_inst[INSTS] = {
	_entree__df,
	activation__df,
	biais__df,
	const__df,
	dot1d_X__df,
	dot1d_XY__df,
	kconvl1d__df,
	kconvl1d_stricte__df,
	kconvl2d_stricte__df,
	matmul1d__df,
	matmul1d_canal__df,
	mul2__df,
	mul3__df,
	pool2_1d__df,
	pool2x2_2d__df,
	softmax__df,
	somme2__df,
	somme3__df,
	somme4__df,
	sub2__df,
	Y__df,
	Y_canalisation__df,
	Y_union_2__df
};

inst_f init_poids[INSTS] = {
	_entree__init_poids,
	activation__init_poids,
	biais__init_poids,
	const__init_poids,
	dot1d_X__init_poids,
	dot1d_XY__init_poids,
	kconvl1d__init_poids,
	kconvl1d_stricte__init_poids,
	kconvl2d_stricte__init_poids,
	matmul1d__init_poids,
	matmul1d_canal__init_poids,
	mul2__init_poids,
	mul3__init_poids,
	pool2_1d__init_poids,
	pool2x2_2d__init_poids,
	softmax__init_poids,
	somme2__init_poids,
	somme3__init_poids,
	somme4__init_poids,
	sub2__init_poids,
	Y__init_poids,
	Y_canalisation__init_poids,
	Y_union_2__init_poids
};

const char * inst_Nom[INSTS] = {
	_entree_nom,
	activation_nom,
	biais_nom,
	const_nom,
	dot1d_X_nom,
	dot1d_XY_nom,
	kconvl1d_nom,
	kconvl1d_stricte_nom,
	kconvl2d_stricte_nom,
	matmul1d_nom,
	matmul1d_canal_nom,
	mul2_nom,
	mul3_nom,
	pool2_1d_nom,
	pool2x2_2d_nom,
	softmax_nom,
	somme2_nom,
	somme3_nom,
	somme4_nom,
	sub2_nom,
	Y_nom,
	Y_canalisation_nom,
	Y_union_2_nom
};

static Inst_t * lire_tete_instruction(FILE * fp) {
	Inst_t * ret = alloc<Inst_t>(1);

	//
	FREAD(&ret->ID, sizeof(uint), 1, fp);
	
	//
	FOR(0, __x, inst_Xs[ret->ID]) {
		uint est_une_entree;
		FREAD(&est_une_entree, sizeof(uint), 1, fp);
		//
		if (est_une_entree && ret->ID != 0) {
			ERR("Seul _entree ID=0 peut avoire des x de type `entree` (ID=%i __x=%i)", ret->ID, __x);
		}
		//
		FREAD(&ret->x_Y  [__x], sizeof(uint), 1, fp);
		FREAD(&ret->x_pos[__x], sizeof(uint), 1, fp);
		FREAD(&ret->x_t  [__x], sizeof(uint), 1, fp);
		//printf("X=%i\n", ret->x_Y[__x]);
	}
	
	//
	FREAD(&ret->Y, sizeof(uint), 1, fp);
	
	//
	FREAD(ret->params, sizeof(uint), inst_PARAMS[ret->ID], fp);
	
	//
	ret->P = calculer_P[ret->ID](ret->x_Y, ret->x_pos, ret->x_t, ret->Y, ret->params);
	ret->L = calculer_L[ret->ID](ret->x_Y, ret->x_pos, ret->x_t, ret->Y, ret->params);

	return ret;
};

static void ecrire_tete_instruction(FILE * fp, Inst_t * ret) {
	//
	FWRITE(&ret->ID, sizeof(uint), 1, fp);
	
	//
	FOR(0, __x, inst_Xs[ret->ID]) {
		uint est_une_entree = (ret->ID == 0);
		FWRITE(&est_une_entree, sizeof(uint), 1, fp);
		//
		FWRITE(&ret->x_Y  [__x], sizeof(uint), 1, fp);
		FWRITE(&ret->x_pos[__x], sizeof(uint), 1, fp);
		FWRITE(&ret->x_t  [__x], sizeof(uint), 1, fp);
	}
	
	//
	FWRITE(&ret->Y, sizeof(uint), 1, fp);
	
	//
	FWRITE(ret->params, sizeof(uint), inst_PARAMS[ret->ID], fp);
};

//	=======================================================

Inst_t * lire_inst_pre_mdl(FILE * fp) {
	Inst_t * ret = lire_tete_instruction(fp);

	//	--- Y & Y' ---
	ret-> y__d = cudalloc<float>(MEGA_T * GRAND_T * ret->Y);
	ret-> l__d = cudalloc<float>(MEGA_T * GRAND_T * ret->L);
	ret->dy__d = cudalloc<float>(MEGA_T * GRAND_T * ret->Y);

	//	--- Poids et Dérivés Locales ---
	ret-> p__d = cudalloc<float>(ret->P);
	ret->dp__d = cudalloc<float>(ret->P);

	//
	init_poids[ret->ID](ret);

	//
	return ret;
};

Inst_t * lire_inst(FILE * fp) {
	Inst_t * ret = lire_tete_instruction(fp);

	float * p = alloc<float>(ret->P);
	FREAD(p, sizeof(float), ret->P, fp);

	//	--- Y & Y' ---
	ret-> y__d = cudalloc<float>(MEGA_T * GRAND_T * ret->Y);
	ret-> l__d = cudalloc<float>(MEGA_T * GRAND_T * ret->L);
	ret->dy__d = cudalloc<float>(MEGA_T * GRAND_T * ret->Y);

	//	--- Poids et Dérivés Locales ---
	ret-> p__d = cpu_vers_gpu<float>(p, ret->P);
	ret->dp__d = cudalloc<float>(ret->P);

	free(p);

	//
	return ret;
};

void ecrire_inst(FILE * fp, Inst_t * inst) {
	ecrire_tete_instruction(fp, inst);
	//
	float * p = gpu_vers_cpu<float>(inst->p__d, inst->P);
	//
	FWRITE(p, sizeof(float), inst->P, fp);
	//
	free(p);
};

void liberer_inst(Inst_t * inst) {
	cudafree<float>(inst-> y__d);
	cudafree<float>(inst-> l__d);
	cudafree<float>(inst->dy__d);
	//
	cudafree<float>(inst-> p__d);
	cudafree<float>(inst->dp__d);
	free(inst);
};

void verif_insts() {
	FOR(0, i, INSTS) {
		ASSERT(inst_Xs[i]     <= MAX_XS);
		ASSERT(inst_PARAMS[i] <= MAX_PARAMS);
	}
};