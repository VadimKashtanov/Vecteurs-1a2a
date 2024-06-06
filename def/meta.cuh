#pragma once

#include "etc.cuh"

#define GRAND_T (10*16)//64//(16*16)//(    16)
#define  MEGA_T 24//24//(7*24*2)

//Reseaux tanachiques
//	16*16*N
//		  1

//Petits Reseaux Recurrents
//		8*8
//		 24

//Grands Reseaux Recurents
//		 16
//   7*24*2

//	verif_mdl()
//GRAND_T = 64 ou 16*16
// MEGA_T = 4 ou 8

#define t_MODE(t, mega_t) ((t)*MEGA_T + (mega_t))