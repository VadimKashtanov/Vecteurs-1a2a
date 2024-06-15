#! /usr/bin/python3

import struct as st
from random import shuffle

OK = lambda s: print(f"[OK] {s}")

def lire(fichier):
	with open(fichier, 'rb') as co:
		bins = co.read()
		(L,) = st.unpack('I', bins[:4])
		return st.unpack('f'*L, bins[4:])

def norme(l):
	_min, _max = min(l), max(l)
	return [(e-_min)/(_max - _min) for e in l]

def norme_théorique(l, _min, _max):
	return [(e-_min)/(_max - _min) for e in l]

def norme_relative(l):
	__max = max([abs(min(l)), abs(max(l))])
	_min, _max = -__max, +__max
	return [(e-_min)/(_max - _min) for e in l]

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#python3 prixs/dar.py PRIXS={HEURES} prixs/tester_model_donnee.bin BTC, ETH, ...

N      = 8
P      = 1#3 #1#3

INTERVALLE_MAX = 256

PRIXS  = 37865
DEPART = INTERVALLE_MAX * N

from sys import argv
assert len(argv) > (1 + 2)
PRIXS       = int(argv[1].split('=')[1])
fichier_bin = argv[2]
MARCHEES    = argv[3:]
assert PRIXS > DEPART
assert any('BTC' in marchee for marchee in MARCHEES)

sources_nom = ['prixs', 'low', 'high', 'median', 'volumes', 'volumes_A', 'volumes_U']
sources     = {
	marchee : {
		nom_extraction  : lire(f'prixs/{marchee}USDT/{nom_extraction}.bin')
		for nom_extraction in [
			'prixs',
			'low', 'high', 'median',
			'volumes', 'volumes_A', 'volumes_U']
		}
	for marchee in MARCHEES#["BTC", "ETH"]
}
print(PRIXS, [len(v) for m,ex in sources.items() for k,v in ex.items()])
assert all(len(v)==PRIXS for m,ex in sources.items() for k,v in ex.items())

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

from outils import ema, direct, macd, chiffre

heures = 1, 2, 5, 12, 48, 168

DIRECT = [
	{
		'ligne' : direct(ema(sources[m][ex], K=i)),
		'interv': i*j,
		'type_de_norme':norme
	}
	for m in MARCHEES
		for ex in ('prixs', 'low', 'high', 'volumes', 'volumes_A', 'volumes_U',)
			for i in heures
				for j in (1,)#(1/2, 1, 2)
					if 1 <= (i*j) < INTERVALLE_MAX
]
OK("DIRECTE")

MACD = [
	{
		'ligne' : macd(ema(sources[m][ex], K=i), e=i*j*k),
		'interv': i*j,
		'type_de_norme':norme_relative
	}
	for m in MARCHEES
		for ex in ('prixs',)
			for i in heures
				for j in (1,)#(1/2, 1, 2)
					for k in (1/8, 1/2)#(1/8, 1/4, 1/2)
						if 1 <= (i*j) < INTERVALLE_MAX
]
OK("MACD")

CHIFFRE = [
	{
		'ligne' : chiffre(ema(sources[m][ex], K=i), __chiffre=k),
		'interv': i*j,
		'type_de_norme': lambda *a: norme_théorique(*a, _min=0, _max=1.0)
	}
	for m in MARCHEES
		for ex in ('prixs',)
			for i in heures
				for j in (1,)#:(1/2, 1, 2)
					for k in (1000, 10000)
						if 1 <= (i*j) < INTERVALLE_MAX
]
OK("CHIFFRE")

#eventuellement, chiffre haut / bas, norme [0;+1], [-1;0] (car on prefere des signaux a de la géométrie)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

T = PRIXS - DEPART - P

lignes = []

TRANSFORMATIONS = (DIRECT+MACD+CHIFFRE)

#shuffle(TRANSFORMATIONS)

for l in TRANSFORMATIONS:#[:128]:
	assert len(l['ligne']) >= T
	lignes += [l]
LIGNES = len(lignes)

print(f"LIGNES = {LIGNES}")
print(f"T = {T}")
print(f"N = {N}")
print(f"P = {P}")

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

def _11_vers_01(l):
	assert all(0 <= i <= +1 for i in l)
	return l #car deja dans [0;+1]

	#[(i+1)/2 for i in l] #[-1;+1] -> [0;+1]

prixs = sources[MARCHEES[0]]['prixs']

print("prixs : ", prixs[-5:])

with open(fichier_bin, "wb") as co:
	co.write(st.pack('I', T))
	co.write(st.pack('I'*3, LIGNES, N, P))

	entrees = []
	sorties = []

	for t in range(DEPART, PRIXS - P):
		for l in lignes:
			entrees += _11_vers_01(l['type_de_norme']([ l['ligne'][t - n*int(l['interv'])] for n in range(N)]))
		sorties += [(prixs[t+p+1]/prixs[t+p]-1) for p in range(P)]

	co.write(st.pack('f'*len(entrees), *entrees))
	co.write(st.pack('f'*len(sorties), *sorties))