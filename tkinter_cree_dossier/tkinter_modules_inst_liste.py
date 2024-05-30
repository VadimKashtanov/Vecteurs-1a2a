from tkinter_cree_dossier.tkinter_mdl import Module_Mdl
from tkinter_cree_dossier.tkinter_dico_inst import Dico
#
from tkinter_cree_dossier.tkinter_insts import liste_insts
#
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

modules_inst = []

for i in liste_insts:
	nom_classe = i.__name__#nom_classe = str(i).split("'")[1].split('.')[1]
	s = f"""
class MODULE_{nom_classe}(Module_Mdl):	#	A+B
	nom = "inst:{i.nom}"
	X, Y = {list(i.X)}, [0]
	X_noms, Y_noms = {["X" for _ in i.X]}, ["Y"]
	params = {{
	"""
	for p in i.params_str:
		s += f"""
		'{p}' : 0,"""
	s += f"""
	}}
	def cree_ix(self):
		#	Params
		X = self.X
		Y = self.Y[0]
		params = [p for _,p in self.params.items()]

		#	------------------

		self.ix = [
			Dico(i={nom_classe}, X=X, x={[None for _ in i.X]}, xt={[None for _ in i.X]}, y=Y, p=params, sortie=True)
		]

	def module_vers_model(self):
		self.cree_ix()
		self.insts_et_connections(ix)

modules_inst += [MODULE_{nom_classe}]
"""
	exec(s)