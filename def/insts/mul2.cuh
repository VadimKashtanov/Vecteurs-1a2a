#pragma once

#include "insts.cuh"

#define mul2__Xs 2
#define mul2__PARAMS 0
#define mul2_nom "Mul 2"

uint mul2__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint mul2__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void mul2__init_poids(Inst_t * inst);

void mul2__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void mul2__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);