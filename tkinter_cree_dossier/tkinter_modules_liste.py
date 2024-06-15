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
from tkinter_cree_dossier.tkinter_insts import i_Softmax
from tkinter_cree_dossier.tkinter_insts import i_Somme2, i_Somme3, i_Somme4
from tkinter_cree_dossier.tkinter_insts import i_Sub2
from tkinter_cree_dossier.tkinter_insts import i_Y, i_Y_canalisation, i_Y_union_2

from tkinter_cree_dossier.tkinter_modules_inst_liste import *

conn = lambda sortie,inst,entree: (sortie, (inst,entree))

######################################################################

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

		assert H>0

		#	------------------

		self.ix = [
			Dico(i=i_Dot1d_X, X=[X], x=[None], xt=[None], y=H, p=[C0,activ], sortie=False)
		]

		for n in range(1, N):
			self.ix += [Dico(i=i_Dot1d_X, X=[H], x=[self.ix[-1]], xt=[0], y=H, p=[C0,activ], sortie=False)]

		self.ix[-1].y      = Y
		self.ix[-1].sortie = True

		return self.ix

class CHAINE_N_DOT1D_RECURENTE(Module_Mdl):
	nom = "Chaine Dot1d Recurrente"
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

		assert H>0
		assert N>0

		#	------------------

		moi = "Moi"

		self.ix = [
			Dico(i=i_Dot1d_XY, X=[X,moi], x=[None,moi], xt=[None,-1], y=H, p=[C0,activ], sortie=False)
		]

		for n in range(1, N):
			self.ix += [Dico(i=i_Dot1d_XY, X=[H,moi], x=[self.ix[-1],moi], xt=[0,-1], y=H, p=[C0,activ], sortie=False)]

		self.ix[-1].y = Y

		for ix in self.ix:
			ix.X[1] = ix.y
			ix.x[1] = ix

		self.ix[-1].sortie = True

		return self.ix

class DOT1D_RECURENTE_N_PROFOND(Module_Mdl):
	nom = "DOT1D RECCURENT N PROFOND"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["H"] # LSTM [X], [H]
	params = {
		'N' : 1,
		'activ' : 0
	}
	def cree_ix(self):
		#	Params
		X = self.X[0]
		Y = self.Y[0]
		#
		N = self.params['N']
		activ = self.params['activ']
		#
		self.elements = {
			'n_x'        : CHAINE_N_DOT1D(X=[X], Y=[X], params={'C0':1,'activ':activ}).cree_ix(),
			'n_recurent' : CHAINE_N_DOT1D(X=[Y], Y=[Y], params={'C0':1,'activ':activ}).cree_ix(),
			'XY' : MODULE_i_Dot1d_XY(X=[X,Y], params={'C0':1, 'activ':activ}).cree_ix(),
		}
		self.connections = {
			'n_x' : {
				0 : None
			},
			'n_recurent' : {
				0 : ('XY', -1),
			},
			'XY' : {
				0 : ('n_x', 0),
				1 : ('n_recurent', 0)
			}
		}
		self.cree_elements_connections()
		return self.ix

class CHAINE_N_DOT1D_RECURENTE_N_PROFONDE(Module_Mdl):
	nom = "CHAINE DOT1D RECC N"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["H"] # LSTM [X], [H]
	params = {
		#'activ' : 0
		'N' : 1,
		'N_rec' : 1,
		'H' : 0
	}
	def cree_ix(self):
		#	Params
		X = self.X[0]
		Y = self.Y[0]
		#
		N = self.params['N']
		N_rec = self.params['N_rec']
		H = self.params['H']

		#	------------------

		_tanh      = 0
		logistique = 1

		self.elements = {}
		self.connections = {}
		#
		self.elements   ['0'] = DOT1D_RECURENTE_N_PROFOND(X=[X], Y=[H], params={'N':N_rec, 'activ':0}).cree_ix()
		self.connections['0'] = {0:None}
		#
		for i in range(1,N-1):
			self.elements   [str(i)] = DOT1D_RECURENTE_N_PROFOND(X=[H], Y=[H], params={'N':N_rec, 'activ':0}).cree_ix()
			self.connections[str(i)] = {0:(str(i-1), 0)}
		#
		self.elements   [str(N-1)] = DOT1D_RECURENTE_N_PROFOND(X=[H], Y=[Y], params={'N':N_rec, 'activ':0}).cree_ix()
		self.connections[str(N-1)] = {0:(str(N-1-1), 0)}

		self.cree_elements_connections()
		return self.ix

############################################

