class Module_Mdl:
	def __init__(self, X=None, Y=None, params=None):
		if X != None:
			assert len(X) == len(self.X)
			self.X = X
		if Y != None:
			assert len(Y) == len(self.Y)
			self.Y = Y
		if params != None:
			assert len(list(params.keys())) == len(list(self.params.keys()))
			self.params = params