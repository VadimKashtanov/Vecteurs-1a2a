#! /usr/bin/python3

import tkinter as tk
import struct as st
from tkinter import messagebox
from tkinter import filedialog

from tkinter_cree_dossier.tkinter_modules_liste import modules
from tkinter_cree_dossier.tkinter_modules_inst_liste import modules_inst

from tkinter_cree_dossier.tkinter_insts import liste_insts

modules_models = modules_inst + modules

#   ==================== TK =========================

def rgb(r,g,b):
	return '#%02x%02x%02x' % (r,g,b)

class Entree(tk.Frame):
	def __init__(self, parent, A, val_ini, *args, **kwargs):
		tk.Frame.__init__(self, parent, *args, **kwargs)
		self.A = A
		self.l = tk.Label(self, text=A, bg='white')
		self.val = tk.StringVar()
		self.val.set(val_ini)
		self.e = tk.Entry(self, textvariable=self.val, width=8)
		#
		self.l.grid(row=0,column=0)
		self.e.grid(row=0,column=1)

class DraggableFrame(tk.Frame):
	def __init__(self, parent, x, y, module, numero, *args, **kwargs):
		tk.Frame.__init__(self, parent.canvas, *args, **kwargs)
		self.parent = parent
		self.bind("<Button-1>",  self.on_drag_start)
		self.bind("<B1-Motion>", self.on_drag_motion)
		self.place(x=x, y=y)
		#	---
		self.module = module
		#   ---
		self.numero = numero
		self.lbl = tk.Label(self, text=module.nom + f'  #{numero}', bg='white')
		self.lbl.grid(row=0, column=0, columnspan=3)
		#	---------
		tk.Button(self, text="X", fg='red', command=self.suppr_la_frame).grid(row=0, column=4)
		#   --- X ---
		#self.xs = [Entree(self, f'X{i}', x) for i,x in enumerate(module.X)]
		self.ps = [Entree(self, f'{nom}', p, bg='white') for i,(nom,p) in enumerate(module.params.items())]
		#self.ys = [Entree(self, f'Y{i}', y) for i,y in enumerate(module.Y)]

		self.xs = []
		for i,x in enumerate(module.X):
			self.xs += [Entree(self, f'X{i}', x, bg='white')]
			tk.Button(self, text='.', command=lambda _x=i:self.sel_B(_x)).grid (row=1+i, column=0)
			self.xs[-1].grid                                                   (row=1+i, column=1)
		#
		for i,p in enumerate(self.ps): p.grid                                  (row=1+i, column=2)
		#
		self.ys = []
		for i,y in enumerate(module.Y):
			self.ys += [Entree(self, f'Y{i}', y, bg='white')]
			self.ys[-1].grid                                                  (row=1+i, column=3)
			tk.Button(self, text='.', command=lambda _y=i:self.sel_A(_y)).grid(row=1+i, column=4)

	def mettre_a_jour_module(self):
		for x in range(len(self.xs)):
			self.module.X[x] = eval(self.xs[x].val.get())
			#print(self.module.__class__, self.module.X)
		for p in range(len(self.ps)):
			self.module.params[self.ps[p].A] = eval(self.ps[p].val.get())
		for y in range(len(self.ys)):
			self.module.Y[y] = eval(self.ys[y].val.get())

	def set_entree_depuis_valeurs_module(self):
		for x in range(len(self.xs)):
			self.xs[x].val.set(str(self.module.X[x]))
		for p in range(len(self.ps)):
			self.ps[p].val.set(str(self.module.params[self.ps[p].A]))
		for y in range(len(self.ys)):
			self.ys[y].val.set(str(self.module.Y[y]))

		self.lbl.config(text=self.module.nom + f'  #{self.numero}')

	def sel_A(self, _y):
		self.parent.instA.set  (str(self.numero))
		self.parent.sortieA.set(str(     _y    ))
	
	def sel_B(self, _x):
		self.parent.instB.set  (str(self.numero))
		self.parent.entréeB.set(str(     _x    ))

	def suppr_la_frame(self):
		self.parent.suppr_une_frame(self.numero)
	
	def on_drag_start(self, event):
		self._drag_start_x = event.x
		self._drag_start_y = event.y
	
	def on_drag_motion(self, event):
		delta_x = event.x - self._drag_start_x
		delta_y = event.y - self._drag_start_y
		new_x = self.winfo_x() + delta_x
		new_y = self.winfo_y() + delta_y
		#
		self.place(x=new_x, y=new_y)
		self.mettre_a_jour_module()
		self.parent.canvas.update_lines()  # Update lines through parent canvas

	def parametriser_le_module(self):
		self.mettre_a_jour_module()

