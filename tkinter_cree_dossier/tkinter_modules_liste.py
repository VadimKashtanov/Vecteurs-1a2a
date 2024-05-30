from tkinter_cree_dossier.tkinter_mdl import Module_Mdl
from tkinter_cree_dossier.tkinter_dico_inst import Dico

from tkinter_cree_dossier.tkinter_insts import i__Entree
from tkinter_cree_dossier.tkinter_insts import i_Activation
from tkinter_cree_dossier.tkinter_insts import i_Biais
from tkinter_cree_dossier.tkinter_insts import i_Dot1d_X, i_Dot1d_XY
from tkinter_cree_dossier.tkinter_insts import i_Kconvl1d_stricte, i_Kconvl2d_stricte
from tkinter_cree_dossier.tkinter_insts import i_MatMul, i_MatMul_Canal
from tkinter_cree_dossier.tkinter_insts import i_Mul2, i_Mul3
from tkinter_cree_dossier.tkinter_insts import i_Pool2_1d, i_Pool2x2_2d
from tkinter_cree_dossier.tkinter_insts import i_Softmax
from tkinter_cree_dossier.tkinter_insts import i_Somme2, i_Somme3, i_Somme4
from tkinter_cree_dossier.tkinter_insts import i_Y, i_Y_canalisation

conn = lambda sortie,inst,entree: (sortie, (inst,entree))

#	======================================================================

class CHAINE_N_DOT1D(Module_Mdl):
	nom = "Chaine Dot1d"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"] # LSTM [X], [H]
	params = {
		'N' : 1,
		'H' : 0,
		'C0' : 1,
		'activ' : 0
	}
	def cree_ix(self):
		#	Params
		N     = self.params[  'N'  ]
		H     = self.params[  'H'  ]
		C0    = self.params[ 'C0'  ]
		activ = self.params['activ']
		X = self.X[0]
		Y = self.Y[0]

		#	------------------

		self.ix = [
			Dico(i=i_Dot1d_X, X=[X], x=[None], xt=[None], y=H, p=[C0,activ], sortie=False)
		]

		for n in range(1, N):
			self.ix += [Dico(i=i_Dot1d_X, X=[H], x=[self.ix[-1]], xt=[0], y=H, p=[C0,activ], sortie=False)]

		self.ix[-1].y      = Y
		self.ix[-1].sortie = True

class GRILLE_XY_DOT1D(Module_Mdl):
	nom = "Grille XY dot1d"
	X, Y = [0,0], [0]
	X_noms, Y_noms = ["X0", "X1"], ["Y"] # LSTM [X], [H]
	params = {
		'Xi'        : 1,
		'Yi'        : 1,
		'H '        : 1,
		'C0'        : 1,
		'activ'     : 0
	}
	def cree_ix(self):
		#	Params
		Xi     = self.params['Xi'       ]
		Yi     = self.params['Yi'       ]
		H      = self.params['H '       ]
		C0     = self.params['C0'       ]
		activ  = self.params['activ'    ]
		X0, X1 = self.X
		Y      = self.Y[0]

		#	---------------------------

		#	Reseaux : Repasser sur la meme
		#	faire une boucle de N fois

		Y_source_X0 = Dico(i=i_Y, X=[X0], x=[None], xt=[None], y=X0, p=[], sortie=False)
		Y_source_X1 = Dico(i=i_Y, X=[X1], x=[None], xt=[None], y=X1, p=[], sortie=False)

		grille = [[None for _ in range(Xi)] for _ in range(Yi)]

		grille[0][0] = Dico(i=i_Dot1d_XY, X=[X0,X1], x=[Y_source_X0, Y_source_X1], xt=[0, 0], y=H, p=[C0,activ], sortie=False)

		for i in range(1, Xi):
			grille[0][i] = Dico(i=i_Dot1d_XY, X=[H,X1], x=[grille[0][i-1], Y_source_X1], xt=[0, 0], y=H, p=[C0,activ], sortie=False)

		for i in range(1, Yi):
			grille[i][0] = Dico(i=i_Dot1d_XY, X=[X0,H], x=[Y_source_X0, grille[i-1][0]], xt=[0, 0], y=H, p=[C0,activ], sortie=False)

		for _y in range(1, Yi):
			for _x in range(1, Xi):
				grille[_y][_x] = Dico(i=i_Dot1d_XY, X=[H,H], x=[grille[_y][_x-1], grille[_y-1][_x]], xt=[0, 0], y=H, p=[C0,activ], sortie=False)

		self.ix = [
			Y_source_X0,
			Y_source_X1
		] + [
			grille[i][j]
			for i in range(Yi)
				for j in range(Xi)
		]

		#	---------------------------

		self.ix[-1].y      = Y
		self.ix[-1].sortie = True

