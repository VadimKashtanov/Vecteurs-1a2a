#pragma once

#include "insts.cuh"

#define kconvl2d_stricte__Xs 1
#define kconvl2d_stricte__PARAMS 5 //K, C0, C1, im_X, im_Y   //K, M01, C0, C1, D1, im_X, im_Y
#define kconvl2d_stricte_nom "Kconvl 2D stricte"

uint kconvl2d_stricte__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint kconvl2d_stricte__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void kconvl2d_stricte__init_poids(Inst_t * inst);

void kconvl2d_stricte__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void kconvl2d_stricte__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);