class KCONVL_RELU(Module_Mdl):	#	f(ax0+bx1+cx2+d)
	nom = "Kconvl + Relu"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"] # LSTM [X], [H]
	params = {
		'K' : 3,
		'C0' : 1,
		'C1' : 1,
		'im_X' : 0,
		'im_Y' : 0
	}
	def cree_ix(self):
		#	Params
		K    = self.params['K'   ]
		C0   = self.params['C0'  ]
		C1   = self.params['C1'  ]
		im_X = self.params['im_X']
		im_Y = self.params['im_Y']
		#
		X = self.X[0]
		Y = self.Y[0]
		#
		#	------------------

		self.ix = [
			a:=Dico(i=i_Kconvl1d,   X=[X], x=[None], xt=[None], y=Y, p=[K,C0,C1,im_X,im_Y], sortie=False),
			b:=Dico(i=i_Activation, X=[Y], x=[a],    xt=[0],    y=Y, p=[3], sortie=True),
		]

		return self.ix

#################################################

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

		assert H>0

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

		return self.ix

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

		return self.ix

class MEMOIRE_TANACHIQUE(Module_Mdl):
	nom = "Bloque Memoire tanachique"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"] # LSTM [X], [H]
	params = {
		'Y_Xi' : 1,
		'Y_Yi' : 1,
		'Y_N_connect' : 1,
		'Y_H'  : 0,
		#
		'M_Xi' : 1,
		'M_Yi' : 1,
		'M_N_connect' : 1,
		'M_H'  : 0,
		#
		'M'   : 0,
		#
		'C0'        : 1,
		'activ'     : 0
	}
	def cree_ix(self):
		Y_Xi = self.params['Y_Xi']
		Y_Yi = self.params['Y_Yi']
		Y_N_connect = self.params['Y_N_connect']
		Y_H  = self.params['Y_H']
		#
		M_Xi = self.params['M_Xi']
		M_Yi = self.params['M_Yi']
		M_N_connect = self.params['M_N_connect']
		M_H  = self.params['M_H']
		#
		M     = self.params['M']
		C0    = self.params['C0']
		activ = self.params['activ']
		#
		X = self.X[0]
		Y = self.Y[0]
		#
		ym_m = GRILLE_XY_N_DOT1D(X=[M,Y],Y=[M], params={
			'Xi'        : M_Xi,
			'Yi'        : M_Yi,
			'H'         : M_H,
			'N_connect' : M_N_connect,
			'C0'        : C0,
			'activ'     : activ
		})
		ym_m.cree_ix()
		ym_m = ym_m.ix
		xm_y = GRILLE_XY_N_DOT1D(X=[X,M],Y=[Y], params={
			'Xi'        : Y_Xi,
			'Yi'        : Y_Yi,
			'H'         : Y_H,
			'N_connect' : Y_N_connect,
			'C0'        : C0,
			'activ'     : activ
		})
		xm_y.cree_ix()
		xm_y = xm_y.ix
		#
		ym_m[0]['X']=[M];  ym_m[0]['x']=[ym_m[-1]];  ym_m[0]['xt'] = [1]
		ym_m[1]['X']=[Y];  ym_m[1]['x']=[xm_y[-1]];  ym_m[1]['xt'] = [1]
		#
		xm_y[0]['X']=[X];  xm_y[0]['x']=[    None];  xm_y[0]['xt'] = [0]
		xm_y[1]['X']=[M];  xm_y[1]['x']=[ym_m[-1]];  xm_y[1]['xt'] = [0]
		#
		self.ix = ym_m + xm_y
		#
		for i in self.ix: i['sortie'] = False
		self.ix[-1]['sortie'] = True

		return self.ix

class MEMOIRE_TANACHIQUE_IxI(Module_Mdl):
	nom = "Bloque Memoire tanh IxI"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"] # LSTM [X], [H]
	params = {
		'IxI Grille' : 0,
		'N_connect'  : 0,
		'H'          : 0,
		'M'          : 0,
		'C0'         : 0,
		'activ'      : 0
	}
	def cree_ix(self):
		Grille    = self.params['IxI Grille']
		N_connect = self.params['N_connect']
		H         = self.params['H']
		M         = self.params['M']
		C0        = self.params['C0']
		activ     = self.params['activ']
		#
		#
		m = MEMOIRE_TANACHIQUE()
		m.params['Y_Xi']=Grille
		m.params['Y_Yi']=Grille
		m.params['Y_N_connect']=N_connect
		m.params['Y_H']=H
		#
		m.params['M_Xi']=Grille
		m.params['M_Yi']=Grille
		m.params['M_N_connect']=N_connect
		m.params['M_H']=H
		#
		m.params['M']=M
		#
		m.params['C0']=C0
		m.params['activ']=activ
		#
		m.cree_ix()
		self.ix = m.ix

		return self.ix

#	======================================================================

