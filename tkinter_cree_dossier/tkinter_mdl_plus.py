from tkinter_cree_dossier.tkinter_mdl import Module_Mdl

from tkinter_cree_dossier.tkinter_dico_inst import Dico

from tkinter_cree_dossier.tkinter_insts import i__Entree
from tkinter_cree_dossier.tkinter_insts import i_Activation
from tkinter_cree_dossier.tkinter_insts import i_Biais, i_Const
from tkinter_cree_dossier.tkinter_insts import i_Dot1d_X, i_Dot1d_XY
from tkinter_cree_dossier.tkinter_insts import i_Kconvl1d, i_Kconvl1d_stricte, i_Kconvl2d_stricte
from tkinter_cree_dossier.tkinter_insts import i_MatMul, i_MatMul_Canal
from tkinter_cree_dossier.tkinter_insts import i_Mul2, i_Mul3
from tkinter_cree_dossier.tkinter_insts import i_Pool2_1d, i_Pool2x2_2d
from tkinter_cree_dossier.tkinter_insts import i_Somme
from tkinter_cree_dossier.tkinter_insts import i_Somme2, i_Somme3, i_Somme4
from tkinter_cree_dossier.tkinter_insts import i_Sub2
from tkinter_cree_dossier.tkinter_insts import i_Vect_Div_Unitair
from tkinter_cree_dossier.tkinter_insts import i_Y, i_Y_canalisation, i_Y_union_2

from tkinter_cree_dossier.tkinter_modules_inst_liste import *

conn = lambda sortie,inst,entree: (sortie, (inst,entree))

########################################################################################

class CHAINE(Module_Mdl):
	H       = 'H-qlq chose'
	N       = 'N-qlq chose'
	ELEMENT = None #GRU, DOT1D ...

	def cree_ix(self):
		#	Params
		N = self.params[self.N]
		H = self.params[self.H]

		params_non_N_ou_H = {k:v for k,v in self.params.items() if not k in (self.N, self.H)}

		X = self.X[0]
		Y = self.Y[0]

		assert N > 0

		#	------------------

		self.elements    = {}
		self.connections = {}
		#
		self.elements   ['0'] = self.ELEMENT(X=[X],Y=[H],params=params_non_N_ou_H).cree_ix()
		self.connections['0'] = {0:None}
		#
		for i in range(1,N-1):
			self.elements   [str(i)] = self.ELEMENT(X=[H],Y=[H],params=params_non_N_ou_H).cree_ix()
			self.connections[str(i)] = {0:(str(i-1), 0)}
		#
		self.elements   [str(N-1)] = self.ELEMENT(X=[H],Y=[Y],params=params_non_N_ou_H).cree_ix()
		self.connections[str(N-1)] = {0:(str(N-1-1), 0)}
		#
		self.cree_elements_connections()
		return self.ix

class RESIDUE(Module_Mdl):
	ELEMENT = None #GRU, DOT1D ...

	def cree_ix(self):
		#	Params
		X = self.X[0]
		Y = self.Y[0]

		#	------------------

		self.elements    = {
			'x'       : MODULE_i_Y     (X=[X], Y=[X], params={}).cree_ix(),
			'residue' : self.ELEMENT   (X=[X], Y=[X], params=self.params).cree_ix(),
			'somme'   : MODULE_i_Somme2(X=[X,X], Y=[X], params={}).cree_ix(),
		}
		self.connections = {
			'x'       : {0:None},
			'residue' : {0:('x',0)},
			'somme'   : {0:('x',0), 1:('residue',0)}
		}
		
		self.cree_elements_connections()
		return self.ix