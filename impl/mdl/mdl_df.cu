#include "mdl.cuh"

#include "../../impl_template/tmpl_etc.cu"

void mdl_df(Mdl_t * mdl, BTCUSDT_t * btcusdt, uint * ts__d) {
	mdl_verif(mdl, btcusdt);
	//
	RETRO_FOR(0, mega_t, MEGA_T) {
		RETRO_FOR(0, b, mdl->BLOQUES) {
			FOR(0, j, mdl->elements[b]) {
				//
				uint i = mdl->instructions[b][j];
				//
				Inst_t * inst = mdl->inst[i];
				//
				float *  x__d[MAX_XS];
				float * dx__d[MAX_XS];
				if (inst->ID == 0) {
					 x__d[0] = btcusdt->entrees__d;
					dx__d[0] = 0;
				} else {
					FOR(0, j, inst_Xs[inst->ID]) {
						 x__d[j] = mdl->inst[inst->x_pos[j]]-> y__d;
						dx__d[j] = mdl->inst[inst->x_pos[j]]->dy__d;
					};
				}
				//
				_df_inst[inst->ID](inst, x__d, dx__d, ts__d, mega_t);
			}

			//	En fin de bloque on attend
			ATTENDRE_CUDA();
		};
	}
};

float* mdl_df_temps(Mdl_t * mdl, BTCUSDT_t * btcusdt, uint * ts__d) {
	float * temps = alloc<float>(mdl->BLOQUES);
	//
	INIT_CHRONO(a)
	//
	mdl_verif(mdl, btcusdt);
	//
	RETRO_FOR(0, mega_t, MEGA_T) {
		RETRO_FOR(0, b, mdl->BLOQUES) {
			DEPART_CHRONO(a);
			//
			FOR(0, j, mdl->elements[b]) {
				//
				uint i = mdl->instructions[b][j];
				//
				Inst_t * inst = mdl->inst[i];
				//
				float *  x__d[MAX_XS];
				float * dx__d[MAX_XS];
				if (inst->ID == 0) {
					 x__d[0] = btcusdt->entrees__d;
					dx__d[0] = 0;
				} else {
					FOR(0, j, inst_Xs[inst->ID]) {
						 x__d[j] = mdl->inst[inst->x_pos[j]]-> y__d;
						dx__d[j] = mdl->inst[inst->x_pos[j]]->dy__d;
					};
				}
				//
				_df_inst[inst->ID](inst, x__d, dx__d, ts__d, mega_t);
			}

			//	En fin de bloque on attend
			ATTENDRE_CUDA();
			temps[b] = VALEUR_CHRONO(a);
		};
	}
	return temps;
};