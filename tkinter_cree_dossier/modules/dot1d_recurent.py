from tkinter_cree_dossier.modules._etc import *

class RECURENT_DOT1D__CHAINE(Module_Mdl):
	bg = 'white'
	fg = 'black'
	nom = "[DOT1D_RECCURENT] Chaine"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"] # LSTM [X], [H]
	params = {
		'H' : 0,
		'N' : 1,
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
