#pragma once

#include "insts.cuh"

#define somme4__Xs 4
#define somme4__PARAMS 0
#define somme4_nom "Somme 4"
uint somme4__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint somme4__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void somme4__init_poids(Inst_t * inst);

void somme4__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void somme4__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);