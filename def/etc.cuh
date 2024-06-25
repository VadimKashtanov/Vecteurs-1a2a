#pragma once

#include "etc/cuda.cuh"
#include "etc/macro.cuh"
#include "etc/types.cuh"

//  Outils
float      rnd();
float poid_1_1();
float signe(float x);

void titre(char * str);

char * scientifique(uint nb);

//	template<typename T>
//		#include "impl_tmpl/tmpl_etc.cu"