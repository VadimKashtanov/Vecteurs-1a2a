#pragma once

#include "meta.cuh"

#define  D(y,c) (powf((y - sng(c)), 2)/2)
#define dD(y,c) (powf((y - sng(c)), 1)  )

#define K(y,c)  (powf((abs(c))*100, 0.25))//(powf(c*100, 0.25))

#define  S(y,c) ( D(y,c) * K(y,c))
#define dS(y,c) (dD(y,c) * K(y,c))

typedef struct {
	//
	uint X;
	uint Y;
	//
	uint T;

	//	Espaces
	float * entrees__d;	//	X * T
	float * sorties__d;	//	Y * T
} BTCUSDT_t;

BTCUSDT_t * cree_btcusdt(char * fichier);
void  liberer_btcusdt(BTCUSDT_t * btcusdt);
//
float *  pourcent_btcusdt(BTCUSDT_t * btcusdt, float * y__d, uint * ts__d, float coef_puissance);
//
float  f_btcusdt(BTCUSDT_t * btcusdt, float * y__d,                uint * ts__d);
void  df_btcusdt(BTCUSDT_t * btcusdt, float * y__d, float * dy__d, uint * ts__d);