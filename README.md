# micro-cluster
Experiments with distributed algorithms and data structures on a cluster of small single board computers using OpenMPI.

## Hardware

### 🖥️ Cluster Overview ###

| Component | Description |
|------------|-------------|
| **Total Nodes** | `7` |
| **Architecture** | `aarch64` |
| **Operating System** | [`Armbian 25.8.1`](https://www.armbian.com/) |
| **MPI Implementation** | `OpenMPI v4.1.4` |
| **Network Topology** | `Ethernet` |
| **Filesystem Sharing** | `NFS` |

### ⚙️ Individual Node Specifications ###
| Component | Specification |
|------------|---------------|
| **Board Model** | [`Sweet Potato AML-S905X-CC-V2`](https://libre.computer/products/aml-s905x-cc-v2/) |
| **CPU** | `4 ARM Cortex-A53 @ 1.416GHz ` |
| **RAM** | `2GB 32-bit DDR4 SDRAM` |
| **Storage** | `16GB EMMC` |
| **Networking** | `100 Mb Ethernet` |
| **Cooling** | `Passive heatsinks` |
| **Power** | `5W Full Load / < 1W Idle` |

### 🧩 Networking ###
| Component | Description |
|------------|---------------|
| **Switch:** | [`8 Port Gigabit Switch`](https://www.amazon.com/TP-Link-Gigabit-Ethernet-Network-Switch/dp/B00A121WN6) |
| **Topology** | `Star`
| **IP Scheme:** | `192.168.5.50–56` |

### ⚡ Power & Cooling ###
| Component | Description |
|------------|---------------|
|**Power Supply:** | `10-port USB hub`|
|**Cooling:** | ` Single 120mm USB fan` |
|**Total Power Consumption:** | `~50W under load` |

---
