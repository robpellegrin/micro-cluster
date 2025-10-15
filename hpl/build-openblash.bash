#!/bin/bash

#!/bin/bash
# This script builds and installs OpenBLAS from source, optimized for the CORTEX-A53 CPU
# used in my SBC cluster. Compiling for the specific hardware yields better performance
# than using prebuilt binaries. It installs the library under /opt/openblas-cortexa53.

sudo apt update
sudo apt install -y build-essential git cmake

git clone https://github.com/OpenMathLib/OpenBLAS.git
cd OpenBLAS

make TARGET=CORTEXA53 USE_THREAD=1 NUM_THREADS=0 -j4

sudo make PREFIX=/opt/openblas-cortexa53 install

#export LD_LIBRARY_PATH=/opt/openblas-cortexa53/lib:$LD_LIBRARY_PATH
#export LIBRARY_PATH=/opt/openblas-cortexa53/lib:$LIBRARY_PATH
#export CPATH=/opt/openblas-cortexa53/include:$CPATH
#export OPENBLAS_NUM_THREADS=1
