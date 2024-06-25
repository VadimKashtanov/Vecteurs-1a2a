#pragma once

#include "meta.cuh"

#define  _11(A) ((A+1.0)/2.0)
#define d_11(A) ((1+0.0)/2.0)

#define  score_log(y,w) (-(  w*logf(y) + (1-w)*logf(1-y)  ))
#define dscore_log(y,w) (-(  (w)/(y) + -(1-w)/(1-y)  )     )

#define  score_log11(y,w) (-(  _11(w)*logf(_11(y)) + (1-_11(w))*logf(1-_11(y))  ))
#define dscore_log11(y,w) (-(  _11(w)/(_11(y))*d_11(y) + -(1-_11(w))/(1-_11(y))*d_11(y)  ))

#define  score_p2(y,w,C) (powf(y-w, C)/(float)C)
#define dscore_p2(y,w,C) (powf(y-w, C-1))

#define  score_absp2(y,w,C) ((powf(1+fabs(y-w), C)-1)/(float)C)
#define dscore_absp2(y,w,C) (powf(1+fabs(y-w), C-1) * dfabs(y-w))

//	------------------------------------------------------------------

#define  ING(A,y,c)  score_p2(A, (sng(c)==sng(y) ? +1:-1), 2)
#define dING(A,y,c) dscore_p2(A, (sng(c)==sng(y) ? +1:-1), 2)

//#define  ING(A,y,c) 0// score_log11(A, (sng(c)==sng(y) ? +1:-1))
//#define dING(A,y,c) 0//dscore_log11(A, (sng(c)==sng(y) ? +1:-1))

#define  D(y,c)  score_p2(y, sng(c), 2)
#define dD(y,c) dscore_p2(y, sng(c), 2)

//#define  D(y,c)  score_log11(y, sng(c))
//#define dD(y,c) dscore_log11(y, sng(c))

#define K(y,c) powf(fabs(c)*500, 1.00)

#define    S(A,y,c) ( D(y,c) * K(y,c) + ING(A,y,c)*K(y,c))
//
#define dSdy(A,y,c) (dD(y,c) * K(y,c))
#define dSdA(A,y,c) (K(y,c) * dING(A,y,c))

/*#define    S(A,y,c) ( D(y,c) * K(y,c) * ING(A,y,c))
//
#define dSdy(A,y,c) (dD(y,c) * K(y,c) *  ING(A,y,c))
#define dSdA(A,y,c) ( D(y,c) * K(y,c) * dING(A,y,c))*/

//	---------------------------------------------------------------

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