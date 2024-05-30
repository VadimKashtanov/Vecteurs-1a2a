#pragma once

#include "insts.cuh"

#define dot1d_XY__Xs 2
#define dot1d_XY__PARAMS 2 //C0, activ
#define dot1d_XY_nom "Dot1d_XY"

uint dot1d_XY__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint dot1d_XY__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void dot1d_XY__init_poids(Inst_t * inst);

void dot1d_XY__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void dot1d_XY__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);