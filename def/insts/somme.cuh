#pragma once

#include "insts.cuh"

#define somme__Xs 1
#define somme__PARAMS 1
#define somme_nom "somme"

uint somme__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint somme__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void somme__init_poids(Inst_t * inst);

void somme__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void somme__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);