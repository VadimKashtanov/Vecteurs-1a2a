import struct as st
import matplotlib.pyplot as plt

ETAPE = lambda I, intitulé: print(f"\033[92m[OK]\033[0m Etape {I}: {intitulé}")

def normer(l):
	_min, _max = min(l), max(l)
	return [(e-_min)/(_max-_min) for e in l]

def normer_11(l):
	_min, _max = min(l), max(l)
	return [2*(e-_min)/(_max-_min)-1 for e in l]

####################################################################################

d = "1H"# "15m"

T = (4)*7*24 # * 4

P = 1

N = 8
INTERVALLE_MAX = 256
DEPART = INTERVALLE_MAX * N

HEURES = DEPART + T + P

from bitget_donnee import DONNEES_BITGET, faire_un_csv

donnees = DONNEES_BITGET(HEURES, d)
csv = faire_un_csv(donnees, NOM="bitgetBTCUSDT")

print(f"Len donnees = {len(donnees)}")

with open('prixs/bitgetBTCUSDT.csv', 'w') as co:
	co.write(csv)

ETAPE(1, "Ecriture CSV")

####################################################################################

with open("structure_generale.bin", 'rb') as co:
	bins = co.read()
	(I,) = st.unpack('I', bins[:4])
	elements = st.unpack('I', bins[4:])
	#
	MEGA_T, = elements

from calcule import calcule

les_Amplitudes, les_predictions, les_delats = calcule(donnees, "bitgetBTC", MEGA_T)

les_Amplitudes  = [(i+1)/2 for i in les_Amplitudes] #[-1;+1] ->  [0;1]
les_predictions = les_predictions                   #[-1;+1]
les_delats      = les_delats                        #[-inf;+inf]

####################################################################################

prixs = [float(c) for _,o,h,l,c,vB,vU in donnees]

print("les_Amplitudes ", les_Amplitudes [-7:])
print("les_predictions", les_predictions[-7:])
print("les_delats     ", les_delats     [-7:])

deltas = [(prixs[i+1]/prixs[i] - 1) for i in range(len(prixs)-1)]

print("les delats", les_delats[-5:])
print("deltas    ", deltas    [-5:])

print(f"moyenne des differences des deltas : {sum([abs(a-b) for a,b in zip(deltas, les_delats)])/len(deltas)}")

####################################################################################

a =          (les_Amplitudes )
b =          (les_predictions)
c = normer_11(prixs[-len(les_predictions)-1:-1])

for i in range(int(len(les_predictions)/MEGA_T)):
	plt.plot([len(les_predictions) - i*MEGA_T]*2, [-1, 1])

	if i == 0:
		plt.plot(list(range(i*MEGA_T, (i+1)*MEGA_T)), a[i*MEGA_T:(i+1)*MEGA_T], 'm-o', label='o = Amplitude')
		plt.plot(list(range(i*MEGA_T, (i+1)*MEGA_T)), b[i*MEGA_T:(i+1)*MEGA_T], 'y-x', label='x = prediction')
	else:
		plt.plot(list(range(i*MEGA_T, (i+1)*MEGA_T)), a[i*MEGA_T:(i+1)*MEGA_T], 'm-o')
		plt.plot(list(range(i*MEGA_T, (i+1)*MEGA_T)), b[i*MEGA_T:(i+1)*MEGA_T], 'y-x')
	#
	for j in range(MEGA_T):
		if b[i*MEGA_T+j] >= 0.0:
			plt.plot([i*MEGA_T+j, i*MEGA_T+j], [c[i*MEGA_T+j], c[i*MEGA_T+j] + 0.03], 'g')
		else:
			plt.plot([i*MEGA_T+j, i*MEGA_T+j], [c[i*MEGA_T+j], c[i*MEGA_T+j] - 0.03], 'r')

plt.plot(c     , 'c-^', label='prix')
plt.legend()
plt.show()

####################################################################################

print("len(les_predictions)", len(les_predictions))
print("len(prixs)          ", len(prixs))

fig, ax = plt.subplots(3,2)

__sng = lambda x: (1 if x > 0 else -1)

signe = [+1,-1]

LEVIERS = [10, 20, 30, 50]

for sng in [0,1]:
	for L in LEVIERS:
		u = 100
		_u0 = [u]
		for i in range(len(les_predictions)):
			p0 = (len(prixs)-1-len(les_predictions)) + i    
			p1 = (len(prixs)-1-len(les_predictions)) + i + 1
			u += u * L * __sng(les_predictions[i]) * (prixs[p1]/prixs[p0]-1) * signe[sng]
			_u0 += [u]
			if u < 0: u = 0
		#
		ax[0][sng].plot(_u0, label=f'{signe[sng]}x{L} * sng()')
		ax[0][sng].legend()
#
for sng in [0,1]:
	for L in LEVIERS:
		u = 100
		_u0 = [u]
		for i in range(len(les_predictions)):
			p0 = (len(prixs)-1-len(les_predictions)) + i    
			p1 = (len(prixs)-1-len(les_predictions)) + i + 1
			u += u * L * les_predictions[i] * (prixs[p1]/prixs[p0]-1) * signe[sng]
			_u0 += [u]
			if u < 0: u = 0
		#
		ax[1][sng].plot(_u0, label=f'{signe[sng]}x{L}')
		ax[1][sng].legend()
	#
for sng in [0,1]:
	for L in LEVIERS:
		u = 100
		_u0 = [u]
		for i in range(len(les_predictions)):
			p0 = (len(prixs)-1-len(les_predictions)) + i    
			p1 = (len(prixs)-1-len(les_predictions)) + i + 1
			u += u * L * __sng(les_predictions[i]) * abs(les_Amplitudes[i]) * (prixs[p1]/prixs[p0]-1) * signe[sng]
			_u0 += [u]
			if u < 0: u = 0
		#
		ax[2][sng].plot(_u0, label=f'{signe[sng]}x{L} (Amplitude)')
		ax[2][sng].legend()
	#
#
plt.legend()
plt.show()