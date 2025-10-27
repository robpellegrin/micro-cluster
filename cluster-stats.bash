#!/bin/bash
#
# Author: Rob Pellegrin
# Date:   10/11/2025
# File:   cluster-stats.bash
# Description:
#   This script collects system statistics from all nodes in the cluster in
#   parallel using GNU Parallel and SSH. It connects to each node, retrieves:
#     - Hostname
#     - CPU temperature
#     - Average CPU frequency
#     - Total and used memory
#     - 1, 5, and 15-minute load averages
#
#   and writes them to a file 'output.txt'.
#
#   All commands are designed to be lightweight and minimal, using data
#   from /proc and /sys to minimize CPU, memory, and I/O overhead. The goal is
#   to collect useful metrics without negatively impacting with the performance
#   of the cluster.
#

cleanup() {
  echo
  echo "Cleaning up and exiting..."
  rm -rf output.txt
  exit 0
}

trap cleanup SIGINT SIGTERM SIGHUP SIGQUIT

get_node_stats() {
  IP_ADDRESS=$1

  read -r HOSTNAME CPU_TEMP CPU_FREQ MEM_TOTAL MEM_USED LOAD1 LOAD5 LOAD15 <<<$(ssh mpi@$IP_ADDRESS '
    HOSTNAME=$(cat /etc/hostname)
    CPU_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
    CPU_FREQ=$(awk "{ sum += \$1; count++ } END { print sum / count }" /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_cur_freq)
    read -r MEM_TOTAL MEM_FREE <<< $(awk "/MemTotal/ {t=\$2} /MemFree/ {f=\$2} END { print t, f }" /proc/meminfo)
    MEM_USED=$((MEM_TOTAL - MEM_FREE))
    read -r LOAD1 LOAD5 LOAD15 _ < /proc/loadavg

    echo "$HOSTNAME $CPU_TEMP $CPU_FREQ $MEM_TOTAL $MEM_USED $LOAD1 $LOAD5 $LOAD15"
  ')

  echo "node_temp{host=\"$HOSTNAME\"} $CPU_TEMP"
  echo "node_freq{host=\"$HOSTNAME\"} $CPU_FREQ"
  echo "node_total_mem{host=\"$HOSTNAME\"} $MEM_TOTAL"
  echo "node_used_mem{host=\"$HOSTNAME\"} $MEM_USED"
  echo "node_load1{host=\"$HOSTNAME\"} $LOAD1"
  echo "node_load5{host=\"$HOSTNAME\"} $LOAD5"
  echo "node_load15{host=\"$HOSTNAME\"} $LOAD15"
  echo
}

# Function must be exported before it can be used with GNU Parallel.
export -f get_node_stats

# IP scheme for cluster is 192.168.5.5x
parallel get_node_stats ::: 192.168.5.5{0..6} >>output.txt

exit 0
