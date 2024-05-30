#include "main.cuh"

#include "../impl_template/tmpl_etc.cu"

static void cree_mdl_depuis_pre_mdl(BTCUSDT_t * btcusdt) {
	Mdl_t * mdl = cree_mdl_depuis_st_bin("mdl.st.bin");
	mdl_verif(mdl, btcusdt);
	ecrire_mdl("mdl.bin", mdl);
	liberer_mdl(mdl);
};

static void plumer_le_score(Mdl_t * mdl, BTCUSDT_t * btcusdt) {
	uint T = btcusdt->T-1;
	T = T - (T%(GRAND_T * MEGA_T));
	T = T / (GRAND_T * MEGA_T);
	//
	float p0[btcusdt->Y]; FOR(0, i, btcusdt->Y) p0[i] = 0.0;
	float p1[btcusdt->Y]; FOR(0, i, btcusdt->Y) p1[i] = 0.0;
	float p3[btcusdt->Y]; FOR(0, i, btcusdt->Y) p3[i] = 0.0;
	float p8[btcusdt->Y]; FOR(0, i, btcusdt->Y) p8[i] = 0.0;
	//
	FOR(0, _t_, T) {
		uint ts[GRAND_T];
		FOR(0, t, GRAND_T) ts[t] = _t_*GRAND_T*MEGA_T + t*MEGA_T;
		//
		uint * ts__d = cpu_vers_gpu<uint>(ts, GRAND_T);
		//
		float * _p0 = mdl_pourcent(mdl, btcusdt, ts__d, 0.0);
		float * _p1 = mdl_pourcent(mdl, btcusdt, ts__d, 1.0);
		float * _p3 = mdl_pourcent(mdl, btcusdt, ts__d, 3.0);
		float * _p8 = mdl_pourcent(mdl, btcusdt, ts__d, 8.0);
		//
		cudafree<uint>(ts__d);
		//
		FOR(0, i, btcusdt->Y) p0[i] += _p0[i] / (float)T;
		FOR(0, i, btcusdt->Y) p1[i] += _p1[i] / (float)T;
		FOR(0, i, btcusdt->Y) p3[i] += _p3[i] / (float)T;
		FOR(0, i, btcusdt->Y) p8[i] += _p8[i] / (float)T;
		//
		free(_p0);
		free(_p1);
		free(_p3);
		free(_p8);
	};
	//
	FOR(0, i, btcusdt->Y) {
		printf("\033[93mPRED MODEL[%i]\033[0m : \033[96m%f%%\033[0m (^1=\033[96m%f%%\033[0m ^3=\033[96m%f%%\033[0m ^8=\033[96m%f%%\033[0m)\n",
			i,
			p0[i],
			p1[i],
			p3[i],
			p8[i]
		);
	}
};

int main() {
	srand(0);
	verif_insts();

	//	--
	printf(" ============== Verif 1e5 ============== \n");
	verif_mdl_1e5();

	//exit(0);

	printf(" ============== Vrai Programme ============== \n");
	//	--- Données ---
	BTCUSDT_t * btcusdt = cree_btcusdt("prixs/dar.bin");
	MSG("Kconvl f & df optimisée (Important)");
	MSG("Pool2d optimisé (f et df)");
	MSG("Faire depuis 2017");
	//
	MSG("Chiffre Haut, Bas, Normale");
	//
	MSG("ADAM n'est pas utilisé");
	//
	MSG("P du model peut etre changé. P=3 par exemple")

	//	--- Re-cree le Model ---
	//cree_mdl_depuis_pre_mdl(btcusdt);

	//	--- Mdl_t ---
	Mdl_t * mdl = ouvrire_mdl("mdl.bin");
	plumer_model(mdl);
	//tester_le_model(mdl, btcusdt);

	plumer_le_score(mdl, btcusdt);

	uint e = 0;
	while (true) {
		printf(" === Echope %i ===\n", e);
		
		//
		uint I = 200;
		
		//
		uint ts[GRAND_T];
		FOR(0, t, GRAND_T)
			ts[t] = rand() % (btcusdt->T - MEGA_T - 1);
		uint * ts__d = cpu_vers_gpu<uint>(ts, GRAND_T);

		//
		opti(mdl, btcusdt, ts__d, I, ADAM, 1e-3);
		ecrire_mdl("mdl.bin", mdl);
		
		//
		if (e % 10 == 0) {
			plumer_le_score(mdl, btcusdt);
		}
		e++;

		//
		cudafree<uint>(ts__d);
	}

	//
	ecrire_mdl("mdl.bin", mdl);

	//
	//liberer_mdl    (mdl    );
	liberer_btcusdt(btcusdt);
};