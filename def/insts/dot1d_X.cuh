#pragma once

#include "insts.cuh"

#define dot1d_X__Xs 1
#define dot1d_X__PARAMS 2 //C0, activ
#define dot1d_X_nom "Dot1d_X"

uint dot1d_X__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint dot1d_X__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void dot1d_X__init_poids(Inst_t * inst);

void dot1d_X__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void dot1d_X__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);