class DOT1D_1(Module_Mdl):	#	f(ax0+bx1+cx2+d)
	nom = "DOT1D X 1"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X0"], ["Y"] # LSTM [X], [H]
	params = {
		'activ' : 0
	}
	def cree_ix(self):
		#	Params
		activ = self.params['activ']
		X0 = self.X[0]
		Y  = self.Y[0]

		#	------------------

		self.ix = [
			ax0:=Dico(i=i_MatMul, X=[X0 ], x=[None], xt=[None], y=Y, p=[], sortie=False),
			b:=  Dico(i=i_Biais , X=[],    x=[],     xt=[],     y=Y, p=[], sortie=False),

			axb:= Dico(i=i_Somme2,     X=[Y,Y], x=[ax0,b], xt=[0,0], y=Y, p=[],      sortie=False),
			faxb:=Dico(i=i_Activation, X=[Y],   x=[axb ],  xt=[0],   y=Y, p=[activ], sortie=True)
		]

		return self.ix

class DOT1D_2(Module_Mdl):	#	f(ax0+bx1+cx2+d)
	nom = "DOT1D XY 2"
	X, Y = [0,0], [0]
	X_noms, Y_noms = ["X0","X1"], ["Y"] # LSTM [X], [H]
	params = {
		'activ' : 0
	}
	def cree_ix(self):
		#	Params
		activ = self.params['activ']
		X0 = self.X[0]
		X1 = self.X[1]
		Y  = self.Y[0]

		#	------------------

		self.ix = [
			ax0:=Dico(i=i_MatMul, X=[X0 ], x=[None], xt=[None], y=Y, p=[], sortie=False),
			bx1:=Dico(i=i_MatMul, X=[X1 ], x=[None], xt=[None], y=Y, p=[], sortie=False),
			  c:=Dico(i=i_Biais , X=[],    x=[],     xt=[    ], y=Y, p=[], sortie=False),

			axbxc:=Dico(i=i_Somme3,     X=[Y,Y,Y], x=[ax0,bx1,c], xt=[0,0,0], y=Y, p=[],      sortie=False),
			faxb:= Dico(i=i_Activation, X=[Y],     x=[axbxc ],    xt=[0],     y=Y, p=[activ], sortie=True)
		]

		return self.ix

class DOT1D_3(Module_Mdl):	#	f(ax0+bx1+cx2+d)
	nom = "DOT1D XYZ 3"
	X, Y = [0,0,0], [0]
	X_noms, Y_noms = ["X0","X1","X2"], ["Y"] # LSTM [X], [H]
	params = {
		'activ' : 0
	}
	def cree_ix(self):
		#	Params
		activ = self.params['activ']
		X0 = self.X[0]
		X1 = self.X[1]
		X2 = self.X[2]
		Y  = self.Y[0]

		#	------------------

		self.ix = [
			ax0:=Dico(i=i_MatMul, X=[X0 ], x=[None], xt=[None], y=Y, p=[], sortie=False),
			bx1:=Dico(i=i_MatMul, X=[X1 ], x=[None], xt=[None], y=Y, p=[], sortie=False),
			cx2:=Dico(i=i_MatMul, X=[X2 ], x=[None], xt=[None], y=Y, p=[], sortie=False),
			  d:=Dico(i=i_Biais , X=[   ], x=[    ], xt=[    ], y=Y, p=[], sortie=False),

			axbxcxd:=Dico(i=i_Somme4,  X=[Y,Y,Y,Y], x=[ax0,bx1,cx2,d], xt=[0,0,0,0], y=Y, p=[],      sortie=False),
			faxb:=Dico(i=i_Activation, X=[Y],       x=[axbxcxd],       xt=[  0 ],    y=Y, p=[activ], sortie=True)
		]

		return self.ix

class AB_plus_CD(Module_Mdl):
	nom = "A*B + C*D"
	X, Y = [0,0,0,0], [0]
	X_noms, Y_noms = ["A","B","C","D"], ["Y"] # LSTM [X], [H]
	params = {
	}
	def cree_ix(self):
		#	Params
		A = self.X[0]
		B = self.X[1]
		C = self.X[2]
		D = self.X[3]
		Y = self.Y[0]

		assert A==B==C==D==Y

		#	------------------

		self.ix = [
			ab:=Dico(i=i_Mul2,     X=[Y,Y], x=[None,None], xt=[None,None], y=Y, p=[], sortie=False),
			cd:=Dico(i=i_Mul2,     X=[Y,Y], x=[None,None], xt=[None,None], y=Y, p=[], sortie=False),
			abcd:=Dico(i=i_Somme2, X=[Y,Y], x=[ab,cd],     xt=[0,0],       y=Y, p=[], sortie=True),
		]

		return self.ix

