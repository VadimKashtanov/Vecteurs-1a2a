from tkinter_cree_dossier.modules._etc import *

class UNION_LSTM1D(Module_Mdl):	#	f(ax0+bx1+cx2+d)
	bg, fg = 'light pink', 'black'
	nom = "[UNION_LSTM]"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"] # LSTM [X], [H]
	params = {
		#'activ' : 0
	}
	def cree_ix(self):
		#	Params
		X = self.X[0]
		Y = self.Y[0]

		#	------------------

		_tanh      = 0
		logistique = 1

		self.ix = []

		self.elements = {
			'x' : MODULE_i_Y(X=[X], Y=[X], params={}).cree_ix(),
			#
			'x;h'   : MODULE_i_Y_union_2(X=[X,Y], Y=[X+Y], params={}).cree_ix(),
			'x;h;c' : MODULE_i_Y_union_2(X=[X+Y,Y], Y=[X+Y+Y], params={}).cree_ix(),
			#
			# f = logistique(sF = Fx@x + Fh@h[-1] + Fc@c[-1] + Fb)
			'f' : DOT1D_1(X=[X+Y+Y], Y=[Y], params={'activ':logistique}).cree_ix(),
			# i = logistique(sI = Ix@x + Ih@h[-1] + Ic@c[-1] + Ib)
			'i' : DOT1D_1(X=[X+Y+Y], Y=[Y], params={'activ':logistique}).cree_ix(),
			#u =       tanh(sU = Ux@x + Uh@h[-1] +          + Ub)
			'u' : DOT1D_1(X=[X+Y], Y=[Y], params={'activ':_tanh}).cree_ix(),
			#c = f*c[-1] + i*u
			'c' : AB_plus_CD(X=[Y,Y,Y,Y], Y=[Y], params={}).cree_ix(),
			#ch = tanh(c)
			'ch' : MODULE_i_Activation(X=[Y], Y=[Y], params={'activ':_tanh}).cree_ix(),
			#o = logistique(sO = Ox@x + Oh@h[-1] + Oc@c    + Ob)
			'o' : DOT1D_1(X=[X+Y+Y], Y=[Y], params={'activ':logistique}).cree_ix(),
			#h = o * ch
			'h' : MODULE_i_Mul2(X=[Y,Y], Y=[Y], params={}).cree_ix(),
		}

		#	======================

		self.connections = {
			'x' : {
				0 : None,
			},
			'x;h' : {
				0 : ('x', 0),
				1 : ('h', -1)
			},
			'x;h;c' : {
				0 : ('x;h', 0),
				1 : ('c', -1)
			},
			'f' : {
				0 : ('x;h;c', 0),
			},
			'i' : {
				0 : ('x;h;c', 0)
			},
			'u' : {
				0 : ('x;h', 0)
			},
			'c' : {
				0 : ('f', 0),
				1 : ('c', -1),
				2 : ('i', 0),
				3 : ('u', 0)
			},
			'ch' : {
				0 : ('c', 0),
			},
			'o' : {
				0 : ('x;h;c', 0)
			},
			'h' : {
				0 : ('o', 0),
				1 : ('ch', 0)
			}
		}

		self.cree_elements_connections()
		return self.ix

class UNION_LSTM1D__CHAINE(CHAINE):
	img = img_chaine
	bg, fg = 'light pink', 'black'
	nom = "[UNION_LSTM1D] CHAINE"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"]
	params = {
		'H' : 0,
		'N' : 0,
	}
	#	--------------------------
	H       = 'H'
	N       = 'N'
	ELEMENT = UNION_LSTM1D

class UNION_LSTM1D__CHAINE__RESIDUELLE(RESIDUE):
	img = img_chaine_residue
	bg, fg = 'light pink', 'black'
	nom = "[UNION_LSTM1D Chaine] Res"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"] # LSTM [X], [H]
	params = {
		'H' : 0,
		'N' : 0,
	}
	#	--------------------------
	ELEMENT = UNION_LSTM1D__CHAINE