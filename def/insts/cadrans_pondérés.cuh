//X: C0 * Kx*Ky -> Y: C1 * Kx*Ky


//y[c1] = somm(x[i] * alpha[c1][i] for i in range(C0)) / somme(alpha[c1])

//	c1=0 :  ([c0=0]*[...] + [c0=1]*[...] + [c0=2]*[...] ...) / ([...]+[...]+[...] ...)
//	c1=1 :
//	 ...
//  c1=C1-1

#pragma once

#include "insts.cuh"

#define cadrans_pondérés__Xs 1
#define cadrans_pondérés__PARAMS 3 //Cx, C0, C1
#define cadrans_pondérés_nom "cadrans_pondérés"

uint cadrans_pondérés__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint cadrans_pondérés__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void cadrans_pondérés__init_poids(Inst_t * inst);

void cadrans_pondérés__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void cadrans_pondérés__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);