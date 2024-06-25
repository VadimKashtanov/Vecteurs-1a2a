from tkinter_cree_dossier.modules._etc import *

from tkinter_cree_dossier.modules.dot1d import DOT1D, DOT1D__CHAINE

class RESEAU(Module_Mdl):
	bg = 'cyan'
	fg = 'black'
	nom = "[RESEAU]"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"] # LSTM [X], [H]
	params = {
		'H' : 1,
		'N' : 0,
		'activ cachée' : 0,
		'activ sortie' : 0,
		'C0' : 1,
	}
	def cree_ix(self):
		#	Params
		N = self.params['N']
		H = self.params['H']

		ac_ca = self.params['activ cachée']
		ac_so = self.params['activ sortie']

		C0 = self.params['C0']

		X = self.X[0]
		Y = self.Y[0]

		assert N > 1
		assert H > 1

		#	------------------

		self.elements = {
			'reseau' : DOT1D__CHAINE(X=[X], Y=[H], params={'N':N-1, 'H':H, 'C0':C0, 'activ':ac_ca}).cree_ix(),
			'sortie' : DOT1D        (X=[H], Y=[Y], params={'C0':C0, 'activ':ac_so}).cree_ix()
		}
		self.connections = {
			'reseau'     : {0:None},
			'sortie' : {0:('reseau', 0)}
		}

		self.cree_elements_connections()
		return self.ix