#pragma once

#include "insts.cuh"

#define somme2__Xs 2
#define somme2__PARAMS 0
#define somme2_nom "Somme 2"

uint somme2__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint somme2__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void somme2__init_poids(Inst_t * inst);

void somme2__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void somme2__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);