#include "opti.cuh"

#include "../impl_template/tmpl_etc.cu"

uint hists[] = {
	ADAM_HISTOIRE
};

void opti(
	Mdl_t     *     mdl,
	BTCUSDT_t * btcusdt,
	uint      *   ts__d,
	uint              I,
	uint       tous_les,
	uint        methode,
	float         alpha
) {
	//	--- Hist ---
	float *** hist = alloc<float**>(hists[methode]);
	FOR(0, h, hists[methode]) {
		hist[h] = alloc<float*>(mdl->insts);
		FOR(0, i, mdl->insts) {
			hist[h][i] = cudalloc<float>(mdl->inst[i]->P);
			// = 0
		}
	}
	//	--- Plume ---
	mdl_plume_grad(mdl, btcusdt, ts__d);
	//	--- Opti  ---
	FOR(0, i, I) {
		if (i != 0) {
			//	dF(x)
			mdl_allez_retour(mdl, btcusdt, ts__d);
			//	x = x - dx
			if (methode == ADAM) adam(mdl, hist, i, alpha);
		}
		//
		if (i % tous_les == 0) {
			float s = mdl_S(mdl, btcusdt, ts__d);
			float * p0 = mdl_pourcent(mdl, btcusdt, ts__d, 0.0);
			float * p1 = mdl_pourcent(mdl, btcusdt, ts__d, 1.0);
			float * p8 = mdl_pourcent(mdl, btcusdt, ts__d, 8.0);
			//

			printf("%3.i/%3.i score = %f (", i, I, s);

			printf("^0:{");
			FOR(0, p, btcusdt->Y) printf("\033[96m%f%%\033[0m ", p0[p]);
			printf("}  ");

			printf("^1:{");
			FOR(0, p, btcusdt->Y) printf("\033[96m%f%%\033[0m ", p1[p]);
			printf("}  ");

			printf("^8:{");
			FOR(0, p, btcusdt->Y) printf("\033[96m%f%%\033[0m ", p8[p]);
			printf("}");

			printf(")\n");

			free(p0);
			free(p1);
			free(p8);
		};
	};
	//
	FOR(0, h, hists[methode]) {
		FOR(0, i, mdl->insts) {
			cudafree<float>(hist[h][i]);
		}
		free(hist[h]);
	}
	free(hist);
}