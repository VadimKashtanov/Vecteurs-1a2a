from tkinter_cree_dossier.modules._etc import *

from tkinter_cree_dossier.modules.dot1d              import *
from tkinter_cree_dossier.modules.dot1d_recurent     import *
from tkinter_cree_dossier.modules.dot1d_recurent_spe import *
from tkinter_cree_dossier.modules.gru1d              import *
from tkinter_cree_dossier.modules.lstm1d             import *
from tkinter_cree_dossier.modules.lstm1d_kconvl      import *
from tkinter_cree_dossier.modules.union_lstm         import *

from tkinter_cree_dossier.modules.attention          import *

from tkinter_cree_dossier.modules.reseau             import *
from tkinter_cree_dossier.modules.lstm_speciale      import *

class SORTIE_SIMPLE(Module_Mdl):	#	f(ax0+bx1+cx2+d)
	bg = 'cyan'
	fg = 'black'
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

			'A' : RESEAU(X=[X], Y=[1], params={'N':N, 'H':H, 'C0':1, 'activ cachée':0, 'activ sortie':0}).cree_ix(),
			'P' : RESEAU(X=[X], Y=[1], params={'N':N, 'H':H, 'C0':1, 'activ cachée':0, 'activ sortie':0}).cree_ix(),

			'sortie' : MODULE_i_Y_union_2(X=[1,1], Y=[2], params={}).cree_ix()
		}
		self.connections = {
			'x' : {0:None},
			'A' : {0:('x', 0)},
			'P' : {0:('x', 0)},
			'sortie':{0:('A',0), 1:('P',0)}
		}

		self.cree_elements_connections()
		return self.ix

class NONE(Module_Mdl):	#	f(ax0+bx1+cx2+d)
	nom = ""
	X, Y = [], []
	X_noms, Y_noms = [], [] # LSTM [X], [H]
	params = {
	}
	def cree_ix(self):
		return []

#	=========================================================================	#

modules = [
	DOT1D,
	DOT1D__CHAINE,
	DOT1D__CHAINE__RESIDUELLE,
	#
	RECURENT_DOT1D_SPE,
	RECURENT_DOT1D_SPE__CHAINE,
	RECURENT_DOT1D_SPE__CHAINE__RESIDUELLE,
	#	--------------------
	LSTM1D,
	LSTM1D__CHAINE,
	LSTM1D__CHAINE__RESIDUELLE,
	#
	GRU1D,
	GRU1D__CHAINE,
	GRU1D__CHAINE__RESIDUELLE,
	#	---------------------
	UNION_LSTM1D,
	UNION_LSTM1D__CHAINE,
	UNION_LSTM1D__CHAINE__RESIDUELLE,
	#
	LSTM1D_CONVOLUTION,
	NONE,
	NONE,
	#	--------------------
	LSTM1D_SPECIALE,
	NONE,
	NONE,
	#
	ATTENTION,
	NONE,
	NONE,
	#	--------------------
	SORTIE_SIMPLE,
	NONE,
	NONE,
	#
	RESEAU,
	SOFTMAX,
	RECURENT_DOT1D__CHAINE
]