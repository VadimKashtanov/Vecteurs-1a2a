#pragma once

#include "insts.cuh"

#define sub2__Xs 2
#define sub2__PARAMS 0
#define sub2_nom "Soustraction 2"

uint sub2__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint sub2__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void sub2__init_poids(Inst_t * inst);

void sub2__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void sub2__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);