class LineCanvas(tk.Canvas):
	def __init__(self, parent, *args, **kwargs):
		tk.Canvas.__init__(self, parent, *args, **kwargs)
		self.parent = parent
		self.lignes = []
		self.textes = []

		self.connections = [
			# (instA,sortieA), (instB,entreeB), t
		]

	def B_a_déjà_cette_entrée_assignée(self, A, B):
		for (iA,sA), (iB,eB), t in self.connections:
			if B[0] == iB:
				if eB == B[1]:
					return True
		return False

	def ajouter_connections(self, A, B, t):
		if t in (0, -1):
			if len(A) == len(B) == 2:
				if (A[0] in self.parent.numeros() and B[0] in self.parent.numeros()):
					if (A[1] < len(self.parent.trouver_frame(A[0]).ys) and B[1] < len(self.parent.trouver_frame(B[0]).xs)):
						if not (A,B) in self.connections:
							if not self.B_a_déjà_cette_entrée_assignée(A, B):
								self.connections += [[A,B,t]]
							else:
								messagebox.showwarning("Attention", f"{B[0]} a déjà son entrée {B[1]} assignée")
						else:
							messagebox.showwarning("Attention", f"La connection {A[0]}.{A[1]} -> {B[0]}.{B[1]} existe déjà")
					else:
						messagebox.showwarning("Attention", f"A ou B n'a pas d'entree ou de sortie {A[1]} ou {B[1]}")
				else:
					messagebox.showwarning("Attention", f"A:{A[0]} et/ou B:{B[0]} n'existe pas")
			else:
				messagebox.showwarning("Attention", f"La connection A={A} B={B} est invalide")
		else:
			messagebox.showwarning("Attention", f"t={t} est invalide. t doit etre dans (0,-1)")

		self.update_lines()
	
	def add_line(self, depart, fin, t):
		_moins_1 = (t == -1)
		ligne = self.create_line(depart[0], depart[1], fin[0], fin[1], width=2, arrow=tk.LAST, fill=('light grey' if _moins_1 else 'black'))
		texte = self.create_text(
			depart[0] + (fin[0]-depart[0])/2,
			depart[1] + (fin[1]-depart[1])/2,
			text = f'#{len(self.lignes)}' + ('[-1]' if t==-1 else ''),
			anchor="nw", fill=('light grey' if _moins_1 else 'black'))
		self.lignes += [ligne] #gc()
		self.textes += [texte] #gc()
	
	def update_lines(self):
		self.delete("all")
		#
		self.lignes      = []
		#
		for (instA, sortieA), (instB,entreeB),t in self.connections:
			frameA, frameB = self.parent.trouver_frame(instA), self.parent.trouver_frame(instB)
			"""Ax = frame1.winfo_rootx() + frame1.winfo_width () // 2 - self.winfo_rootx()
			Ay = frame1.winfo_rooty() + frame1.winfo_height() // 2 - self.winfo_rooty()
			Bx = frame2.winfo_rootx() + frame2.winfo_width () // 2 - self.winfo_rootx()
			By = frame2.winfo_rooty() + frame2.winfo_height() // 2 - self.winfo_rooty()"""
			#
			Xa = frameA.winfo_width ()
			Ya = frameA.winfo_height()
			Xb = frameB.winfo_width ()
			Yb = frameB.winfo_height()
			#
			Ax, Ay = frameA.winfo_x(), frameA.winfo_y()
			Bx, By = frameB.winfo_x(), frameB.winfo_y()
			#
			depart = [Ax+Xa, Ay+45+sortieA*30]
			fin    = [Bx,    By+45+entreeB*30]
			#
			#	Ajouter un léger décalage
			depart[0] += 10
			fin   [0] -= 10
			#
			self.add_line(depart, fin, t)

