#include "main.cuh"

#include "../impl_template/tmpl_etc.cu"

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

static float ** toutes_les_predictions(Mdl_t * mdl, BTCUSDT_t * btcusdt) {
	uint mode = 0;
	//
	uint T = 0;// = btcusdt->T;
	uint PREDS = 0;
	//
	if (GRAND_T*MEGA_T >= btcusdt->T) {
		T = btcusdt->T;
		T = T - (T % MEGA_T);
		T = T / MEGA_T;
		//
		PREDS = T * MEGA_T;
		//
		mode = 1;
	} else {
		T = btcusdt->T;
		T = T - (T%(GRAND_T * MEGA_T));
		T = T / (GRAND_T * MEGA_T);
		//
		PREDS = T * (GRAND_T * MEGA_T);
		//
		mode = 0;
	}
	//
	//uint partie_non_couverte = btcusdt->T - T*MEGA_T*GRAND_T;
	//
	float * les_Amplitudes  = alloc<float>(PREDS);
	float * les_predictions = alloc<float>(PREDS);
	float * les_deltas      = alloc<float>(PREDS);
	//
	uint lp = 0;
	//
	FOR(0, _t_, T) {
		uint ts[GRAND_T];
		//
		if (mode == 0) {
			FOR(0, t, GRAND_T) ts[t] = (btcusdt->T-PREDS) + _t_*GRAND_T*MEGA_T + t*MEGA_T;
		} else {
			FOR(0, t, GRAND_T) ts[t] = (btcusdt->T-PREDS) + _t_*MEGA_T + t*0;
		}
		//
		uint * ts__d = cpu_vers_gpu<uint>(ts, GRAND_T);
		//
		mdl_f(mdl, btcusdt, ts__d);
		//
		cudafree<uint>(ts__d);
		//
		float * y = gpu_vers_cpu<float>(mdl->inst[mdl->la_sortie]->y__d, GRAND_T*MEGA_T*(btcusdt->Y+1));
		//
		if (mode == 0) {
			FOR(0, t, GRAND_T) {
				FOR(0, mega_t, MEGA_T) {
					les_Amplitudes [lp]  = y[t*MEGA_T*(btcusdt->Y+1) + mega_t*(btcusdt->Y+1) + 0];
					les_predictions[lp]  = y[t*MEGA_T*(btcusdt->Y+1) + mega_t*(btcusdt->Y+1) + 1];
					les_deltas     [lp] = lire(btcusdt->sorties__d, (ts[t] + mega_t)*btcusdt->Y+0);
					if ((ts[t] + mega_t) >= btcusdt->T-1) MSG("(ts[t] + mega_t) == btcusdt->T-1\n");
					lp++;
				}
			}
		} else {
			uint t = 0;
			FOR(0, mega_t, MEGA_T) {
				les_Amplitudes [lp]  = y[t*MEGA_T*(btcusdt->Y+1) + mega_t*(btcusdt->Y+1) + 0];
				les_predictions[lp]  = y[t*MEGA_T*(btcusdt->Y+1) + mega_t*(btcusdt->Y+1) + 1];
				les_deltas     [lp] = lire(btcusdt->sorties__d, (ts[t] + mega_t)*btcusdt->Y+0);
				if ((ts[t] + mega_t) >= btcusdt->T-1) MSG("(ts[t] + mega_t) == btcusdt->T-1\n");
				lp++;
			}
		}
		//
		free(y);
	};
	//
	float ** ret = alloc<float*>(3);
	ret[0] = les_Amplitudes ;
	ret[1] = les_predictions;
	ret[2] = les_deltas     ;
	return ret;
};

int main() {
	srand(0);
	verif_insts();

	//	=========================================================
	//	=========================================================
	//	=========================================================
	BTCUSDT_t * btcusdt = cree_btcusdt("prixs/tester_model_donnee.bin");

	//	=========================================================
	//	=========================================================
	//	=========================================================

	//	--- Mdl_t ---
	Mdl_t * mdl = ouvrire_mdl("mdl.bin");
	//plumer_model(mdl);
	//montrer_Y_du_model(mdl, btcusdt);
	//tester_le_model(mdl, btcusdt);

	float ** __lp = toutes_les_predictions(mdl, btcusdt);
	float * A  = __lp[0];
	float * lp = __lp[1];
	float * dl = __lp[2];

	FILE * fp = FOPEN("les_predictions.bin", "wb");
	//
	uint T = 0;// = btcusdt->T;
	uint PREDS = 0;
	//
	if (GRAND_T*MEGA_T >= btcusdt->T) {
		T = btcusdt->T;
		T = T - (T % MEGA_T);
		T = T / MEGA_T;
		//
		PREDS = T * MEGA_T;
	} else {
		T = btcusdt->T;
		T = T - (T%(GRAND_T * MEGA_T));
		T = T / (GRAND_T * MEGA_T);
		//
		PREDS = T * (GRAND_T * MEGA_T);
	}
	//
	FWRITE(A, sizeof(float), PREDS, fp);	//les prédictions
	free(A);
	//
	FWRITE(lp, sizeof(float), PREDS, fp);	//les prédictions
	free(lp);
	//
	FWRITE(dl, sizeof(float), PREDS, fp);	//les déltas
	free(dl);
	//
	fclose(fp);

	//	=========================================================
	//	=========================================================
	//	=========================================================
	//
	//plumer_le_score(mdl, btcusdt);

	//
	liberer_mdl    (mdl    );
	liberer_btcusdt(btcusdt);
};