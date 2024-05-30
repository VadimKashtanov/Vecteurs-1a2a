#! /usr/bin/python3

import struct as st
from random import shuffle

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

LIGNES = 256 #une ligne = une analyse du marché
N      = 8
P      = 1#3

INTERVALLE_MAX = 128 #256

PRIXS  = 37865
DEPART = INTERVALLE_MAX * N

sources_nom = ['prixs', 'low', 'high', 'median', 'volumes', 'volumes_A', 'volumes_U', 'tradecount']
sources     = {
	marchee : {
		nom_extraction  : lire(f'{marchee}USDT/{nom_extraction}.bin')
		for nom_extraction in [
			'prixs',
			'low', 'high', 'median',
			'volumes', 'volumes_A', 'volumes_U',
			'tradecount']
		}
	for marchee in ["BTC", "ETH"]
}
assert all(len(v)==PRIXS for m,ex in sources.items() for k,v in ex.items())

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

from outils import ema, direct, macd

heures = 1, 2, 5, 12, 48, 168

DIRECT = [
	{'ligne' : direct(ema(sources[m][ex], K=i)), 'interv':i*j, 'type_de_norme':norme}
	for m in ('BTC',)
		for ex in ('prixs', 'low', 'high', 'volumes', 'volumes_A', 'volumes_U',)
			for i in heures
				for j in (1/2, 1, 2)
					if 1 <= (i*j) < INTERVALLE_MAX
]

MACD = [
	{'ligne' : macd(ema(sources[m][ex], K=i), e=i*j*k), 'interv':i*j, 'type_de_norme':norme_relative}
	for m in ('BTC',)
		for ex in ('prixs',)
			for i in heures
				for j in (1/2, 1, 2)
					for k in (1/8, 1/4, 1/2)
						if 1 <= (i*j) < INTERVALLE_MAX
]

CHIFFRE_HAUT = []	#Norme Theorique [ 0;+1]
CHIFFRE_BAS  = []	#Norme Theorique [ 0;+1]
CHIFFRE      = []	#Norme Theorique [-1;+1]

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

T = PRIXS - DEPART - P

lignes = []

TRANSFORMATIONS = (DIRECT+MACD)

shuffle(TRANSFORMATIONS)

for l in TRANSFORMATIONS[:128]:
	assert len(l['ligne']) >= T
	lignes += [l]

LIGNES = len(lignes)

print(f"LIGNES = {LIGNES}")
print(f"T = {T}")
print(f"N = {N}")
print(f"P = {P}")

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

prixs = sources['BTC']['prixs']

with open("dar.bin", "wb") as co:
	co.write(st.pack('I', T))
	co.write(st.pack('I'*3, LIGNES, N, P))

	entrees = []
	sorties = []

	for t in range(DEPART, PRIXS - P):
		for l in lignes:
			entrees += l['type_de_norme']([ l['ligne'][t - n*int(l['interv'])] for n in range(N)])
		sorties += [(prixs[t+p+1]/prixs[t+p]-1) for p in range(P)]

	co.write(st.pack('f'*len(entrees), *entrees))
	co.write(st.pack('f'*len(sorties), *sorties))