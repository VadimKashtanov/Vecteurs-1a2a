#pragma once

#include "meta.cuh"

//#define  ING(A,y,c) (1 + (sng(y)==sng(c) ? (1- x2(A)) : (1+ x2(A)) ) )
//#define dING(A,y,c) (0 + (sng(y)==sng(c) ? (0-dx2(A)) : (0+dx2(A)) ) )

#define COEFA 2.0
#define ING 0.10 //Minimiseur
//#define  ING(A,y,c) (powf(1.0 + MINIMISEUR*(A*A - 0.0*(sng(y)==sng(c)) ), COEFA)/COEFA)
//#define dING(A,y,c) (powf(1.0 + MINIMISEUR*(A*A - 0.0*(sng(y)==sng(c)) ), COEFA-1)   * 2*A * MINIMISEUR)

//#define  ING(A,y,c) 1//(sng(y)==sng(c) ? (1 - A*A) : (A*A))
//#define dING(A,y,c) 0//(sng(y)==sng(c) ? (  - 2*A) : (2*A))

#define COEFD 2.0
//#define  D(y,c) (powf((y - (sng(c))), COEFD)/COEFD)
//#define dD(y,c) (powf((y - (sng(c))), COEFD-1)    )
#define    D(A,y,c) (powf((y*((1-ING)+ING*(A*A)) - (sng(c))), COEFD)/COEFD)
#define dDdy(A,y,c) (powf((y*((1-ING)+ING*(A*A)) - (sng(c))), COEFD-1)*((1-ING)+ING*(A*A)))
#define dDdA(A,y,c) (powf((y*((1-ING)+ING*(A*A)) - (sng(c))), COEFD-1)*y*ING*2*A    )

#define K(y,c)  powf(fabs(c)*100, 1.00)//(((sng(y))==(sng(c)) ? (powf((fabs(c))*100, 0.25)) : (powf((fabs(c))*100, 1.00))))

/*#define    S(A,y,c) ( D(y,c) * K(y,c) * ING(A,y,c))
//
#define dSdy(A,y,c) (dD(y,c) * K(y,c) *  ING(A,y,c))
#define dSdA(A,y,c) ( D(y,c) * K(y,c) * dING(A,y,c))*/

#define    S(A,y,c) ( D(A,y,c) * K(y,c))
//
#define dSdy(A,y,c) (dDdy(A,y,c) * K(y,c))
#define dSdA(A,y,c) (dDdA(A,y,c) * K(y,c))

typedef struct {
	//
	uint X;
	uint Y;	//=P
	//
	uint A;	//
	uint P;	//les predictions
	//
	uint T;

	//	Espaces
	float * entrees__d;	//	X * T
	float * sorties__d;	//	P * T
} BTCUSDT_t;

BTCUSDT_t * cree_btcusdt(char * fichier);
void  liberer_btcusdt(BTCUSDT_t * btcusdt);
//
float *  pourcent_btcusdt(BTCUSDT_t * btcusdt, float * y__d, uint * ts__d, float coef_puissance);
//
float  f_btcusdt(BTCUSDT_t * btcusdt, float * y__d,                uint * ts__d);
void  df_btcusdt(BTCUSDT_t * btcusdt, float * y__d, float * dy__d, uint * ts__d);