class LSTM1D(Module_Mdl):	#	f(ax0+bx1+cx2+d)
	nom = "LSTM 1D"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["H"] # LSTM [X], [H]
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
			# f = logistique(sF = Fx@x + Fh@h[-1] + Fc@c[-1] + Fb)
			'f' : DOT1D_3(X=[X,Y,Y], Y=[Y], params={'activ':logistique}).cree_ix(),
			# i = logistique(sI = Ix@x + Ih@h[-1] + Ic@c[-1] + Ib)
			'i' : DOT1D_3(X=[X,Y,Y], Y=[Y], params={'activ':logistique}).cree_ix(),
			#u =       tanh(sU = Ux@x + Uh@h[-1] +          + Ub)
			'u' : DOT1D_2(X=[X,Y], Y=[Y], params={'activ':_tanh}).cree_ix(),
			#c = f*c[-1] + i*u
			'c' : AB_plus_CD(X=[Y,Y,Y,Y], Y=[Y], params={}).cree_ix(),
			#ch = tanh(c)
			'ch' : MODULE_i_Activation(X=[Y], Y=[Y], params={'activ':_tanh}).cree_ix(),
			#o = logistique(sO = Ox@x + Oh@h[-1] + Oc@c    + Ob)
			'o' : DOT1D_3(X=[X,Y,Y], Y=[Y], params={'activ':logistique}).cree_ix(),
			#h = o * ch
			'h' : MODULE_i_Mul2(X=[Y,Y], Y=[Y], params={}).cree_ix(),
		}

		#	======================

		self.connections = {
			'x' : {
				0 : None,
			},
			'f' : {
				0 : ('x', 0),
				1 : ('h', -1),
				2 : ('c', -1)
			},
			'i' : {
				0 : ('x', 0),
				1 : ('h', -1),
				2 : ('c', -1)
			},
			'u' : {
				0 : ('x', 0),
				1 : ('h', -1)
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
				0 : ('x', 0),
				1 : ('h', -1),
				2 : ('c', -1),
			},
			'h' : {
				0 : ('o', 0),
				1 : ('ch', 0)
			}
		}

		self.cree_elements_connections()
		return self.ix

class CHAINE_N_LSTM(Module_Mdl):
	nom = "Chaine LSTM"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"] # LSTM [X], [H]
	params = {
		'N' : 1,
		'H' : 0
	}
	def cree_ix(self):
		#	Params
		N     = self.params[  'N'  ]
		H     = self.params[  'H'  ]
		X = self.X[0]
		Y = self.Y[0]

		assert N > 1
		assert H > 1

		#	------------------

		self.elements = {}
		self.connections = {}
		#
		self.elements   ['0'] = LSTM1D(X=[X], Y=[H], params={}).cree_ix()
		self.connections['0'] = {0:None}
		#
		for i in range(1,N-1):
			self.elements   [str(i)] = LSTM1D(X=[H], Y=[H], params={}).cree_ix()
			self.connections[str(i)] = {0:(str(i-1), 0)}
		#
		self.elements   [str(N-1)] = LSTM1D(X=[H], Y=[Y], params={}).cree_ix()
		self.connections[str(N-1)] = {0:(str(N-1-1), 0)}

		self.cree_elements_connections()
		return self.ix

#	=========================================================================

class DOT1D_3_PRODONDE_CHAINE(Module_Mdl):	#	f(ax0+bx1+cx2+d)
	nom = "DOT1D_3_PRODONDE_CHAINE"
	X, Y = [0,0,0], [0]
	X_noms, Y_noms = ["X0", "X1", "X2"], ["H"] # LSTM [X], [H]
	params = {
		'N' : 1,
		'activ_fin' : 0
	}
	def cree_ix(self):
		#	Params
		X0 = self.X[0]
		X1 = self.X[1]
		X2 = self.X[2]
		Y  = self.Y[0]

		N = self.params['N']
		activ_fin = self.params['activ_fin']

		self.elements = {
			'_a' : CHAINE_N_DOT1D(X=[X0], Y=[X0], params={'N':N,'H':X0,'C0':1,'activ':0}).cree_ix(),
			'_b' : CHAINE_N_DOT1D(X=[X1], Y=[X1], params={'N':N,'H':X1,'C0':1,'activ':0}).cree_ix(),
			'_c' : CHAINE_N_DOT1D(X=[X2], Y=[X2], params={'N':N,'H':X2,'C0':1,'activ':0}).cree_ix(),
			'abc'    :        DOT1D_3(X=[X0,X1,X2], Y=[Y], params={'activ':0}                   ).cree_ix(),
			'chaine' : CHAINE_N_DOT1D(X=[Y],        Y=[Y], params={'N':N,'H':Y,'C0':1,'activ':0}).cree_ix(),
			'f'      :        DOT1D_1(X=[Y],        Y=[Y], params={'activ':activ_fin}           ).cree_ix(),
		}

		self.connections = {
			'_a' : {0 : None},
			'_b' : {0 : None},
			'_c' : {0 : None},
			'abc' : {
				0 : ('_a', 0),
				1 : ('_b', 0),
				2 : ('_c', 0),
			},
			'chaine' : {0 : ('abc',   0)},
			'f'      : {0 : ('chaine',0)},
		}

		self.cree_elements_connections()
		return self.ix

