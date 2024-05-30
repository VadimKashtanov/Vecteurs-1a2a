#pragma once

#include "insts.cuh"

#define kconvl1d_stricte__Xs 1
#define kconvl1d_stricte__PARAMS 4 //K, C0, C1, im_X
#define kconvl1d_stricte_nom "Kconvl 1D stricte"

uint kconvl1d_stricte__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint kconvl1d_stricte__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void kconvl1d_stricte__init_poids(Inst_t * inst);

void kconvl1d_stricte__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void kconvl1d_stricte__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);