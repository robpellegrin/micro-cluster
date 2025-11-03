# High-Performance Linpack (HPL) Benchmark
This directory contains files related to the [High-Performance Linpack (HPL) benchmark](https://netlib.org/benchmark/hpl/), which is used to evaluate the floating-point computing performance of high-performance computing (HPC) systems. 

## 1. About HPL Benchmark
HPL is used by [TOP500.org](https://www.top500.org "The TOP500 list of supercomputers")
to assess and rank the performance of supercomputers globally. The benchmark measures the computational power of systems and is the basis for the TOP500 list, which ranks the 500 most powerful supercomputers in the world.

## 2. Directory Contents
 - **hpl_results/**: Holds noteworthy results produced by HPL.
 - **HPL.dat**: This is the input configuration file for the HPL benchmark. It contains various parameters that define the benchmark's size, problem dimensions, and algorithm-specific settings. An explanation of the parameters can be found at [Netlib.org](https://www.netlib.org/benchmark/hpl/tuning.html).

## 3. Library used – OpenBLAS
- **Source**: https://github.com/OpenMathLib/OpenBLAS
- **Version**: 0.3.30
- **Target**: Compiled from for the ARMv8 architecture

*Significantly outperformed the default precompiled ATLAS library available in the Debian repositories by ~30 % on this platform.*

## 5. Results – Single Node

| Library | GFLOPS | Notes |
|---------|--------|-------|
| OpenBLAS v0.3.30 (ARMv8) | **12.3** | ~30 % faster than ATLAS |
| ATLAS (pre‑compiled Debian) | - | Default distribution package |

These numbers come from a single best-run of a single node in the cluster.

## 6. Results – Cluster

| Library | GFLOPS | Notes |
|---------|--------|-------|
| OpenBLAS v0.3.30 (ARMv8) | [**21.485**](https://github.com/robpellegrin/micro-cluster/blob/main/hpl/hpl_results/xhpl_run_2025-11-02_13-27-03.log) | ~100% faster than ATLAS |
| ATLAS (pre‑compiled Debian) | - | Default distribution package |

These numbers come from a single best-run on a cluster of 7 identical nodes.

## 6. Summary

TODO

---

*This is not a how‑to guide; it simply documents what was done and the outcome.*