class DOT1D_2_PRODONDE_CHAINE(Module_Mdl):	#	f(ax0+bx1+cx2+d)
	nom = "DOT1D_2_PRODONDE_CHAINE"
	X, Y = [0,0], [0]
	X_noms, Y_noms = ["X0", "X1"], ["H"] # LSTM [X], [H]
	params = {
		'N' : 1,
		'activ_fin' : 0
	}
	def cree_ix(self):
		#	Params
		X0 = self.X[0]
		X1 = self.X[1]
		Y  = self.Y[0]

		N = self.params['N']
		activ_fin = self.params['activ_fin']

		self.elements = {
			'_a' : CHAINE_N_DOT1D(X=[X0], Y=[X0], params={'N':N,'H':X0,'C0':1,'activ':0}).cree_ix(),
			'_b' : CHAINE_N_DOT1D(X=[X1], Y=[X1], params={'N':N,'H':X1,'C0':1,'activ':0}).cree_ix(),
			'ab'     :        DOT1D_2(X=[X0,X1], Y=[Y], params={'activ':0}                   ).cree_ix(),
			'chaine' : CHAINE_N_DOT1D(X=[Y],     Y=[Y], params={'N':N,'H':Y,'C0':1,'activ':0}).cree_ix(),
			'f'      :        DOT1D_1(X=[Y],     Y=[Y], params={'activ':activ_fin}           ).cree_ix(),
		}

		self.connections = {
			'_a' : {0 : None},
			'_b' : {0 : None},
			'ab' : {
				0 : ('_a', 0),
				1 : ('_b', 0)
			},
			'chaine' : {0 : ('ab',     0)},
			'f'      : {0 : ('chaine', 0)},
		}

		self.cree_elements_connections()
		return self.ix

class LSTM1D_PLUS_PROFOND(Module_Mdl):	#	f(ax0+bx1+cx2+d)
	nom = "LSTM 1D Plus Profond"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["H"] # LSTM [X], [H]
	params = {
		'N' : 1,
		#'activ' : 0
	}
	def cree_ix(self):
		#	Params
		X = self.X[0]
		Y = self.Y[0]

		N = self.params['N']

		#	------------------

		_tanh      = 0
		logistique = 1

		self.elements = {
			'x' : MODULE_i_Y(X=[X], Y=[X], params={}).cree_ix(),
			# f = logistique(sF = Fx@x + Fh@h[-1] + Fc@c[-1] + Fb)
			'f' : DOT1D_3_PRODONDE_CHAINE(X=[X,Y,Y], Y=[Y], params={'N':N, 'activ_fin':logistique}).cree_ix(),
			# i = logistique(sI = Ix@x + Ih@h[-1] + Ic@c[-1] + Ib)
			'i' : DOT1D_3_PRODONDE_CHAINE(X=[X,Y,Y], Y=[Y], params={'N':N, 'activ_fin':logistique}).cree_ix(),
			#u =       tanh(sU = Ux@x + Uh@h[-1] +          + Ub)
			'u' : DOT1D_2_PRODONDE_CHAINE(X=[X,Y], Y=[Y], params={'N':N, 'activ_fin':_tanh}).cree_ix(),
			#c = f*c[-1] + i*u
			'c' : AB_plus_CD(X=[Y,Y,Y,Y], Y=[Y], params={}).cree_ix(),
			#ch = tanh(c)
			'ch' : MODULE_i_Activation(X=[Y], Y=[Y], params={'activ':_tanh}).cree_ix(),
			#o = logistique(sO = Ox@x + Oh@h[-1] + Oc@c    + Ob)
			'o' : DOT1D_3_PRODONDE_CHAINE(X=[X,Y,Y], Y=[Y], params={'N':N, 'activ_fin':logistique}).cree_ix(),
			#h = o * ch
			'h' : MODULE_i_Mul2(X=[Y,Y], Y=[Y], params={}).cree_ix(),
		}

		#	======================

		self.connections = {
			'x' : {
				0 : None,
			},
			'f' : {
				0 : ('x', 0),
				1 : ('h', -1),
				2 : ('c', -1)
			},
			'i' : {
				0 : ('x', 0),
				1 : ('h', -1),
				2 : ('c', -1)
			},
			'u' : {
				0 : ('x', 0),
				1 : ('h', -1)
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
				0 : ('x', 0),
				1 : ('h', -1),
				2 : ('c', -1),
			},
			'h' : {
				0 : ('o', 0),
				1 : ('ch', 0)
			}
		}

		self.cree_elements_connections()
		return self.ix

#	=========================================================================

