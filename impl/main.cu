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

void visualiser_vitesses(char * mdl_bin, BTCUSDT_t * btcusdt) {
	//	Sans que ça soit optimisé
	Mdl_t * mdl = ouvrire_mdl(mdl_bin);
	//
	mdl_desoptimiser(mdl);
	//
	uint ts[GRAND_T];
	FOR(0, t, GRAND_T)
		ts[t] = rand() % (btcusdt->T - MEGA_T - 1);
	uint * ts__d = cpu_vers_gpu<uint>(ts, GRAND_T);
	//
	float * temps = mdl_allez_retour_temps(mdl, btcusdt, ts__d);
	//
	temps; // INSTS + INSTS (F et F')
	//
	//
	printf(" --- Temps F(x) ---\n");
	float _max = max_lst<float>(temps+0*mdl->BLOQUES, mdl->BLOQUES);
	printf("temp max = %f\n", _max);
	FOR(0, i, mdl->BLOQUES) {
		uint pts = (uint)roundf(30.0*temps[0+mdl->BLOQUES + i] / _max);
		printf("%4.i| ", i);
		FOR(0, j, pts) printf("\033[103m_\033[0m");
		FOR(pts, j, 30) printf(" ");
		printf("  %s\n", inst_Nom[mdl->inst[i]->ID]);
	}
	//
	//
	printf(" --- Temps dF(x) ---\n");
	_max = max_lst<float>(temps+1*mdl->BLOQUES, mdl->BLOQUES);
	printf("temp max = %f\n", _max);
	FOR(0, i, mdl->BLOQUES) {
		uint pts = (uint)roundf(30.0*temps[1+mdl->BLOQUES + i] / _max);
		printf("%4.i| ", i);
		FOR(0, j, pts) printf("\033[104m_\033[0m");
		FOR(pts, j, 30) printf(" ");
		printf("  %s\n", inst_Nom[mdl->inst[i]->ID]);
	}
	//
	free(temps);
	//
	//
	liberer_mdl(mdl);
};

void montrer_Y_du_model(Mdl_t * mdl, BTCUSDT_t * btcusdt) {
	uint ts[GRAND_T];
	FOR(0, t, GRAND_T)
		ts[t] = rand() % (btcusdt->T - MEGA_T - 1);
	uint * ts__d = cpu_vers_gpu<uint>(ts, GRAND_T);
	//
	mdl_allez_retour(mdl, btcusdt, ts__d);
	//
	printf(" ======= Plumer Y ======\n");
	printf("mega_t = | ");
	FOR(0, i, MIN2(MEGA_T, 19)) printf("    %i   |", i);
	printf("\n");
	FOR(0, i, mdl->insts)
	{
		Inst_t * inst = mdl->inst[i];
		printf("#%i -- ID=%i %s Y=%i --\n", i, inst->ID, inst_Nom[inst->ID], inst->Y);
		//
		float * y = gpu_vers_cpu<float>(inst->y__d, inst->Y * GRAND_T * MEGA_T);
		//
		FOR(0, j, inst->Y) {
			printf("%i| ", j);
			FOR(0, mega_t, MIN2(MEGA_T, 19)) {
				printf("%+f ", y[mega_t*GRAND_T*inst->Y + 0*inst->Y + j]);
			}
			printf("\n");
		}
		//
		free(y);
	};
	//
	cudafree<uint>(ts__d);
};

int main() {
	srand(time(NULL));
	ecrire_structure_generale("structure_generale.bin");
	verif_insts();

	//	=========================================================
	//	=========================================================
	//	=========================================================
	//verif_mdl_1e5();

	//exit(0);

	//	=========================================================
	//	=========================================================
	//	=========================================================
	BTCUSDT_t * btcusdt = cree_btcusdt("prixs/dar.bin");
	MSG("Kconvl f & df optimisée (Important)");
	MSG("Pool2d optimisé (f et df)");
	//
	MSG("ADAM n'est pas utilisé");
	//
	MSG("P du model peut etre changé. P=3 par exemple")

	//	=========================================================
	//	=========================================================
	//	=========================================================

	//visualiser_vitesses("mdl.bin", btcusdt);

	//	=========================================================
	//	=========================================================
	//	=========================================================

	//	--- Re-cree le Model ---
	//cree_mdl_depuis_pre_mdl(btcusdt);

	//	--- Mdl_t ---
	Mdl_t * mdl = ouvrire_mdl("mdl.bin");
	plumer_model(mdl);
	//montrer_Y_du_model(mdl, btcusdt);
	//tester_le_model(mdl, btcusdt);

	//	=========================================================
	//	=========================================================
	//	=========================================================
	uint un_mois = ((24*30 - (24*30 % MEGA_T)) / MEGA_T) * MEGA_T;
	//
//plumer_le_score(mdl, btcusdt);
	// 
	uint e = 0;       // Atention Mechanisme, alternative Dot1d AB, ...
	while (true) {
		printf(" === Echope %i ===\n", e);
		
		//
		uint I        = 50;
		uint tous_les = 10;
		
		//
		srand(time(NULL));
		uint ts[GRAND_T];
		FOR(0, t, GRAND_T)
			ts[t] = rand() % (btcusdt->T - MEGA_T - 1 - un_mois);
		uint * ts__d = cpu_vers_gpu<uint>(ts, GRAND_T);

		//
		opti(mdl, btcusdt, ts__d, I, tous_les, ADAM, 1e-4);
		ecrire_mdl("mdl.bin", mdl);

		if (e % 10 == 0) {
			printf("pause ...\n");
			sleep(2);
		}
		
		//
		if (e % 50 == 0 && e != 0) {
			plumer_le_score(mdl, btcusdt);
		}
		e++;

		//
		cudafree<uint>(ts__d);
	}

	//
	//liberer_mdl    (mdl    );
	//liberer_btcusdt(btcusdt);
};






/*
Bon parametres:

6 juin 2024 = grand=10*16, mega_t=24, alpha=5e-4, I=50, L2=0.0, K=(sng==sng ? 0.25 : 2.0)

7 juin 2024 :
	grand_t = 3*16
	mega_t  = 24
	alpha = 5e-4
	I = 40
	L2=0.0
	K=(0.25 : 2.0)
	model = N=8 max_interv=256
		kconvl_lstm+pool -> chaine x10                   -> chaine -> x10
					-> kconvl_lstm+pool -> chaine -> x10 ->

*/