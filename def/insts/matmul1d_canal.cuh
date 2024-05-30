#pragma once

#include "insts.cuh"

#define matmul1d_canal__Xs 1
#define matmul1d_canal__PARAMS 3
#define matmul1d_canal_nom "matmul_canal"

uint matmul1d_canal__calculer_P(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);
uint matmul1d_canal__calculer_L(uint X[MAX_XS], uint x[MAX_XS], uint t[MAX_XS], uint Y, uint params[MAX_PARAMS]);

void matmul1d_canal__init_poids(Inst_t * inst);

void matmul1d_canal__f(Inst_t * inst, float ** x__d, uint * ts__d, uint mega_t);
void matmul1d_canal__df(Inst_t * inst, float ** x__d, float ** dx__d, uint * ts__d, uint mega_t);

//	matmul1d_cananl X (C0 C1 M) Y         (et Kconvl)
//		C0
//		C1
//		M - melange (DIV)
//
//	_C0 = C0 / M
//	_C1 = C1 / M
//
//	X = _C0 * M * x
//	Y = _C1 * M * y