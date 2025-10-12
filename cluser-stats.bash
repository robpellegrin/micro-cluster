#!/bin/bash
#
# Author: Rob Pellegrin
# Date:   10/11/2025
# file:   cluster-stats.bash
# Description:
#   This script collects system statistics from all nodes in the cluster in
#   parallel using GNU Parallel and SSH. It connects to each node, retrieves:
#     - Hostname
#     - CPU temperature
#     - Average CPU frequency
#     - Total and used memory
#     - 1, 5, and 15-minute load averages
#
#   The results are printed to the console.
#
#   All commands are designed to be lightweight and minimal, using data
#   from /proc and /sys to minimize CPU, memory, and I/O overhead. The goal is
#   to collect useful metrics without interfering with the performance of the
#   cluster.
#

get_node_stats() {
  IP_ADDRESS=$1

  read -r HOSTNAME CPU_TEMP CPU_FREQ MEM_TOTAL MEM_USED LOAD1 LOAD5 LOAD15 <<< $(ssh mpi@$IP_ADDRESS '
    HOSTNAME=$(cat /etc/hostname)
    CPU_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
    CPU_FREQ=$(awk "{ sum += \$1; count++ } END { print sum / count }" /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_cur_freq)
    read -r MEM_TOTAL MEM_FREE <<< $(awk "/MemTotal/ {t=\$2} /MemFree/ {f=\$2} END { print t, f }" /proc/meminfo)
    MEM_USED=$((MEM_TOTAL - MEM_FREE))
    read -r LOAD1 LOAD5 LOAD15 _ < /proc/loadavg

    echo "$HOSTNAME $CPU_TEMP $CPU_FREQ $MEM_TOTAL $MEM_USED $LOAD1 $LOAD5 $LOAD15"
  ')

  echo "Host: $HOSTNAME"
  echo "Temp: $CPU_TEMP"
  echo "Freq: $CPU_FREQ"
  echo "Total Mem: $MEM_TOTAL"
  echo "Used Mem: $MEM_USED"
  echo "1 Min: $LOAD1"
  echo "5 Min: $LOAD5"
  echo "15 Min: $LOAD15"
  echo

}

export -f get_node_stats

parallel get_node_stats ::: 192.168.5.5{0..5}

exit 0
