from tkinter_cree_dossier.modules._etc import *

class DOT1D(MODULE_i_Dot1d_X):
	bg, fg = 'white', 'black'
	nom = "[DOT1D]"

class DOT1D__CHAINE(CHAINE):
	img = img_chaine
	bg, fg = 'white', 'black'
	nom = "[DOT1D] CHAINE"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"]
	params = {
		'H' : 0,
		'N' : 1,
		'C0' : 1,
		'activ' : 0
	}
	#	--------------------------
	H       = 'H'
	N       = 'N'
	ELEMENT = DOT1D

class DOT1D__CHAINE__RESIDUELLE(RESIDUE):
	img = img_chaine_residue
	bg, fg = 'white', 'black'
	nom = "[DOT1D Chaine] Res"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"] # LSTM [X], [H]
	params = {
		'H' : 0,
		'N' : 0,
		'C0' : 1,
		'activ' : 0
	}
	#	--------------------------
	ELEMENT = DOT1D__CHAINE