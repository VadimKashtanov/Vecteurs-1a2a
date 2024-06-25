from tkinter_cree_dossier.modules._etc import *

class GRU1D(Module_Mdl):	#	f(ax0+bx1+cx2+d)
	bg, fg = 'light green', 'black'
	nom = "[GRU]"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["H"] # LSTM [X], [H]
	params = {
		#
	}
	def cree_ix(self):
		#	Params
		X = self.X[0]
		Y = self.Y[0]

		#	------------------

		_tanh      = 0
		logistique = 1

		self.elements = {
			'x' : MODULE_i_Y(X=[X], Y=[X], params={}).cree_ix(),
			#
			'z' : DOT1D_2(X=[X,Y], Y=[Y], params={'activ':logistique}).cree_ix(),
			'r' : DOT1D_2(X=[X,Y], Y=[Y], params={'activ':logistique}).cree_ix(),
			#
			'r*h' : MODULE_i_Mul2 (X=[Y,Y], Y=[Y], params={}).cree_ix(),
			'ĥ'   : DOT1D_2(X=[X,Y], Y=[Y], params={'activ':_tanh}).cree_ix(),
			#
			'1'  : MODULE_i_Const(X=[], Y=[Y], params={'cst' : 1}).cree_ix(),
			'(1-z)' : MODULE_i_Sub2(X=[Y,Y], Y=[Y], params={}).cree_ix(),
			#
			#(1-z)*h + z * ĥ
			'h' : AB_plus_CD(X=[Y,Y,Y,Y], Y=[Y], params={}).cree_ix(),
		}

		#	======================

		self.connections = {
			'x' : {
				0 : None,
			},
			'z' : {
				0 : ('x', 0), 
				1 : ('h', -1),
			},
			'r' : {
				0 : ('x', 0), 
				1 : ('h', -1),
			},
			'r*h' : {
				0 : ('r', 0), 
				1 : ('h', -1),
			},
			'ĥ' : {
				0 : ('x', 0), 
				1 : ('r*h', 0),
			},
			'1' : {},
			'(1-z)' : {
				0 : ('1', 0), 
				1 : ('z', 0),
			},
			'h' : {
				0 : ('(1-z)', 0),
				1 : ('h', -1),
				2 : ('z', 0),
				3 : ('ĥ', 0)
			}
		}

		self.cree_elements_connections()
		return self.ix

class GRU1D__CHAINE(CHAINE):
	img = img_chaine
	bg, fg = 'light green', 'black'
	nom = "[GRU1D] CHAINE"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"]
	params = {
		'H' : 0,
		'N' : 0,
	}
	#	--------------------------
	H       = 'H'
	N       = 'N'
	ELEMENT = GRU1D

class GRU1D__CHAINE__RESIDUELLE(RESIDUE):
	img = img_chaine_residue
	bg, fg = 'light green', 'black'
	nom = "[GRU1D Chaine] Res"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"]
	params = {
		'N' : 0,
	}
	#	--------------------------
	ELEMENT = GRU1D__CHAINE