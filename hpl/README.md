# High-Performance Linpack (HPL) Benchmark
This directory contains files related to the [High-Performance Linpack (HPL) benchmark](https://netlib.org/benchmark/hpl/), which is used to evaluate the floating-point computing performance of high-performance computing (HPC) systems. 

## 1. About HPL Benchmark
HPL is used by [TOP500.org](https://www.top500.org "The TOP500 list of supercomputers")
to assess and rank the performance of supercomputers globally. The benchmark measures the computational power of systems and is the basis for the TOP500 list, which ranks the 500 most powerful supercomputers in the world.

## 2. Directory Contents
 - **hpl_results/**: Holds results from noteworthy HPL runs for runs of the cluster, as well as individual nodes.
 - **HPL.dat**: This is the input configuration file for the HPL benchmark. It contains various parameters that define the benchmark's size, problem dimensions, and algorithm-specific settings. An explanation of the parameters can be found at [Netlib.org](https://www.netlib.org/benchmark/hpl/tuning.html).

## 3. Library used – OpenBLAS & OpenMP
- [**OpenBLAS**](https://github.com/OpenMathLib/OpenBLAS)
  - v0.3.30, built from source
  - Compiled for the *generic* ARMv8 architecture.  
    Targeting Cortex‑A53 produced a buggy, unusable build.
- [**OpenMPI**](https://www.open-mpi.org/)
  - v5.0.8, built from source

## 4. Best Results
* **Single Node**

  | Library | GFLOPS | Notes |
  |---------|--------|-------|
  | OpenBLAS (ARMv8) | [**7.0346**](https://github.com/robpellegrin/micro-cluster/blob/main/hpl/hpl_results/single_node_hpl_run_2025-11-03_17-31-47.log) | ~200% faster than ATLAS! |
  | ATLAS (pre‑compiled Debian) | [**2.2211**](https://github.com/robpellegrin/micro-cluster/blob/main/hpl/hpl_results/single_node_atlas_hpl_run_2025-11-03_17-37-06.log) | Default distribution package |

* **Cluster (Seven Identical Nodes)**

  | Library | GFLOPS | Notes |
  |---------|--------|-------|
  | OpenBLAS v0.3.30 (ARMv8) | [**25.308**](https://github.com/robpellegrin/micro-cluster/blob/main/hpl/hpl_results/hpl_run_2025-11-03_09-23-00.log) | ~100% faster than ATLAS |
  | ATLAS (pre‑compiled Debian) | - | Default distribution package |

## 5. Summary

TODO

## 6. References
  |                         |                                              |
  |-------------------------|----------------------------------------------|
  | HPL Benchmark           | https://netlib.org/benchmark/hpl/            |
  | OpenBLAS                | https://github.com/xianyi/OpenBLAS           |
  | OpenMPI                 | https://www.open-mpi.org/                    |
  | TOP500                  | https://www.top500.org/                      |
  | Netlib HPL Tuning Guide | https://netlib.org/benchmark/hpl/tuning.html |

*This is not a how‑to guide; it simply documents what was done and the outcome.*
