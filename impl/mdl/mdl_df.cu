#include "mdl.cuh"

#include "../../impl_template/tmpl_etc.cu"

void mdl_df(Mdl_t * mdl, BTCUSDT_t * btcusdt, uint * ts__d) {
	mdl_verif(mdl, btcusdt);
	//
	RETRO_FOR(0, mega_t, MEGA_T) {
		RETRO_FOR(0, i, mdl->insts) {
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
			ATTENDRE_CUDA();
		};
	}
};