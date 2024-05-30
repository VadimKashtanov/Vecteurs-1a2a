#pragma once

#include "insts.cuh"

#define pool2x2_2d__Xs 1
#define pool2x2_2d__PARAMS 3
#define pool2x2_2d_nom "Pool 2x2"

uint pool2x2_2d__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint pool2x2_2d__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void pool2x2_2d__init_poids(Inst_t * inst);

void pool2x2_2d__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void pool2x2_2d__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);