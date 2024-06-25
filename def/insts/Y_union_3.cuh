#pragma once

#include "insts.cuh"

#define Y_union_2__Xs 2
#define Y_union_2__PARAMS 0
#define Y_union_2_nom "Y union 2"

uint Y_union_2__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint Y_union_2__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void Y_union_2__init_poids(Inst_t * inst);

void Y_union_2__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void Y_union_2__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);