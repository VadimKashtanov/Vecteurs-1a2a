from tkinter_cree_dossier.modules._etc import *

from tkinter_cree_dossier.modules.dot1d import DOT1D__CHAINE

class RECURENT_DOT1D_SPE(Module_Mdl):
	bg, fg = 'light grey', 'black'
	nom = "[RECURENT_DOT1D_SPE]"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"] # LSTM [X], [H]
	params = {
		'H-analyseX' : 0,
		'N-analyseX' : 1,
		#
		'H-neurone' : 0,
		'N-neurone' : 1,
		#
		'H-recurent' : 0,
		'N-recurent' : 1,
		#
		'C0' : 1,
		'activ' : 0
	}
	def cree_ix(self):
		#	Params
		X = self.X[0]
		Y = self.Y[0]
		#
		H_analyseX = self.params['H-analyseX']
		N_analyseX = self.params['N-analyseX']
		#
		H_neurone  = self.params['H-neurone']
		N_neurone  = self.params['N-neurone']
		#
		H_recurent = self.params['H-recurent']
		N_recurent = self.params['N-recurent']
		#
		C0    = self.params['C0'   ]
		activ = self.params['activ']

		#	------------------

		_tanh      = 0
		logistique = 1

		self.elements = {
			'x' : MODULE_i_Y(X=[X], Y=[X], params={}).cree_ix(),
			#
			'chaine_X' : DOT1D__CHAINE(X=[X], Y=[X],   params={'H':H_analyseX, 'N':N_analyseX, 'C0':C0, 'activ':activ}).cree_ix(),
			#
			'recurent' : DOT1D__CHAINE(X=[Y], Y=[Y],   params={'H':H_recurent, 'N':N_recurent, 'C0':C0, 'activ':activ}).cree_ix(),
			#
			'concate'  : MODULE_i_Y_union_2(X=[X,Y], Y=[X+Y], params={}).cree_ix(),
			#
			'neurone'  : DOT1D__CHAINE(X=[X+Y], Y=[Y], params={'H':H_neurone, 'N':N_neurone, 'C0':C0, 'activ':activ}).cree_ix(),
		}

		#	======================

		self.connections = {
			'x' : {
				0 : None,
			},
			'chaine_X' : {
				0 : ('x', 0)
			},
			'recurent' : {
				0 : ('neurone', -1),
			},
			'concate' : {
				0 : ('chaine_X', 0),
				1 : ('recurent', 0)
			},
			'neurone' : {
				0 : ('concate', 0)
			}
		}

		self.cree_elements_connections()
		return self.ix

class RECURENT_DOT1D_SPE__CHAINE(CHAINE):
	img = img_chaine
	bg, fg = 'light grey', 'black'
	nom = "[RECURENT_DOT1D_SPE] CHAINE"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"]
	params = {
		'H-analyseX' : 0,
		'N-analyseX' : 1,
		#
		'H-neurone' : 0,
		'N-neurone' : 1,
		#
		'H-recurent' : 0,
		'N-recurent' : 1,
		#
		'C0' : 1,
		'activ' : 0,
		#
		'H' : 0,
		'N' : 1,
	}
	#	--------------------------
	H       = 'H'
	N       = 'N'
	ELEMENT = RECURENT_DOT1D_SPE

class RECURENT_DOT1D_SPE__CHAINE__RESIDUELLE(RESIDUE):
	img = img_chaine_residue
	bg, fg = 'light grey', 'black'
	nom = "[RECURENT_DOT1D_SPE Chaine] Res"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"] # LSTM [X], [H]
	params = {
		'H-analyseX' : 0,
		'N-analyseX' : 1,
		#
		'H-neurone' : 0,
		'N-neurone' : 1,
		#
		'H-recurent' : 0,
		'N-recurent' : 1,
		#
		'C0' : 1,
		'activ' : 0,
		#
		'H' : 0,
		'N' : 0,
	}
	#	--------------------------
	ELEMENT = RECURENT_DOT1D_SPE__CHAINE