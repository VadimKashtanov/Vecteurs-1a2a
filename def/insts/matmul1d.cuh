#pragma once

#include "insts.cuh"

#define matmul1d__Xs 1
#define matmul1d__PARAMS 0
#define matmul1d_nom "matmul1d"

uint matmul1d__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint matmul1d__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void matmul1d__init_poids(Inst_t * inst);

void matmul1d__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void matmul1d__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);