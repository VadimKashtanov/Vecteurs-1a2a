#include "mdl.cuh"

#include "../impl_template/tmpl_etc.cu"

void mdl_dy_zero(Mdl_t * mdl) {
	FOR(0, i, mdl->insts) {
		uint I = mdl->inst[i]->Y*GRAND_T*MEGA_T;
		kerd_liste_inis<float><<<dim3(KERD(I, 64)), dim3(64)>>>(
			mdl->inst[i]->dy__d, 0.0, I
		);
		if (mdl->inst[i]->P != 0) {
			uint P = mdl->inst[i]->P;
			kerd_liste_inis<float><<<dim3(KERD(P, 64)), dim3(64)>>>(
				mdl->inst[i]->dp__d, 0.0, P
			);
		}
	};
	ATTENDRE_CUDA();
};