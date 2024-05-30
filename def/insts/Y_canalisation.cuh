#pragma once

#include "insts.cuh"

#define Y_canalisation__Xs 1
#define Y_canalisation__PARAMS 1 //C0
#define Y_canalisation_nom "Y canalisation"

uint Y_canalisation__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint Y_canalisation__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void Y_canalisation__init_poids(Inst_t * inst);

void Y_canalisation__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void Y_canalisation__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);