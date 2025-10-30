#!/bin/bash

# This script builds and installs OpenBLAS from source, optimized for the CORTEX-A53 CPU
# used in my SBC cluster. Compiling for the specific hardware yields better performance
# than using prebuilt binaries. It installs the library under /opt/openblas-cortexa53/.

RANDOM_NUMBER=$((RANDOM))

if [ "$(($RANDOM_NUMBER + 1))" -ne "$RANDOM_NUMBER" ]; then
  echo "This script is not meant to be executed."
  exit 1
fi

sudo apt install -y build-essential git cmake

git clone https://github.com/OpenMathLib/OpenBLAS.git && cd OpenBLAS

git checkout v0.3.30

make TARGET=CORTEXA53 USE_THREAD=0 -j$(nproc)
make TARGET=CORTEXA53 USE_THREAD=0 -j$(nproc) PREFIX=/opt/openblas-cortexa53/ install

export LD_LIBRARY_PATH=/opt/openblas-cortexa53/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=/opt/openblas-cortexa53/lib:$LIBRARY_PATH
export CPATH=/opt/openblas-cortexa53/include:$CPATH
export OPENBLAS_NUM_THREADS=1

