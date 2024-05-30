#include "mdl.cuh"

#include "../../impl_template/tmpl_etc.cu"

static void monter_de_un(uint I, uint i, uint * grille, uint * nb) {
	FOR(i+1, j, I) {
		FOR(0, k, nb[j]) {
			grille[(j-1)*I + k] = grille[j*I + k];
		};
		nb[j-1] = nb[j];
	}
};

static void eliminer_vides(uint I, uint * grille, uint * nb) {
	uint _true = true;
	do {
		_true = true;
		uint pos_nulle = I+1;
		FOR(0, i, I) {
			if (nb[i] == 0) {
				pos_nulle = i;
				_true = false;
			}
		}
		//
		if (pos_nulle != I+1) {
			monter_de_un(I, pos_nulle, grille, nb);
		}
	} while (_true);
};

//	===============================================================

static void deplacer(
	uint de_ligne, uint vers_ligne, uint de_elm,
	uint I, uint * grille, uint * nb)
{
	grille[vers_ligne*I + nb[vers_ligne]-1] = grille[de_ligne*I + de_elm];
	//
	FOR(de_elm+1, j, nb[de_ligne]) grille[de_ligne*I + j-1] = grille[de_ligne*I + j];
	//
	nb[de_ligne] -= 1;
	//
	eliminer_vides(I, grille, nb);
};

//	===============================================================

static void mise_a_jour_position(
	uint * positions_ligne, uint * position_elm,
	uint I, uint * grille, uint * nb)
{
	FOR(0, i, I) {
		uint fait = false;
		FOR(0, j, I) {
			if (nb[j] != 0)  {
				FOR(0, k, nb[j]) {
					if (grille[j*I + k] == i) {
						positions_ligne[i] = j;
						position_elm   [i] = k;
						//
						fait = true;
						break;
					}
				}
			}
			if (fait) break;
		}
	}
};

void mdl_optimisation(Mdl_t * mdl) {
	/*mdl->BLOQUES = mdl->insts;
	mdl->elements = (uint*)malloc(sizeof(uint) * mdl->insts);
	FOR(0, i, mdl->insts)
		mdl->elements[i] = 0;
	mdl->instructions = (uint**)malloc(sizeof(uint*) * mdl->insts);
	FOR(0, i, mdl->insts)
		mdl->instructions[i] = (uint*)malloc(sizeof(uint) * mdl->insts);
	//
	uint a_été_inclue[mdl->insts];
	FOR(0, i, mdl->insts) a_été_inclue[i] = 0;*/

	uint I = mdl->insts;
	//
	uint grille[I][I];
	uint     nb[I];
	FOR(0, i, I) {
		grille[i][0] = i;
		nb[i]        = 1;
	}
	//
	uint positions_ligne[I];
	uint position_elm   [I];
	mise_a_jour_position(positions_ligne, position_elm, I, grille, nb);
	//
	uint optimisable = false;
	do {
		optimisable = false;
		//
		FOR(0, i, I) {
			FOR(0, j, i) {
				
			};
			//
			if (optimisable) break;
		}
	} while (optimisable);
	
	//
	/*uint tous_inclues = 0;
	while (!(tous_inclues)) {
		FOR(0, i, mdl->insts) {
			if (!a_été_inclue[i]) {
				uint requière_une_donnee = false;
				FOR(0, _x, inst_Xs[mdl->inst[i]->ID]) {
					if (mdl->inst[i]->x_est_une_entree[_x]) requière_une_donnee = true;
				};
				if (requière_une_donnee) {
					mdl->elements[0]++;
					a_été_inclue[i] = 1;

					//	Ajout element
					mdl->instructions[0][mdl->elements[0]++] = i;
				}
			}
		}
		tous_inclues = 1;
		FOR(0, i, mdl->insts)
			if (!(a_été_inclue[i]))
				tous_inclues = 0;
	}*/
};