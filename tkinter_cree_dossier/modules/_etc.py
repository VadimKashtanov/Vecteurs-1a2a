from tkinter_cree_dossier.tkinter_mdl import Module_Mdl 
from tkinter_cree_dossier.tkinter_dico_inst import Dico

from tkinter_cree_dossier.tkinter_modules_inst_liste import *

from tkinter_cree_dossier.tkinter_mdl_plus import *

img_chaine                = "tkinter_cree_dossier/modules_images/chaine.png"
img_residue               = "tkinter_cree_dossier/modules_images/residue.png"
img_chaine_residue        = "tkinter_cree_dossier/modules_images/chaine_residue.png"
img_residue_chaine        = "tkinter_cree_dossier/modules_images/residue_chaine.png"
img_chaine_residue_chaine = "tkinter_cree_dossier/modules_images/chaine_residue_chaine.png"

conn = lambda sortie,inst,entree: (sortie, (inst,entree))

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

#########################################################################################

class MATMUL2D(Module_Mdl):
	nom = "MATMUL2D A@P"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X0"], ["Y"] # LSTM [X], [H]
	params = {
		'Ax' : 0,
		'Ay' : 0,
		'Bx' : 0,
		'C0' : 1,
	}
	def cree_ix(self):
		#	Params
		Ax = self.params['Ax']
		Ay = self.params['Ay']
		Bx = self.params['Bx']
		C0 = self.params['C0']

		assert self.X[0] == Ax*Ay*C0
		assert self.Y[0] == Ay*Bx*C0

		#	------------------

		self.ix = [
			p  := Dico(i=i_Biais,               X=[],             x=[],       xt=[],       y=Ax*Bx*C0, p=[],            sortie=False),
			xp := Dico(i=i_Matmul2d_Sans_Poids, X=[Ax*Ay, Bx*Ax], x=[None,p], xt=[None,0], y=Ay*Bx*C0, p=[Ax,Ay,Bx,C0], sortie=True)
		]

		return self.ix

#########################################################################################

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

#########################################################################################

class SOFTMAX(Module_Mdl):
	bg, fg = 'yellow', 'black'
	nom = "Softmax"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Y"]
	params = {
		'C0' : 1
	}
	def cree_ix(self):
		#	Params
		X = self.X[0]
		Y = self.Y[0]

		C0 = self.params['C0']

		assert X==Y

		#	------------------

		self.ix = [
			_expx   := Dico(i=i_Activation,       X=[Y],   x=[None],        xt=[None], y=Y, p=[6], sortie=False),
			somme   := Dico(i=i_Somme,            X=[Y],   x=[_expx],       xt=[0],    y=C0, p=[C0],  sortie=False),
			softmax := Dico(i=i_Vect_Div_Unitair, X=[Y,C0], x=[_expx,somme], xt=[0,0],  y=Y, p=[C0],  sortie=True ),
		]

		return self.ix