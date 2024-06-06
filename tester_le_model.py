import time
import datetime

import requests

from os import system

ARONDIRE_AU_MODULO = lambda x,mod: (x + (mod - (x%mod)) if x%mod!=0 else x)

milliseconde = lambda la: int(la * 1000   )*1
seconde      = lambda la: int(la          )*1000
heure        = lambda la: int(la / (60*60))*1000*60*60

requette_bitget = lambda de, a, SYMBOLE: eval(
	requests.get(
		f"https://api.bitget.com/api/mix/v1/market/history-candles?symbol={SYMBOLE}_UMCBL&granularity=1H&startTime={de}&endTime={a}"
	).text
)

HEURES_PAR_REQUETTE = 100

T = (30)*24
N = 4#8
INTERVALLE_MAX = 128
DEPART = INTERVALLE_MAX * N

HEURES = DEPART + T
HEURES = ARONDIRE_AU_MODULO(HEURES, HEURES_PAR_REQUETTE)

la = heure(time.time())
heures_voulues = [
	la - 60*60*1000*i
	for i in range(ARONDIRE_AU_MODULO(HEURES, HEURES_PAR_REQUETTE))
][::-1]

donnees_BTCUSDT = []

REQUETTES = int(len(heures_voulues) / HEURES_PAR_REQUETTE)
print(f"Extraction de {len(heures_voulues)} heures depuis api.bitget.com ...")
for i in range(REQUETTES):
	paquet_heures_btc = requette_bitget(heures_voulues[i*HEURES_PAR_REQUETTE], heures_voulues[(i+1)*HEURES_PAR_REQUETTE-1], "BTCUSDT")
	donnees_BTCUSDT += paquet_heures_btc

	if i % 1 == 0:
		print(f"[{round(i*HEURES_PAR_REQUETTE/len(heures_voulues)*100)}%],   len(paquet_heures_btc)={len(paquet_heures_btc)}, (btc,)")

print(f"HEURES VOULUES = {len(heures_voulues)}, len(donnees_BTCUSDT)={len(donnees_BTCUSDT)}")

bitgetBTCUSDT = """https://www.CryptoDataDownload.com
Unix,Date,Symbol,Open,High,Low,Close,Volume,Volume Base Asset,tradecount
"""
for _,o,h,l,c,vB,vU in donnees_BTCUSDT[::-1]:
	bitgetBTCUSDT += f'0,0,bitgetBTCUSDT,{o},{h},{l},{c},{vU},{vB},0\n'

prixs = [float(c) for _,o,h,l,c,vB,vU in donnees_BTCUSDT]

print("- prixs:", prixs[-5:])

with open('prixs/bitgetBTCUSDT.csv', 'w') as co:
	co.write(bitgetBTCUSDT)

print("\033[92m[OK]\033[0m Etape 1: Ecriture CSV")

system("python3 prixs/ecrire_multi_sources.py prixs/bitgetBTCUSDT.csv")
print("\033[92m[OK]\033[0m Etape 2: Ecriture Multi Source")

system(f"python3 prixs/dar.py PRIXS={HEURES} prixs/tester_model_donnee.bin bitgetBTC")
print("\033[92m[OK]\033[0m Etape 3: dar.py")

system("rm les_predictions.bin")

system(f"./prog_tester_le_mdl")

import struct as st

with open("les_predictions.bin", 'rb') as co:
	bins = co.read()
	I = int( int(len(bins)/4) / 2)
	les_predictions = st.unpack('f'*I, bins[:4*I])
	les_delats      = st.unpack('f'*I, bins[4*I:])

deltas = [(prixs[i+1]/prixs[i] - 1) for i in range(len(prixs)-1)]

print(les_delats[-5:])
print(deltas    [-5:])

#breakpoint()

def normer(l):
	_min, _max = min(l), max(l)
	return [(e-_min)/(_max-_min) for e in l]

import matplotlib.pyplot as plt

a = normer(les_predictions)
b = normer(prixs[-len(les_predictions):-1])

plt.plot(a, 'x')
plt.plot(b     )
plt.show()

print(len(les_predictions))
print(len(prixs))

fig, ax = plt.subplots(2)

signe = [+1,-1]

for sng in [0,1]:
	for L in (10, 50, 100):
		u = 100
		_u0 = [u]
		for i in range(len(les_predictions)):
			p0 = (len(prixs)-1-len(les_predictions)) + i    
			p1 = (len(prixs)-1-len(les_predictions)) + i + 1
			u += u * L * les_predictions[i-1] * (prixs[p1]/prixs[p0]-1) * signe[sng]
			_u0 += [u]
			if u < 0: u = 0
		#
		ax[sng].plot(_u0, label=f'{signe[sng]}x{L}')
	#
#
plt.legend()
plt.show()

#	Faire correspondre les elements !!!!!