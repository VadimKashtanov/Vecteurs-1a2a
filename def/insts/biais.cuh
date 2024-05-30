#pragma once

#include "insts.cuh"

#define biais__Xs 0
#define biais__PARAMS 0
#define biais_nom "Biais"

uint biais__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint biais__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void biais__init_poids(Inst_t * inst);

void biais__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void biais__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);