#pragma once

#include "insts.cuh"

#define mul3__Xs 3
#define mul3__PARAMS 0
#define mul3_nom "Mul 3"
uint mul3__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint mul3__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void mul3__init_poids(Inst_t * inst);

void mul3__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void mul3__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);