class Chaine_Residuelle_LSTM(Module_Mdl):	#	f(ax0+bx1+cx2+d)
	nom = "Chaine Residuelle LSTM"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["X"] # LSTM [X], [H]
	params = {
		'N' : 1,
		'H' : 0,
		'C0' : 1,
		'activ' : 0
	}
	def cree_ix(self):
		#	Params
		X = self.X[0]
		Y = self.Y[0]

		N     = self.params[  'N'  ]
		H     = self.params[  'H'  ]
		C0    = self.params[ 'C0'  ]
		activ = self.params['activ']

		assert X==Y

		#	------------------

		_tanh      = 0
		logistique = 1

		self.ix = []

		self.elements = {
			'x' : MODULE_i_Y(X=[X], Y=[X], params={}).cree_ix(),
			'residu0' : CHAINE_N_DOT1D(X=[X], Y=[X], params={
				'N' : N,
				'H' : H,
				'C0' : C0,
				'activ' : activ
			}).cree_ix(),
			'lstm' : LSTM1D(X=[X], Y=[X], params={

			}).cree_ix(),
			'residu1' : CHAINE_N_DOT1D(X=[X], Y=[X], params={
				'N' : N,
				'H' : H,
				'C0' : C0,
				'activ' : activ
			}).cree_ix(),
			'somme' : MODULE_i_Somme2(X=[X,X], Y=[X], params={}).cree_ix()
		}

		self.connections = {
			'x' : {
				0 : None,
			},
			'residu0' : {
				0 : ('x', 0)
			},
			'lstm' : {
				0 : ('residu0', 0)
			},
			'residu1' : {
				0 : ('lstm', 0)
			},
			'somme' : {
				0 : ('x', 0),
				1 : ('residu1', 0)
			}
		}

		self.cree_elements_connections()
		return self.ix

class MUL_POID(Module_Mdl):
	nom = "MUL POIDS"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["X"] # LSTM [X], [H]
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
			'poid' : MODULE_i_Biais(X=[], Y=[X], params={}).cree_ix(),
			'mul'  : MODULE_i_Mul2(X=[X,X], Y=[X], params={}).cree_ix(),
		}

		self.connections = {
			'poid' : {
				#0 : None,
			},
			'mul' : {
				0 : None,
				1 : ('poid', 0)
			},
		}

		self.cree_elements_connections()
		return self.ix

