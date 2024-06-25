from tkinter_cree_dossier.modules._etc import *

class LSTM1D_CONVOLUTION(Module_Mdl):	#	f(ax0+bx1+cx2+d)
	bg = 'light yellow'
	fg = 'black'
	nom = "[LSTM CONVOL]"
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