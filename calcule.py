from os import system
import struct as st

def calcule(donnees, NOM, MEGA_T):
	prixs = [float(c) for _,o,h,l,c,vB,vU in donnees]

	system(f"python3 prixs/ecrire_multi_sources.py prixs/{NOM}USDT.csv")

	system(f"python3 prixs/dar.py PRIXS={len(prixs)} prixs/tester_model_donnee.bin bitgetBTC")

	system("rm les_predictions.bin")

	####################################################################################

	system(f"./prog_tester_le_mdl")

	with open("structure_generale.bin", 'rb') as co:
		bins = co.read()
		(I,) = st.unpack('I', bins[:4])
		elements = st.unpack('I', bins[4:])
		#
		MEGA_T, = elements

	with open("les_predictions.bin", 'rb') as co:
		bins = co.read()
		I = int( int(len(bins)/4) / 3)
		les_Amplitudes  = st.unpack('f'*I, bins[0*4*I:1*4*I])
		les_predictions = st.unpack('f'*I, bins[1*4*I:2*4*I])
		les_delats      = st.unpack('f'*I, bins[2*4*I:3*4*I])

	return les_Amplitudes, les_predictions, les_delats