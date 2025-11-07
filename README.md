# micro-cluster
Experiments with distributed algorithms and data structures on a cluster of small single board computers using OpenMPI.

*Nothing here is meant to be a how‑to guide.*

# Table of Contents
- [micro-cluster](#micro-cluster)
- [Table of Contents](#table-of-contents)
- [Hardware](#hardware)
  - [🖥️ Cluster Overview](#️-cluster-overview)
  - [⚙️ Individual Node Specifications](#️-individual-node-specifications)
  - [🧩 Networking](#-networking)
  - [⚡ Power \& Cooling](#-power--cooling)
- [Real-time Monitoring with Prometheus \& Grafana](#real-time-monitoring-with-prometheus--grafana)
  - [What we're watching and why](#what-were-watching-and-why)
  - [Prometheus](#prometheus)
  - [Grafana](#grafana)
- [Power Consumption](#power-consumption)
  - [Graph of Power Usage](#graph-of-power-usage)
  - [Analysis](#analysis)
- [Using Ansible to Preserve Sanity](#using-ansible-to-preserve-sanity)

# Hardware

## 🖥️ Cluster Overview

| Component              | Description                                    |
| ---------------------- | ---------------------------------------------- |
| **Total Nodes**        | `7`                                            |
| **Architecture**       | `aarch64`                                      |
| **Operating System**   | [**Armbian 25.8.1**](https://www.armbian.com/) |
| **MPI Implementation** | `OpenMPI v4.1.4`                               |
| **Network Topology**   | `Ethernet`                                     |
| **Filesystem Sharing** | `NFS`                                          |

## ⚙️ Individual Node Specifications

| Component       | Specification                                                                        |
| --------------- | ------------------------------------------------------------------------------------ |
| **Board Model** | [**Sweet Potato AML-S905X-CC-V2**](https://libre.computer/products/aml-s905x-cc-v2/) |
| **CPU**         | `4 × ARM Cortex-A53 @ 1.416 GHz`                                                     |
| **RAM**         | `2 GB 32-bit DDR4 SDRAM`                                                             |
| **Storage**     | `16 GB eMMC`                                                                         |
| **Networking**  | `100 Mb Ethernet`                                                                    |
| **Cooling**     | `Passive heatsinks`                                                                  |
| **Power**       | `5 W full load / < 1 W idle`                                                         |

## 🧩 Networking

| Component     | Description                                                                                               |
| ------------- | --------------------------------------------------------------------------------------------------------- |
| **Switch**    | [**TP-Link 8 Port Gigabit Switch**](https://www.amazon.com/TP-Link-Gigabit-Ethernet-Network-Switch/dp/B00A121WN6) |
| **Topology**  | `Star`                                                                                                    |
| **IP Scheme** | `192.168.5.50–56`                                                                                         |

## ⚡ Power & Cooling

| Component                   | Description             |
| --------------------------- | ----------------------- |
| **Power Supply**            | `10-port USB hub`       |
| **Cooling**                 | `Single 120 mm USB fan` |
| **Total Power Consumption** | `~30 W under load`      |

# Real-time Monitoring with Prometheus & Grafana
With [Prometheus](https://prometheus.io/) and [Grafana](https://grafana.com/), we can easily create a visual dashboard that can be used to quickly detect performance issues and optionally get notified when a node goes down or a job stalls.

## What we're watching and why

- **CPU Frequency** – Monitors for thermal throttling; a sudden drop usually indicates overheating.
- **CPU Temperature** – Another indicator of thermal throttling.
- **Load Averages (1 / 5 / 15 min)** – Quick sanity check of how many processes are competing for CPU.
- **Memory Usage** – Proportion of RAM in use; a sudden spike often precedes swapping.
- **Swap Space** – Any activity is an immediate sign of a memory bottleneck.
- **Power Usage** – Sudden fluctuations are a likely indicator of node failure.
<figure>
  <img src=".images/grafana-screenshot.png" alt="HPL performance chart" width="1000">
  <figcaption>Figure 1: Grafana dashboard showing current and historical information for the SBC cluster.
  <br><i>Note: CPU Frequency appears linear because the CPU governor on each node has been explicitly  set to 'performance'. </i><br> </figcaption>
</figure>
<br>

## Prometheus

**Prometheus** is an open‑source monitoring system that collects metrics via HTTP pulls, stores them in a time‑series database, and provides a powerful query language (PromQL) for real‑time analysis.  

I found it more straight-forward to create a custom Prometheus exporter instead of trying to adapt an existing one. Running `python3 ./web-server.py` makes the node metrics available via HTTP. When an HTTP request hits the python web server at port `2146`, it executes `cluster-stats.bash`, then serves the resulting output.

After installing Prometheus, add a new scape configuration to `prometheus.yml`.

```
# prometheus.yml
scrape_configs:
  - job_name: cluster_scrape # New job
    static_configs:
      - targets: ['localhost:2146']
```

## Grafana

**Grafana** is a visualization platform that consumes Prometheus (and other data sources), making it simple to build interactive dashboards, set alerts, and monitor the collected metrics at a glance.

After installing Grafana, import `grafana-dashboard.json`.

# Power Consumption

Power consumption is an important consideration for any cluster—every watt drawn translates directly into electricity bills, especially when the cluster runs for an extended period of time. A nice benefit of SBCs are their low power consumption, keeping operating costs down.

For real‑time power monitoring I used a [THIRDREALITY Zigbee Smart Plug](https://www.amazon.com/THIRDREALITY-Monitoring-Certified-Compatible-SmartThing/dp/B0BPY2KRHH) and [Home Assistant](https://www.home-assistant.io/). The plug reports instantaneous voltage and current to Home Assistant, which exposes the measurements through its [REST API](https://developers.home-assistant.io/docs/api/rest/). Poll that endpoint, parse the JSON payload, and ingest the data into our monitoring stack (Grafana/Prometheus) for continuous graphing and alerting.

## Graph of Power Usage

<figure>
  <img src=".images/power-graph.png" alt="HPL performance chart" width="900">
  <figcaption>Figure 2: Power consumption over 30 minutes. The cluster is idle for 10 minutes, briefly powered off, then put under a heavy load with the HPL benchmark before returning to idle.
  <br>
  </figcaption>
</figure>
<br>

## Analysis

The data from Home Assistant can be easily exported into a CSV for numerical analysis.  
From this data, we get the following:

| State | Max |  Min | Mean |
|-------|-----|------|-----|
| Idle  | `16.1w` | `11.6w` | `12.6w` |
| Under Load | `34.5w` | `26.8w` | `30.1w`|

These measurements show that the entire cluster draws only ≈ 30 watts under full load—roughly the power of a single laptop—demonstrating that a low‑power SBC cluster is an exceptionally cost‑effective platform for experimenting with distributed systems.

# Using Ansible to Preserve Sanity

[Ansible](https://docs.ansible.com/ansible/latest/index.html) is a critical component of cluster operations. Without it we would be manually SSH‑ing into each node (one at a time), installing packages, compiling OpenBLAS, deploying HPL, etc. Ansible allows us to define the desired state of every node in a single, idempotent playbook and execute those changes on all hosts simultaneously. This guarantees identical configuration across the cluster and, most importantly, eliminates monotonous SSH sessions.

The playbooks/roles used to manage this cluster are in a dedicated ansible repository:
- https://github.com/robpellegrin/ansible

---
