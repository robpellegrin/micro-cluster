#!/bin/bash

mkdir -p ./test_results/

matrix_sizes=("2000")
block_sizes=("8" "16" "32" "64" "128" "256")
num_processes=("16" "32" "64")
bcasts=("1" "2" "3" "4", "5")
pfacts=("0" "1" "2")
rfacts=("0" "1" "2")
swap=("0" "1" "2")
l1=("0" "1")
u=("0" "1")
e=("0" "1")


for N in "${matrix_sizes[@]}"; do
  for NB in "${block_sizes[@]}"; do
    for BCAST in "${bcasts[@]}"; do
    for PFACT in "${pfacts[@]}"; do
    for RFACT in "${rfacts[@]}"; do
    for SWAP in "${swap[@]}"; do
    for L1 in "${l1[@]}"; do
    for U in "${u[@]}"; do
    for E in "${e[@]}"; do
      echo "Running benchmark with N=$N, NB=$NB BCAST=$BCAST PFACT=$PFACT"
      echo "RFACT=$RFACT"

      # Copy the original HPL.dat template
      cp HPL.dat.template HPL.dat

      # Generate a new HPL.dat file or modify existing one for this combination
      # Modify the HPL.dat file with the current parameters
      sed -i "s/^32000        Ns/$N         Ns/" HPL.dat
      sed -i "s/^64           NBs/$NB           NBs/" HPL.dat
      sed -i "s/^3            BCASTs/$BCAST            BCASTs/" HPL.dat
      sed -i "s/^2            PFACTs/$PFACT            PFACTs/" HPL.dat
      sed -i "s/^2            RFACTs/$RFACT            RFACTs/" HPL.dat
      sed -i "s/^1            SWAP/$SWAP            SWAP/" HPL.dat
      sed -i "s/^0            L1/$L1            L1/" HPL.dat
      sed -i "s/^1            U/$U            U/" HPL.dat
      sed -i "s/^1            E/$E            E/" HPL.dat

      # Run the benchmark
      cp HPL.dat ./test_results/auto_hpl_run_$(date +%F_%H-%M-%S).dat
      mpirun --hostfile ~/hosts xhpl 2>&1 >> ./test_results/auto_hpl_run_$(date +%F_%H-%M-%S).log

    done
    done
    done
    done
    done
    done
    done
  done
done

curl -d "Benchmarking done!!" https://ntfy.robpellegrin.duckdns.org/test