class LSTM1D_CONVOLUTION(Module_Mdl):	#	f(ax0+bx1+cx2+d)
	nom = "LSTM1D_CONVOLUTION"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["H"] # LSTM [X], [H]
	params = {
		#'activ' : 0
		'K'    : 3,
		'C0'   : 1,
		'C1'   : 1,
		'im_X' : 0
	}
	def cree_ix(self):
		#	Params
		X = self.X[0]
		Y = self.Y[0]

		K    = self.params['K']
		C0   = self.params['C0']
		C1   = self.params['C1']
		im_X = self.params['im_X']

		assert X == C0*im_X
		assert Y == C1*im_X

		#	------------------

		_tanh      = 0
		logistique = 1

		params_kconvl = {'K':K, 'C0':C0, 'C1':C1, 'im_X':im_X}
		params_kconvl_C1C1 = {'K':K, 'C0':C1, 'C1':C1, 'im_X':im_X}

		self.elements = {
			'x' : MODULE_i_Y(X=[X], Y=[X], params={}).cree_ix(),

			# f = logistique(sF = Fx@x + Fh@h[-1] + Fc@c[-1] + Fb)
			'f_x' : MODULE_i_Kconvl1d_stricte(X=[X], Y=[Y], params=params_kconvl).cree_ix(),
			'f_h' : MODULE_i_Kconvl1d_stricte(X=[Y], Y=[Y], params=params_kconvl_C1C1).cree_ix(),
			'f_c' :                  MUL_POID(X=[Y], Y=[Y], params={}).cree_ix(),
			'f_b' :  MODULE_i_Biais(X=[],  Y=[Y], params={}).cree_ix(),
			'f_s' : MODULE_i_Somme4(X=[Y,Y,Y,Y], Y=[Y], params={}).cree_ix(),
			'f_a' : MODULE_i_Activation(X=[Y], Y=[Y], params={'activ':logistique}).cree_ix(),
			
			# i = logistique(sI = Ix@x + Ih@h[-1] + Ic@c[-1] + Ib)
			'i_x' : MODULE_i_Kconvl1d_stricte(X=[X], Y=[Y], params=params_kconvl).cree_ix(),
			'i_h' : MODULE_i_Kconvl1d_stricte(X=[Y], Y=[Y], params=params_kconvl_C1C1).cree_ix(),
			'i_c' :                  MUL_POID(X=[Y], Y=[Y], params={}).cree_ix(),
			'i_b' :  MODULE_i_Biais(X=[],  Y=[Y], params={}).cree_ix(),
			'i_s' : MODULE_i_Somme4(X=[Y,Y,Y,Y], Y=[Y], params={}).cree_ix(),
			'i_a' : MODULE_i_Activation(X=[Y], Y=[Y], params={'activ':logistique}).cree_ix(),
			
			#u =       tanh(sU = Ux@x + Uh@h[-1] +          + Ub)
			'u_x' : MODULE_i_Kconvl1d_stricte(X=[X], Y=[Y], params=params_kconvl).cree_ix(),
			'u_h' : MODULE_i_Kconvl1d_stricte(X=[Y], Y=[Y], params=params_kconvl_C1C1).cree_ix(),
			'u_b' :            MODULE_i_Biais(X=[],  Y=[Y], params={}).cree_ix(),
			'u_s' : MODULE_i_Somme3(X=[Y,Y,Y], Y=[Y], params={}).cree_ix(),
			'u_a' : MODULE_i_Activation(X=[Y], Y=[Y], params={'activ':_tanh}).cree_ix(),
			
			#c = f*c[-1] + i*u
			'c' : AB_plus_CD(X=[Y,Y,Y,Y], Y=[Y], params={}).cree_ix(),
			
			#ch = tanh(c)
			'ch' : MODULE_i_Activation(X=[Y], Y=[Y], params={'activ':_tanh}).cree_ix(),
			
			#o = logistique(sO = Ox@x + Oh@h[-1] + Oc@c    + Ob)
			'o_x' : MODULE_i_Kconvl1d_stricte(X=[X], Y=[Y], params=params_kconvl).cree_ix(),
			'o_h' : MODULE_i_Kconvl1d_stricte(X=[Y], Y=[Y], params=params_kconvl_C1C1).cree_ix(),
			'o_c' :                  MUL_POID(X=[Y], Y=[Y], params={}).cree_ix(),
			'o_b' :  MODULE_i_Biais(X=[],  Y=[Y], params={}).cree_ix(),
			'o_s' : MODULE_i_Somme4(X=[Y,Y,Y,Y], Y=[Y], params={}).cree_ix(),
			'o_a' : MODULE_i_Activation(X=[Y], Y=[Y], params={'activ':logistique}).cree_ix(),
			
			#h = o * ch
			'h' : MODULE_i_Mul2(X=[Y,Y], Y=[Y], params={}).cree_ix(),
		}

		#	======================

		self.connections = {
			'x' : {0 : None},
			#
			'f_x' : {0:('x', 0)},
			'f_h' : {0:('h', -1)},
			'f_c' : {0:('c', -1)},
			'f_s' : {0:('f_x', 0), 1:('f_h', 0), 2:('f_c', 0), 3:('f_b', 0)},
			'f_a' : {0:('f_s', 0)},
			#
			'i_x' : {0:('x', 0)},
			'i_h' : {0:('h', -1)},
			'i_c' : {0:('c', -1)},
			'i_s' : {0:('i_x', 0), 1:('i_h', 0), 2:('i_c', 0), 3:('i_b', 0)},
			'i_a' : {0:('i_s', 0)},
			#
			'u_x' : {0:('x', 0)},
			'u_h' : {0:('h', -1)},
			'u_s' : {0:('u_x', 0), 1:('u_h', 0), 2:('u_b', 0)},
			'u_a' : {0:('u_s', 0)},
			#
			'c' : {
				0 : ('f_a', 0),
				1 : ('c', -1),
				2 : ('i_a', 0),
				3 : ('u_a', 0)
			},
			'ch' : {
				0 : ('c', 0),
			},
			#
			'o_x' : {0:('x', 0)},
			'o_h' : {0:('h', -1)},
			'o_c' : {0:('c', 0)},
			'o_s' : {0:('o_x', 0), 1:('o_h', 0), 2:('o_c', 0), 3:('o_b', 0)},
			'o_a' : {0:('o_s', 0)},
			#
			'h' : {
				0 : ('o_a', 0),
				1 : ('ch', 0)
			}
		}

		self.cree_elements_connections()
		return self.ix

#	==============================================================

