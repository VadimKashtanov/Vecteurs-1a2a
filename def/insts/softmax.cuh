#pragma once

#include "insts.cuh"

#define softmax__Xs 1
#define softmax__PARAMS 0
#define softmax_nom "Softmax"

uint softmax__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint softmax__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void softmax__init_poids(Inst_t * inst);

void softmax__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void softmax__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);