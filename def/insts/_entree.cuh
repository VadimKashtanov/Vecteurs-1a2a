#pragma once

#include "insts.cuh"

#define _entree__Xs 1
#define _entree__PARAMS 0
#define _entree_nom "Entree"

uint _entree__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint _entree__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void _entree__init_poids(Inst_t * inst);

void _entree__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void _entree__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);