class LSTM1D_PARRALLELE(Module_Mdl):	#	f(ax0+bx1+cx2+d)
	nom = "LSTM1D Parallèle"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"] # LSTM [X], [H]
	params = {
		'P' : 1,
	}
	def cree_ix(self):
		#	Params
		X = self.X[0]
		Y = self.Y[0]

		N = self.params['P']
		assert N > 0
		from math import log
		assert log(N, 2) == int(log(N, 2))

		#	------------------

		_tanh      = 0
		logistique = 1

		#	------------------

		self.elements = {
			'x' : MODULE_i_Y(X=[X], Y=[X], params={}).cree_ix(),
		}
		self.connections = {
			'x' : {0:None}
		}

		for i in range(N):
			self.elements[f'{i}b'   ] = MODULE_i_Biais(
				X=[ ], Y=[X], params={}).cree_ix()
			#
			self.elements[f'{i}a'   ] = MODULE_i_Activation(
				X=[X], Y=[X], params={'activ':logistique}).cree_ix()
			#
			self.elements[f'{i}m'   ] = MODULE_i_Mul2(
				X=[X,X], Y=[X], params={}).cree_ix()
			#
			self.elements[f'{i}lstm'] = LSTM1D(
				X=[X], Y=[Y], params={}).cree_ix()
			#
			self.connections[f'{i}b'   ] = {0:( 'x',    0)            }
			self.connections[f'{i}a'   ] = {0:(f'{i}b', 0)            }
			self.connections[f'{i}m'   ] = {0:(f'{i}a', 0), 1:('x', 0)}
			self.connections[f'{i}lstm'] = {0:(f'{i}m', 0)            }

		L = int(log(N, 2))

		K = int(N / (2**(0+1)))
		for j in range(K):
			self.elements[f'{0}somme{j}'] = MODULE_i_Somme2(X=[Y,Y], Y=[Y], params={}).cree_ix()
			self.connections[f'{0}somme{j}'] = {0:(f'{j*2}lstm',0), 1:(f'{j*2+1}lstm',0)}

		for i in range(1, L):
			K = int(N / (2**(i+1)))
			for j in range(K):
				self.elements[f'{i}somme{j}'] = MODULE_i_Somme2(X=[Y,Y], Y=[Y], params={}).cree_ix()
				self.connections[f'{i}somme{j}'] = {
					0 : (f'{i-1}somme{j*2+0}', 0),
					1 : (f'{i-1}somme{j*2+1}', 0)
				}

		print(self.elements)
		print(self.connections)

		for k,v in self.elements.items():
			print(k,v)
		print("===== Connections =======\n")
		for k,v in self.connections.items():
			print(k,v)

		self.cree_elements_connections()
		return self.ix

#	======================================================

class GRU1D(Module_Mdl):	#	f(ax0+bx1+cx2+d)
	nom = "GRU 1D"
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

class CHAINE_GRU1D(Module_Mdl):	#	f(ax0+bx1+cx2+d)
	nom = "Chaine GRU"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"] # LSTM [X], [H]
	params = {
		'N' : 1,
		'H' : 0
	}
	def cree_ix(self):
		#	Params
		N     = self.params[  'N'  ]
		H     = self.params[  'H'  ]
		X = self.X[0]
		Y = self.Y[0]

		assert N > 1
		assert H > 1

		#	------------------

		self.elements = {}
		self.connections = {}
		#
		self.elements   ['0'] = GRU1D(X=[X], Y=[H], params={}).cree_ix()
		self.connections['0'] = {0:None}
		#
		for i in range(1,N-1):
			self.elements   [str(i)] = GRU1D(X=[H], Y=[H], params={}).cree_ix()
			self.connections[str(i)] = {0:(str(i-1), 0)}
		#
		self.elements   [str(N-1)] = GRU1D(X=[H], Y=[Y], params={}).cree_ix()
		self.connections[str(N-1)] = {0:(str(N-1-1), 0)}

		self.cree_elements_connections()
		return self.ix

#	======================================================

class SORTIE_SIMPLE(Module_Mdl):	#	f(ax0+bx1+cx2+d)
	nom = "SORTIE SIMPLE"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"] # LSTM [X], [H]
	params = {
		'H' : 1,
		'N' : 0
	}
	def cree_ix(self):
		#	Params
		N     = self.params[  'N'  ]
		H     = self.params[  'H'  ]
		X = self.X[0]
		Y = self.Y[0]

		assert N > 1
		assert H > 1

		#	------------------

		self.elements = {
			'x' : MODULE_i_Y(X=[X], Y=[X], params={}).cree_ix(),

			'A' : CHAINE_N_DOT1D(X=[X], Y=[1], params={})
			'P' :
		}
		self.connections = {
			'x' : {0:None},
		}

		self.cree_elements_connections()
		return self.ix

#	======================================================

class RESEAU_DO1D(Module_Mdl):
	nom = "RESEAU DO1D"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"] # LSTM [X], [H]
	params = {
		'[META] Neurones par couche' : 1,
		'[META] Couches' : 1,
		'[META] Y du dot1d partout' : 1,
		'[Neurone] entree : Grille XY' : 1,
		'[Neurone] entree : Grille-N-connecte' : 1,
		'[Neurone] sortie : N-connect'         : 1,
	}

modules = [
	#KCONVL_RELU,
	#
	CHAINE_N_DOT1D,
	CHAINE_N_DOT1D_RECURENTE,
	CHAINE_N_DOT1D_RECURENTE_N_PROFONDE,
	DOT1D_3,
	#
	#GRILLE_XY_DOT1D,
	#GRILLE_XY_N_DOT1D,
	GRU1D,
	CHAINE_GRU1D,
	#
	LSTM1D,
	CHAINE_N_LSTM,
	LSTM1D_PLUS_PROFOND,
	#
	LSTM1D_CONVOLUTION,
	Chaine_Residuelle_LSTM,
	#
	LSTM1D_PARRALLELE,
	#
	#RESEAU_DO1D


	SORTIE_SIMPLE
]