#valgrind --track-origins=yes --leak-check=full --show-leak-kinds=all ./main
#cuda-gdb
#compute-sanitizer --tool memcheck
rm *.o
clear
printf "[\033[93m***\033[0m] \033[103mCompilation ...\033[0m \n"

#echo "!!! -G -g !!!";A="-Idef -Idef/insts -diag-suppress 2464 -G -g -O0 -lm -lcublas_static -lcublasLt_static -lculibos -Xcompiler -fopenmp -Xcompiler -O0"
#echo "!!! -g !!!";A="-Idef -Idef/insts -diag-suppress 2464 -g -O0 -lm -lcublas_static -lcublasLt_static -lculibos -Xcompiler -fopenmp -Xcompiler -O3"
A="-Idef -Idef/insts -diag-suppress 2464 -O3 -lm -lcublas_static -lcublasLt_static -lculibos -Xcompiler -fopenmp -Xcompiler -O3"

# les 3 lignes au dessus : debbug cuda, debbug, optimiser

################################################################

#	/insts
nvcc -c impl/insts/insts.cu         ${A} &
nvcc -c impl/insts/inst_controle.cu ${A} &
#	/insts/_entree
nvcc -c impl/insts/_entree/_entree.cu ${A} &
nvcc -c impl/insts/_entree/_entree_f.cu ${A} &
nvcc -c impl/insts/_entree/_entree_df.cu ${A} &
#	/insts/activation
nvcc -c impl/insts/activation/activation.cu ${A} &
nvcc -c impl/insts/activation/activation_f.cu ${A} &
nvcc -c impl/insts/activation/activation_df.cu ${A} &
#	/insts/biais
nvcc -c impl/insts/biais/biais.cu ${A} &
nvcc -c impl/insts/biais/biais_f.cu ${A} &
nvcc -c impl/insts/biais/biais_df.cu ${A} &
#	/insts/const
nvcc -c impl/insts/const/const.cu ${A} &
nvcc -c impl/insts/const/const_f.cu ${A} &
nvcc -c impl/insts/const/const_df.cu ${A} &
#	/insts/dot1d_X
nvcc -c impl/insts/dot1d_X/dot1d_X.cu ${A} &
nvcc -c impl/insts/dot1d_X/dot1d_X_f.cu ${A} &
nvcc -c impl/insts/dot1d_X/dot1d_X_df.cu ${A} &
#	/insts/dot1d_XY
nvcc -c impl/insts/dot1d_XY/dot1d_XY.cu ${A} &
nvcc -c impl/insts/dot1d_XY/dot1d_XY_f.cu ${A} &
nvcc -c impl/insts/dot1d_XY/dot1d_XY_df.cu ${A} &
#	/insts/kconvl1d
nvcc -c impl/insts/kconvl1d/kconvl1d.cu ${A} &
nvcc -c impl/insts/kconvl1d/kconvl1d_f.cu ${A} &
nvcc -c impl/insts/kconvl1d/kconvl1d_df.cu ${A} &
#	/insts/kconvl1d_stricte
nvcc -c impl/insts/kconvl1d_stricte/kconvl1d_stricte.cu ${A} &
nvcc -c impl/insts/kconvl1d_stricte/kconvl1d_stricte_f.cu ${A} &
nvcc -c impl/insts/kconvl1d_stricte/kconvl1d_stricte_df.cu ${A} &
#	/insts/kconvl2d_stricte
nvcc -c impl/insts/kconvl2d_stricte/kconvl2d_stricte.cu ${A} &
nvcc -c impl/insts/kconvl2d_stricte/kconvl2d_stricte_f.cu ${A} &
nvcc -c impl/insts/kconvl2d_stricte/kconvl2d_stricte_df.cu ${A} &
###
wait
#	/insts/matmul1d
nvcc -c impl/insts/matmul1d/matmul1d.cu ${A} &
nvcc -c impl/insts/matmul1d/matmul1d_f.cu ${A} &
nvcc -c impl/insts/matmul1d/matmul1d_df.cu ${A} &
#	/insts/matmul1d_canal
nvcc -c impl/insts/matmul1d_canal/matmul1d_canal.cu ${A} &
nvcc -c impl/insts/matmul1d_canal/matmul1d_canal_f.cu ${A} &
nvcc -c impl/insts/matmul1d_canal/matmul1d_canal_df.cu ${A} &
#	/insts/mul2
nvcc -c impl/insts/mul2/mul2.cu ${A} &
nvcc -c impl/insts/mul2/mul2_f.cu ${A} &
nvcc -c impl/insts/mul2/mul2_df.cu ${A} &
#	/insts/mul3
nvcc -c impl/insts/mul3/mul3.cu ${A} &
nvcc -c impl/insts/mul3/mul3_f.cu ${A} &
nvcc -c impl/insts/mul3/mul3_df.cu ${A} &
#	/insts/pool2_1d
nvcc -c impl/insts/pool2_1d/pool2_1d.cu ${A} &
nvcc -c impl/insts/pool2_1d/pool2_1d_f.cu ${A} &
nvcc -c impl/insts/pool2_1d/pool2_1d_df.cu ${A} &
#	/insts/pool2x2
nvcc -c impl/insts/pool2x2_2d/pool2x2_2d.cu ${A} &
nvcc -c impl/insts/pool2x2_2d/pool2x2_2d_f.cu ${A} &
nvcc -c impl/insts/pool2x2_2d/pool2x2_2d_df.cu ${A} &
#	/insts/softmax
nvcc -c impl/insts/softmax/softmax.cu ${A} &
nvcc -c impl/insts/softmax/softmax_f.cu ${A} &
nvcc -c impl/insts/softmax/softmax_df.cu ${A} &
###
wait
#	/insts/somme2
nvcc -c impl/insts/somme2/somme2.cu ${A} &
nvcc -c impl/insts/somme2/somme2_f.cu ${A} &
nvcc -c impl/insts/somme2/somme2_df.cu ${A} &
#	/insts/somme3
nvcc -c impl/insts/somme3/somme3.cu ${A} &
nvcc -c impl/insts/somme3/somme3_f.cu ${A} &
nvcc -c impl/insts/somme3/somme3_df.cu ${A} &
#	/insts/somme4
nvcc -c impl/insts/somme4/somme4.cu ${A} &
nvcc -c impl/insts/somme4/somme4_f.cu ${A} &
nvcc -c impl/insts/somme4/somme4_df.cu ${A} &
#	/insts/sub2
nvcc -c impl/insts/sub2/sub2.cu ${A} &
nvcc -c impl/insts/sub2/sub2_f.cu ${A} &
nvcc -c impl/insts/sub2/sub2_df.cu ${A} &
#	/insts/Y
nvcc -c impl/insts/Y/Y.cu ${A} &
nvcc -c impl/insts/Y/Y_f.cu ${A} &
nvcc -c impl/insts/Y/Y_df.cu ${A} &
#	/insts/Y
nvcc -c impl/insts/Y_canalisation/Y_canalisation.cu ${A} &
nvcc -c impl/insts/Y_canalisation/Y_canalisation_f.cu ${A} &
nvcc -c impl/insts/Y_canalisation/Y_canalisation_df.cu ${A} &
#	/insts/Y_union_2
nvcc -c impl/insts/Y_union_2/Y_union_2.cu ${A} &
nvcc -c impl/insts/Y_union_2/Y_union_2_f.cu ${A} &
nvcc -c impl/insts/Y_union_2/Y_union_2_df.cu ${A} &
###########
#	/etc
nvcc -c impl/etc/etc.cu     ${A} &
#	/etc/btcusdt
nvcc -c impl/btcusdt/btcusdt.cu          ${A} &
nvcc -c impl/btcusdt/btcusdt_f.cu        ${A} &
nvcc -c impl/btcusdt/btcusdt_df.cu       ${A} &
nvcc -c impl/btcusdt/btcusdt_pourcent.cu ${A} &
#	/main
nvcc -c impl/main/verif_1e5.cu    ${A} &
nvcc -c impl/main/structure.cu    ${A} &
#	/mdl
nvcc -c impl/mdl/mdl.cu ${A} &
nvcc -c impl/mdl/mdl_optimisation.cu    ${A} &
nvcc -c impl/mdl/mdl_ctrl.cu            ${A} &
nvcc -c impl/mdl/mdl_f.cu  ${A} &
nvcc -c impl/mdl/mdl_df.cu ${A} &
nvcc -c impl/mdl/mdl_S.cu            ${A} &
nvcc -c impl/mdl/mdl_allez_retour.cu ${A} &
nvcc -c impl/mdl/mdl_pourcent.cu ${A} &
nvcc -c impl/mdl/mdl_tester_le_model.cu ${A} &
nvcc -c impl/mdl/mdl_plume.cu           ${A} &
#	/opti
nvcc -c impl/opti/opti_adam.cu ${A} &
nvcc -c impl/opti/opti_opti.cu ${A} &
#
#	Attente de terminaison des differents fils de compilation
#
wait

################################################################

#	Programme : "principale"
nvcc     -c impl/main.cu ${A}
nvcc *.o -o      main    ${A}
rm main.o
#	Programme : "tester le model"
nvcc     -c impl/prog_tester_le_mdl.cu ${A}
nvcc *.o -o      prog_tester_le_mdl    ${A}
rm prog_tester_le_mdl.o
#
#	Attente de terminaison des differents fils de compilation
#
wait

################################################################

#	Verification d'erreure
if [ $? -eq 1 ]
then
	printf "\n[\033[91m***\033[0m] \033[101m [!] Erreure. Pas d'execution. [!]\033[0m\n"
	exit
else
	printf "[\033[92m***\033[0m] \033[102m========= Execution du programme =========\033[0m\n"
fi

#	Executer si Aucune erreur
time ./main
if [ $? -ne 0 ]
then
	printf "[\033[91m***\033[0m] \033[101m /!\ Erreur durant l'execution. /!\ \033[0m\n"
	exit
else
	printf "[\033[92m***\033[0m] \033[102mAucune erreure durant l'execution.\033[0m\n"
fi

rm *.o