from tkinter_cree_dossier.modules._etc import *

class ATTENTION(Module_Mdl):	#	f(ax0+bx1+cx2+d)
	bg, fg = 'white', 'black'
	nom = "[ATTENTION] Y=Xn"
	X, Y = [0], [0]
	X_noms, Y_noms = ["X"], ["Z"]
	params = {
		'X.n' : 0,
		'X.d' : 0,
		#
		'QKV.d' : 0,
		#
		'C0' : 1,
		'C1' : 1,
	}
	def cree_ix(self):
		#	Params
		Xn = self.params['X.n']
		Xd = self.params['X.d']
		#
		QKVd = self.params['QKV.d']
		#
		C0 = self.params['C0']
		C1 = self.params['C1']

		X = self.X[0]
		Y = self.Y[0]

		assert X == Xn*Xd*C0

		Kd = Qd = Vd = QKVd

		#	------------------

		self.elements = {
			'x' : MODULE_i_Candrans_Pondérés(X=[Xn*Xd*C0], Y=[Xn*Xd*C1], params={'Cx':Xn*Xd, 'C0':C0, 'C1':C1}).cree_ix(),
			#
			'Q' : MATMUL2D(X=[Xn*Xd*C1], Y=[Xn*Qd*C1], params={'Ax':Xd,'Ay':Xn,'Bx':Qd,'C0':C1}).cree_ix(),
			'K' : MATMUL2D(X=[Xn*Xd*C1], Y=[Xn*Kd*C1], params={'Ax':Xd,'Ay':Xn,'Bx':Kd,'C0':C1}).cree_ix(),
			'V' : MATMUL2D(X=[Xn*Xd*C1], Y=[Xn*Vd*C1], params={'Ax':Xd,'Ay':Xn,'Bx':Vd,'C0':C1}).cree_ix(),
			#
			'K.t' : MODULE_i_Transpose2D(Y=[Xn*Kd*C1], params={'Ax':Kd, 'Ay':Xn, 'C0':C1}).cree_ix(),
			#
			'K.t@Q'   : MODULE_i_Matmul2d_Sans_Poids(X=[Xn*Kd*C1, Xn*Qd*C1], Y=[Xn*Xn*C1], params={'Ax':Kd, 'Ay':Xn, 'Bx':Xn, 'C0':C1}).cree_ix(),
			'softmax' : SOFTMAX(X=[Xn*Xn*C1], Y=[Xn*Xn*C1], params={'C0':C1}).cree_ix(),
			#
			'softmax(K.t@Q) @ V' : MODULE_i_Matmul2d_Sans_Poids(X=[Xn*Kd*C1, Vd*Xn*C1], Y=[Vd*Xn*C1], params={'Ax':Xn, 'Ay':Xn, 'Bx':Vd, 'C0':C1}).cree_ix(),
		}

		#	======================

		self.connections = {
			'x' : {
				0 : None,
			},
			#
			'Q' : {0 : ('x', 0)},
			'K' : {0 : ('x', 0)},
			'V' : {0 : ('x', 0)},
			#
			'K.t' : {0 : ('K', 0)},
			#
			'K.t@Q' : {
				0 : ('K.t', 0),
				1 : ('Q'  , 0)
			},
			#
			'softmax' : {0 : ('K.t@Q', 0)},
			#
			'softmax(K.t@Q) @ V' : {
				0 : ('softmax', 0),
				1 : ('V'      , 0)
			}
		}

		self.cree_elements_connections()
		return self.ix

class ATTENTION_MASQUE_PASSAGE(Module_Mdl):
	pass

class Transformeur(Module_Mdl): #Ou pas, peut etre pas utile
	pass