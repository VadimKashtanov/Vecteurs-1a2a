#pragma once

#include "insts.cuh"

#define somme3__Xs 3
#define somme3__PARAMS 0
#define somme3_nom "Somme 3"

uint somme3__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint somme3__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void somme3__init_poids(Inst_t * inst);

void somme3__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void somme3__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);