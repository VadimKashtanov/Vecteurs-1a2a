#pragma once

#include "insts.cuh"

#define activation__Xs 1
#define activation__PARAMS 1
#define activation_nom "Activ"

uint activation__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint activation__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void activation__init_poids(Inst_t * inst);

void activation__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void activation__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);