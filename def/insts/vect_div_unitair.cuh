#pragma once

#include "insts.cuh"

#define vect_div_unitair__Xs 2
#define vect_div_unitair__PARAMS 1
#define vect_div_unitair_nom "vect_div_unitair"

uint vect_div_unitair__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint vect_div_unitair__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void vect_div_unitair__init_poids(Inst_t * inst);

void vect_div_unitair__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void vect_div_unitair__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);