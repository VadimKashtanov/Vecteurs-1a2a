#pragma once

#include "insts.cuh"

#define const__Xs 0
#define const__PARAMS 1
#define const_nom "Constante"

uint const__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint const__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void const__init_poids(Inst_t * inst);

void const__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void const__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);