class GRILLE_XY_N_DOT1D(Module_Mdl):
	nom = "Grille XY avec N_dot1d"
	X, Y = [0,0], [0]
	X_noms, Y_noms = ["X0", "X1"], ["Y"] # LSTM [X], [H]
	params = {
		'Xi'        : 1,
		'Yi'        : 1,
		'H'         : 1,
		'N_connect' : 1,
		'C0'        : 1,
		'activ'     : 0
	}
	def cree_ix(self):
		X0, X1 = self.X
		Y = self.Y[0]
		#	Params
		Xi        = self.params['Xi'       ]
		Yi        = self.params['Yi'       ]
		H         = self.params['H'        ]
		N_connect = self.params['N_connect']
		C0        = self.params['C0'       ]
		activ     = self.params['activ'    ]
		X = self.X[0]
		Y = self.Y[0]

		#	---------------------------

		grille = GRILLE_XY_DOT1D(
			X=[X0,X1],
			Y=[Y],
			params={
				'Xi'    : Xi,
				'Yi'    : Yi,
				'H '    :  H,
				'C0'    : C0,
				'activ' : activ
		})
		grille.cree_ix()
		g_ix = grille.ix

		self.ix = [g_ix[0], g_ix[1]]

		#	--------------------------

		for k,l in enumerate(g_ix[2:]):
			#print(k, l)
			chaine_x = CHAINE_N_DOT1D(X=[l['X'][0]],Y=[H], params={
				'N' : N_connect,
				'H' : H,
				'C0' : C0,
				'activ' : activ
			})
			chaine_x.cree_ix()
			_ix_x = chaine_x.ix
			_ix_x[0]['x' ] = [l['x' ][0]]
			_ix_x[0]['xt'] = [l['xt'][0]]
			#
			#
			#
			chaine_y = CHAINE_N_DOT1D(X=[l['X'][1]],Y=[H], params={
				'N' : N_connect,
				'H' : H,
				'C0' : C0,
				'activ' : activ
			})
			chaine_y.cree_ix()
			_ix_y = chaine_y.ix
			_ix_y[0]['x' ] = [l['x' ][1]]
			_ix_y[0]['xt'] = [l['xt'][1]]
			#
			#
			#
			self.ix += _ix_x + _ix_y
			l['X'][0] = _ix_x[-1].y
			l['X'][1] = _ix_y[-1].y
			l['x'][0] = _ix_x[-1]
			l['x'][1] = _ix_y[-1]
			l['xt'][0] = 0
			l['xt'][1] = 0
			self.ix += [l]

		#	--------------------------
		#self.ix[-1]['y'] = Y
		#
		for i in self.ix: i['sortie'] = False
		self.ix[-1]['sortie'] = True

		#print(" ================= ");
		#for i in self.ix:
		#	print(i)
		#print(" ================= ");

class MEMOIRE_TANACHIQUE(Module_Mdl):
	nom = "Bloque Memoire tanachique"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"] # LSTM [X], [H]
	params = {
		
	}
	def cree_ix(self):
		# Eviter Y.cuh (c'est lent) (ou pas)
		pass

#	======================================================================

"""class LSTM1D(Module_Mdl):	#	f(ax0+bx1+cx2+d)
	nom = "LSTM 1D"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["H"] # LSTM [X], [H]
	params = {
		#'activ' : 0
	}
	def cree_ix(self):
		#	Params
		activ = self.params['activ']
		X = self.X[0]
		Y = self.Y[0]

		#	------------------

		_tanh      = 0
		logistique = 1

		h = "ref a h"
		c = "ref a c"

		self.ix = [
		# f = logistique(sF = Fx@x + Fh@h + Fc@c[-1] + Fb)
		# i = logistique(sI = Ix@x + Ih@h + Ic@c[-1] + Ib)
		#u =       tanh(sU = Ux@x + Uh@h +          + Ub)
		#c = f*c[-1] + i*u

		#ch = tanh(c)

		#o = logistique(sO = Ox@x + Oh@h + Oc@c    + Ob)

		
		#h = o * ch
		]

		#for l in self.ix:
		#	if h alors 'x', 'xt' = h
		#	if c alors 'x', 'xt' = c

		for i in range(len(self.ix)):
			assert self.ix[i][str(i)] == i"""

modules = [
	CHAINE_N_DOT1D, GRILLE_XY_DOT1D, GRILLE_XY_N_DOT1D,
	MEMOIRE_TANACHIQUE
]