class DraggableApp(tk.Tk):
	def __init__(self, *args, **kwargs):
		tk.Tk.__init__(self, *args, **kwargs)
		self.geometry("1800x1120")

		self.frames = []
		self.canvas = LineCanvas(
			self,
			width=1460, height=1135,
			#width=1510, height=1135,
			scrollregion=(0, 0, 1900, 2000),
			bg=rgb(240,240,240),
		)

		self.canvas.grid(row=0, column=0)

		####################### Partie Bouttons ########################
		
		self.frame_boutons = tk.LabelFrame(self, text='Bouttons')
		self.frame_boutons.grid(row=0, column=1, sticky="nswe")

		#	----------------------
		ajout_module = tk.LabelFrame(self.frame_boutons, text='Ajouter Modules')
		modules_instruction = tk.Frame(ajout_module)
		for i_m in range(len(modules_inst)): #modules_models:
			m = modules_models[i_m]
			tk.Button(modules_instruction, text=f'{m.nom}', command=lambda _m=m:self.add_frame(_m())).grid(row=i_m//2, column=i_m%2, sticky='nsew')
		modules_instruction.pack(fill=tk.BOTH, expand=True)
		#
		#
		modules_normaux = tk.Frame(ajout_module)
		for i_m in range(len(modules_inst), len(modules_models)): #modules_models:
			m = modules_models[i_m]
			tk.Button(modules_normaux, text=f'{m.nom}', command=lambda _m=m:self.add_frame(_m())).grid(row=i_m//2, column=i_m%2, sticky='nsew')#.pack(fill=tk.X)
		modules_normaux.pack(fill=tk.BOTH, expand=True)

		ajout_module.pack(fill=tk.BOTH, expand=True)

		#	-------------------------

		self.prochain_numero_a_donner = 0

		#	-------------------------

		# Create a frame for arrow buttons
		self.fleches_frame = tk.LabelFrame(self.frame_boutons, text='Deplacement')
		self.fleches_frame.pack(fill=tk.Y, expand=True)

		# Load arrow images
		arrow_up_img    = tk.PhotoImage(file="tkinter_cree_dossier/arrow_up.png"   )
		arrow_down_img  = tk.PhotoImage(file="tkinter_cree_dossier/arrow_down.png" )
		arrow_left_img  = tk.PhotoImage(file="tkinter_cree_dossier/arrow_left.png" )
		arrow_right_img = tk.PhotoImage(file="tkinter_cree_dossier/arrow_right.png")

		# Create arrow buttons
		self.x, self.y = 0, 0
		move_up_btn    = tk.Button(self.fleches_frame, image=arrow_up_img,    command=self.move_objects_up   )
		move_up_btn.grid   (row=0, column=1)
		move_down_btn  = tk.Button(self.fleches_frame, image=arrow_down_img,  command=self.move_objects_down )
		move_down_btn.grid (row=1, column=1)
		move_left_btn  = tk.Button(self.fleches_frame, image=arrow_left_img,  command=self.move_objects_left )
		move_left_btn.grid (row=1, column=0)
		move_right_btn = tk.Button(self.fleches_frame, image=arrow_right_img, command=self.move_objects_right)
		move_right_btn.grid(row=1, column=2)

		# Keep reference to the images to prevent garbage collection
		self.arrow_images = [arrow_up_img, arrow_down_img, arrow_left_img, arrow_right_img]

		# Keep references to the buttons
		self.arrow_buttons = [move_up_btn, move_down_btn, move_left_btn, move_right_btn]

		#	---------- Ajout de Connections -----------
		conn_frame = tk.LabelFrame(self.frame_boutons, text='Connections')

		tk.Label(conn_frame, text='Inst ').grid(row=0, column=1)
		tk.Label(conn_frame, text='Point').grid(row=0, column=2)
		tk.Label(conn_frame, text='A'    ).grid(row=1, column=0)
		tk.Label(conn_frame, text='B'    ).grid(row=2, column=0)

		tk.Label(conn_frame, text='[t]').grid(row=0, column=3)

		self.instA = tk.StringVar(); self.sortieA = tk.StringVar();
		self.instB = tk.StringVar(); self.entréeB = tk.StringVar();
		self.instA.set('0');         self.sortieA.set('0');
		self.instB.set('0');         self.entréeB.set('0');
		self.e_instA   = tk.Entry(conn_frame, textvariable=self.instA,   width=8)
		self.e_instB   = tk.Entry(conn_frame, textvariable=self.instB,   width=8)
		self.e_sortieA = tk.Entry(conn_frame, textvariable=self.sortieA, width=8)
		self.e_entréeB = tk.Entry(conn_frame, textvariable=self.entréeB, width=8)
		self.e_instA.grid  (row=1,column=1)
		self.e_instB.grid  (row=2,column=1)
		self.e_sortieA.grid(row=1,column=2)
		self.e_entréeB.grid(row=2,column=2)

		self.t_A   = tk.StringVar(); self.t_A.set('0')
		self.e_t_A = tk.Entry(conn_frame, textvariable=self.t_A,   width=8) 
		self.e_t_A.grid(row=1, column=3)

		tk.Button(conn_frame, text="+", fg=rgb(0,128,0), command=self.ajouter_une_connection  ).grid(row=3, column=1)
		tk.Button(conn_frame, text="x", fg=rgb(255,0,0), command=self.supprimer_une_connection).grid(row=3, column=3)

		conn_frame.pack(fill=tk.BOTH, expand=True)

		#	-------------------- Ordre Connections --------------

		ordre_frame = tk.LabelFrame(self.frame_boutons, text='Modifier Ordre Insts')

		self.ordre_de = Entree(ordre_frame, '#', '0')
		self.ordre_a  = Entree(ordre_frame, '#', '0')

		self.ordre_de.grid(row=0,column=0)
		tk.Label(ordre_frame, text='<->').grid(row=0,column=1)
		self.ordre_a.grid(row=0,column=2)
		tk.Button(ordre_frame, text='Changer Ordre', command=self.changer_ordre).grid(row=1,column=0,columnspan=2)

		tk.Button(ordre_frame, text='Supprimer Toutes les Connections', command=self.supprimer_toutes_les_connections).grid(row=2,column=0,columnspan=3)

		ordre_frame.pack(fill=tk.BOTH, expand=True)

		#	-------------------- La Sortie Exacte -----------------------

		sortie_frame = tk.LabelFrame(self.frame_boutons, text='La Sortie Model')
		self.vraie_sortie = 0
		self.la_sortie = Entree(sortie_frame, 'Sortie du Modele : ', '0')
		self.la_sortie.grid(row=0, column=0, sticky='nsew')
		tk.Button(sortie_frame, text='Appliquer', command=self.mise_a_jour_sortie).grid(row=0, column=1, sticky='nsew')

		sortie_frame.pack(fill=tk.BOTH, expand=True)

		#	-------------- Fichier Enregistrer / Ouvire -----------------

		eo = tk.LabelFrame(self.frame_boutons, text='Sauvgarde & Ouverture')

		tk.Button(eo, text="Enregistrer", fg='blue',   command=self.sauvgarder).pack(fill=tk.BOTH, expand=True)
		tk.Button(eo, text="Ouvrire",     fg='yellow', command=self.ouvrire   ).pack(fill=tk.BOTH, expand=True)

		self.bind('<Control-s>', self.sauvgarder)
		self.bind('<Control-o>', self.ouvrire   )

		tk.Button(eo, text="Modules -> Mdl_t", command=self.modules_vers_mdl).pack(fill=tk.BOTH, expand=True)

		eo.pack(fill=tk.BOTH, expand=True)

		#	---- Rapide ----
		self.bind('+', self.ajouter_une_connection)
		self.bind('a', self.ajouter_une_connection)

		def change_focus(event):
			if (not type(event.widget) in [str]):
				event.widget.focus_set()

		self.bind_all('<Button>', change_focus)

	def supprimer_toutes_les_connections(self, *k):
		for i in range(len(self.canvas.connections)):
			del self.canvas.connections[0]

		self.canvas.update_lines()

	def suppr_une_frame(self, numero):
		f = self.trouver_frame(numero)
		f.pack_forget()
		f.destroy()
		del self.frames[self.frames.index(f)]
		#
		for c in range(len(self.canvas.connections)):
			(iA,sA), (iB, eB), t = self.canvas.connections[c]
			if iB==numero or iA==numero:
				self.canvas.connections[c] = None
		#
		self.canvas.connections = [c for c in self.canvas.connections if c != None]
		#
		self.canvas.update()
		self.canvas.update_lines()

	def update_frames(self):
		for f in self.frames:
			f.mettre_a_jour_module()
			f.set_entree_depuis_valeurs_module()

	def changer_ordre(self):
		de = eval(self.ordre_de.val.get())
		a  = eval(self.ordre_a.val.get())

		self.canvas.connections[de], self.canvas.connections[a] = self.canvas.connections[a], self.canvas.connections[de]

		self.canvas.update()
		self.canvas.update_lines()

	def ajouter_une_connection(self, *k):
		iA, sA = eval(self.instA.get()), eval(self.sortieA.get())
		iB, eB = eval(self.instB.get()), eval(self.entréeB.get())
		t = int(self.t_A.get())
		self.canvas.ajouter_connections((iA,sA), (iB, eB), t)

	def supprimer_une_connection(self):
		iA, sA = eval(self.instA.get()), eval(self.sortieA.get())
		iB, eB = eval(self.instB.get()), eval(self.entréeB.get())
		t = eval(self.t_A.get())
		if [(iA,sA), (iB,eB), t] in self.canvas.connections:
			del self.canvas.connections[self.canvas.connections.index([(iA,sA), (iB,eB),t])]
			self.canvas.update_lines()
		else:
			messagebox.showwarning('Attention', f"Il n'existe pas de connection iA={iA} sA={sA} iB={iB} eB={eB}")

	def trouver_frame(self, numero):
		for f in self.frames:
			if f.numero == numero:
				return f
		raise Exception(f"Pas trouvé le numéro {numero}")

	def numeros(self):
		return [f.numero for f in self.frames]

	def add_frame(self, module, x=0, y=0):
		frame = DraggableFrame(self, x, y, module, self.prochain_numero_a_donner, 
			width=100, height=135, bg=rgb(255,255,255))
		frame.pack_propagate(0)
		self.frames.append(frame)
		self.canvas.update_lines()
		#
		self.prochain_numero_a_donner += 1

	def mise_a_jour_sortie(self):
		self.vraie_sortie = eval(self.la_sortie.val.get())
		self.re_ordonner_frames()

	#	========================================================================

	def move_objects_up(self):
		self.y -= 1
		for frame in self.frames:
			frame.place_configure(y=frame.winfo_y() - -400)
		self.canvas.update()
		self.canvas.update_lines()

	def move_objects_down(self):
		self.y += 1
		for frame in self.frames:
			frame.place_configure(y=frame.winfo_y() + -400)
		self.canvas.update()
		self.canvas.update_lines()

	def move_objects_left(self):
		self.x -= 1
		for frame in self.frames:
			frame.place_configure(x=frame.winfo_x() - -400)
		self.canvas.update()
		self.canvas.update_lines()

	def move_objects_right(self):
		self.x += 1
		for frame in self.frames:
			frame.place_configure(x=frame.winfo_x() + -400)
		self.canvas.update()
		self.canvas.update_lines()

	# ========================================================================

	def re_ordonner_frames(self):
		self.update_frames()
		#
		frames_ordonnées = []
		for (iA,sA),(iB,eB),t in self.canvas.connections:
			if not self.trouver_frame(iA) in frames_ordonnées:
				frames_ordonnées += [self.trouver_frame(iA)]
		for (iA,sA),(iB,eB),t in self.canvas.connections:
			if not self.trouver_frame(iB) in frames_ordonnées:
				frames_ordonnées += [self.trouver_frame(iB)]
		if not self.trouver_frame(self.vraie_sortie) in frames_ordonnées:
			frames_ordonnées += [self.trouver_frame(self.vraie_sortie)]

		a_supprimer = []
		for f in self.frames:
			if not f in frames_ordonnées:
				a_supprimer += [f]
		for f in a_supprimer:
			f.suppr_la_frame()

		nouveaux = {
			self.frames[i].numero : frames_ordonnées.index(self.frames[i]) for i in range(len(self.frames))
		}

		for i,(ancien,nouveau) in enumerate(nouveaux.items()):
			self.frames[i].numero = nouveau

		for c in range(len(self.canvas.connections)):
			(iA,sA), (iB,eB), t = self.canvas.connections[c]
			for i,(ancien,nouveau) in enumerate(nouveaux.items()):
				if iA == ancien:
					iA = nouveau
					break

			for i,(ancien,nouveau) in enumerate(nouveaux.items()):
				if iB == ancien:
					iB = nouveau
					break

			self.canvas.connections[c] = [(iA,sA), (iB,eB), t]

		#	Re-ordonner la liste self.frames
		self.frames = [self.trouver_frame(i) for i in range(len(self.frames))]
		self.prochain_numero_a_donner = len(self.frames)

		#	--
		self.canvas.update()
		self.update_frames()
		self.canvas.update_lines()

	# ========================================================================

	def ouvrire(self, event=None):
		self.x, self.y = 0, 0
		#
		fichier = filedialog.askopenfilename(filetypes = (('module', '*.module'), ('Tous les fichier', '*.*')))
		#
		def st_lire(bins, taille):
			I = st.calcsize(taille)
			return list(st.unpack(taille, bytes(bins[:I]))), bins[I:]
		#
		with open(fichier, 'rb') as co:
			bins = list(co.read())
			#
			(L_f, L_c,), bins = st_lire(bins, 2*'I')
			#
			version = hash(''.join([m.nom for m in modules_models])) % 123456
			(version_fichier,), bins = st_lire(bins, 1*'I')
			if version != version_fichier:
				messagebox.showwarning("Attention", f"Les versions ne sont pas compatibles ({version} != {version_fichier})")
				#return
			#
			self.canvas.delete('all')
			self.prochain_numero_a_donner = 0
			for i in self.frames:
				i.pack_forget()
				i.destroy()
			for c in self.canvas.connections: del c
			self.frames             = []
			self.canvas.connections = []
			#
			for f in range(L_f):
				(ID,),bins = st_lire(bins, 1*'I')
				(x,y),bins = st_lire(bins, 2*'I')
				self.add_frame(modules_models[ID](), x=x, y=y)
				self.frames[-1].module.X, bins = st_lire(bins, len(self.frames[-1].module.X)*'I')
				self.frames[-1].module.Y, bins = st_lire(bins, len(self.frames[-1].module.Y)*'I')
				params, bins = st_lire(bins, len(self.frames[-1].module.params)*'I')
				for i,k in enumerate(self.frames[-1].module.params.keys()):
					self.frames[-1].module.params[k] = params[i]
				#
				self.frames[-1].set_entree_depuis_valeurs_module()
			#
			for c in range(L_c):
				(iA,sA, iB,eB, t), bins = st_lire(bins, 5*'I')
				self.canvas.connections += [[(iA,sA),(iB,eB),-t]]
		#	--
		self.canvas.update()
		self.canvas.update_lines()

	def sauvgarder(self, event=None):
		x, y = self.x, self.y
		for i in range(abs(x)):
			if x > 0 : self.move_objects_left ()
			else     : self.move_objects_right()
		for i in range(abs(y)):
			if y > 0 : self.move_objects_up ()
			else     : self.move_objects_down()
		self.x = 0
		self.y = 0
		#
		fichier = filedialog.asksaveasfilename(filetypes = (('module', '*.module'), ('Tous les fichier', '*.*')))
		#
		with open(fichier, 'wb') as co:
			co.write(st.pack('II', len(self.frames), len(self.canvas.connections)))
			#
			version = hash(''.join([m.nom for m in modules_models])) % 123456
			co.write(st.pack('I', version))
			#
			for f in self.frames:
				f.mettre_a_jour_module()
				try:
					co.write(st.pack('III', modules_models.index(type(f.module)), f.winfo_x(), f.winfo_y()))
				except:
					print("TraceBack")
					print("co.write(st.pack('III', modules_models.index(type(f.module)), f.winfo_x(), f.winfo_y()))")
					print("struct.error: argument out of range")
					print("Valeurs :", modules_models.index(type(f.module)), f.winfo_x(), f.winfo_y())
					return
				co.write(st.pack('I'*len(f.module.X), *f.module.X))
				co.write(st.pack('I'*len(f.module.Y), *f.module.Y))
				co.write(st.pack('I'*len(f.module.params), *list(f.module.params.values())))

			for (iA,sA),(iB,eB),t in self.canvas.connections:
				co.write(st.pack('IIIII', iA,sA,iB,eB,abs(t)))

	# =======================================================================

	def modules_vers_mdl(self):
		self.re_ordonner_frames()
		
		#	Etape 1 : Union & indéxation
		#	Assemblage de toutes les instructions dans un seul ix. Puis indexation des entrés non `None`
		ix = []
		depart_i = []
		depart = 0
		for f in self.frames:
			f.mettre_a_jour_module()
			m = f.module
			#
			try:
				m.cree_ix()
			except Exception as e:
				print(f"Erreur dans frame={f.numero}, module : {m}")
				raise e
			#
			for i in range(len(m.ix)):
				#print(m.ix[i])
				assert all(m.ix[i]['x'][j] in m.ix or m.ix[i]['x'][j] == None for j in range(len(m.ix[i]['x'])))
			#
			for _l in m.ix:
				#l = _l.copier()
				ix += [_l]
				#
				_l['x'] = [(depart+m.ix.index(x) if x!=None else None) for x in _l['x']]
				#print(_l['x'])
				#print(_l)
			#
			depart_i += [depart]
			depart += len(m.ix)

		#	Voyons la liste des sorties de chaque frame
		sorties = [i for i in range(len(ix)) if ix[i]['sortie']]
		
		#	Touts les `None` sont des entrés ou sorties
		#	Etape 2 : Connection des entrés et sorties possibles avec self.canvas.connections (x et xt)
		les_None = [(i,x) for i in range(len(ix)) for x in range(len(ix[i]['x'])) if ix[i]['x'][x] == None]
		#
		les_None_par_inst = [[] for i in range(len(self.frames))]
		for inst in range(len(self.frames)):
			for (i,x) in les_None:
				if i >= depart_i[inst]:
					les_None_par_inst[inst] += [(i,x)]
		#
		for (iA,sA),(iB,eB),t in self.canvas.connections:
			i, x = les_None_par_inst[iB][eB]
			sorties_A = [depart_i[iA]+j for j in range(len(self.frames[iA].module.ix)) if ix[depart_i[iA]+j]['sortie']][sA]
			ix[i]['x' ][x] = sorties_A#depart_i[iA] + [j for j in range(len(ix[i])) if ix[i]['sortie']][sA]
			ix[i]['xt'][x] = t

		#	Etape 3 : Identifier les None Restant comme entrées
		vraies_entrées = [(i,x) for i,l in enumerate(ix) for x,_x in enumerate(l['x']) if     _x == None]
		#les_x_non_none = [   x  for i,l in enumerate(ix) for x,_x in enumerate(l['x']) if not _x == None]
		#vraies_sorties = [ i    for i,l in enumerate(ix) if ix[i]['sortie'] and not i in les_x_non_none ]
		la_sortie = depart_i[self.vraie_sortie] + [i for i,__l in enumerate(self.frames[self.vraie_sortie].module.ix) if __l['sortie']][0]

		#	fichier.st.bin
		bins = b''
		bins += st.pack('I', len(ix))
		for pos,i in enumerate(ix):
			#	Verification
			inst = i['i'](i['X'], i['y'], i['p'])
			print(f'{pos}| {i}')
			inst.assert_coherance()
			if pos != 0:
				for j,_x in enumerate(i['x']):
					#print(len(ix), _x, ix[_x])
					#print(ix[_x]['y'], i['X'][j])
					assert ix[_x]['y'] == i['X'][j]
			#	ID
			bins += st.pack('I', liste_insts.index(inst.__class__))
			#	X
			for _x in range(len(i['x'])):
				est_une_entree = (i['x'][_x] == None)
				bins += st.pack('I', int(est_une_entree))
				#
				if not est_une_entree:
					X, x, xt = i['X'][_x], i['x'][_x], abs(i['xt'][_x])
				else:
					X, x, xt = i['y'], (1 << 32)-1, 0
				#
				bins += st.pack('III', X, x, xt)
			#	Y
			bins += st.pack('I', i['y'])
			#	Params
			bins += st.pack('I'*len(i['p']), *i['p'])
		#
		bins += st.pack('I', la_sortie)

		#	--- IO ---
		fichier = filedialog.asksaveasfilename(filetypes = (('pre_mdl', '*.st.bin'), ('Tous les fichier', '*.*')))
		with open(fichier, 'wb') as co:
			co.write(bins)

if __name__ == "__main__":
	DraggableApp().mainloop()