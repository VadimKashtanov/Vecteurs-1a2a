class Dico:
	i = None
	#
	X  = []
	x  = []
	xt = []
	#
	y = 0
	#
	p = []
	#
	sortie = False
	# 
	def __init__(self, **karg):
		for k,v in karg.items():
			self[k] = v

	def __setitem__(self, k, v):
		if k in ('i', 'X', 'x', 'xt', 'y', 'p', 'sortie'):
			self.__setattr__(f'{k}', v)
		else:
			raise Exception(f"Argument {k} n'existe pas")

	def __getitem__(self, k):
		if k in ('i', 'X', 'x', 'xt', 'y', 'p', 'sortie'):
			return self.__getattribute__(f'{k}')

	def __str__(self):
		montrer = lambda obj: (obj if type(obj) == int else f'<id={id(obj)}>')
		return f'<id={id(self)}> i:{self.i}, X:{self.X}, x:{list(map(montrer,self.x))}, xt:{self.xt}, y:{self.y}, p:{self.p}, sortie:{self.sortie}'


	def copier(self):
		return Dico(
			i=self.i,
			X=self.X,
			x=self.x,
			xt=self.xt,
			y=self.y,
			p=self.p,
			sortie=self.sortie
		)