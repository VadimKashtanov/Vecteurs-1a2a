#include "mdl.cuh"

#include "../../impl_template/tmpl_etc.cu"

void mdl_f(Mdl_t * mdl, BTCUSDT_t * btcusdt, uint * ts__d) {
	mdl_verif(mdl, btcusdt);
	//
	FOR(0, mega_t, MEGA_T) {
		FOR(0, i, mdl->insts) {
			Inst_t * inst = mdl->inst[i];
			//
			float * x__d[MAX_XS];
			if (inst->ID == 0) {
				x__d[0] = btcusdt->entrees__d;
			} else {
				FOR(0, j, inst_Xs[inst->ID]) {
					x__d[j] = mdl->inst[inst->x_pos[j]]->y__d;
				};
			}
			//
			__f_inst[inst->ID](inst, x__d, ts__d, mega_t);
			ATTENDRE_CUDA();
		};
	}
};