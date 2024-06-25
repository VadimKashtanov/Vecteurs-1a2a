#pragma once

#include "insts.cuh"

#define matmul2d_sans_poids__Xs 2
#define matmul2d_sans_poids__PARAMS 4 //Ax, Ay, By, C0
#define matmul2d_sans_poids_nom "matmul2d sans poid"

uint matmul2d_sans_poids__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint matmul2d_sans_poids__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void matmul2d_sans_poids__init_poids(Inst_t * inst);

void matmul2d_sans_poids__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void matmul2d_sans_poids__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);

//	-- Ceci est A @ B

//	faut ajouter drop Connect (mon masque de poids)

//	a revoire les choses avec chat gpt

// pas oublier mon idee avec mes truc logistic(x)*memoire ...