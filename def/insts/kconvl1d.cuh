#pragma once

#include "insts.cuh"

#define kconvl1d__Xs 1
#define kconvl1d__PARAMS 5 //K, C0, C1, im_X, im_Y
#define kconvl1d_nom "Kconvl 1D"

uint kconvl1d__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint kconvl1d__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void kconvl1d__init_poids(Inst_t * inst);

void kconvl1d__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void kconvl1d__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);