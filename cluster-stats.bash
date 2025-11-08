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
#   and writes them to a file '/tmp/cluster-stats.output'.
#
#   All commands are designed to be lightweight and minimal, using data
#   from /proc and /sys to minimize CPU, memory, and I/O overhead. The goal is
#   to collect useful metrics without negatively impacting with the performance
#   of the cluster.
#
#   After collecting system stats, this script then queries Home Assistant to
#   retrieve information about the current power draw of the cluster.
#
#   Depends on:
#		- GNU Parallel: https://www.gnu.org/software/parallel/
#		- Passwordless SSH

# This file contains the values for HA_ADDRESS and TOKEN.
source .env

OUTPUT_FILE="/tmp/cluster-stats.output"

cleanup() {
  echo
  echo "Cleaning up and exiting..."
  rm -rf $OUTPUT_FILE
  exit 0
}

trap cleanup SIGINT SIGTERM SIGHUP SIGQUIT

get_node_stats() {
  IP_ADDRESS=$1

  # Ping once, wait at most 1 second for a reply, suppress all output.
  # This makes sure the node is online before attempting SSH.
  if ! ping -c 1 -W 1 -q "$IP_ADDRESS" >/dev/null 2>&1; then
    exit 1
  fi

  read -r HOSTNAME CPU_TEMP CPU_FREQ MEM_TOTAL MEM_USED SWAP_USED LOAD1 LOAD5 LOAD15 <<<$(ssh mpi@$IP_ADDRESS '
    HOSTNAME=$(cat /etc/hostname)
    CPU_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
    read -r LOAD1 LOAD5 LOAD15 _ < /proc/loadavg

    CPU_FREQ=$(awk "{ sum += \$1; count++ } END { print sum / count }" \
      /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_cur_freq)

    read -r MEM_TOTAL MEM_FREE SWAP_USED <<< \
      $(awk "/MemTotal/ {t=\$2} /MemFree/ {f=\$2} /SwapTotal/ {s=\$2} /SwapFree/ {sf=\$2} \
      END { print t, f, s-sf }" /proc/meminfo)

    MEM_USED=$((MEM_TOTAL - MEM_FREE))

    echo "$HOSTNAME $CPU_TEMP $CPU_FREQ $MEM_TOTAL $MEM_USED $SWAP_USED $LOAD1 $LOAD5 $LOAD15"
  ')

  # If these values don't exist, something went wrong.
  if [[ -z $HOSTNAME || -z $CPU_TEMP ]]; then
    exit 1
  fi

  echo "node_temp{host=\"$HOSTNAME\"} $CPU_TEMP"
  echo "node_freq{host=\"$HOSTNAME\"} $CPU_FREQ"
  echo "node_total_mem{host=\"$HOSTNAME\"} $MEM_TOTAL"
  echo "node_used_mem{host=\"$HOSTNAME\"} $MEM_USED"
  echo "node_swap_used{host=\"$HOSTNAME\"} $SWAP_USED"
  echo "node_load1{host=\"$HOSTNAME\"} $LOAD1"
  echo "node_load5{host=\"$HOSTNAME\"} $LOAD5"
  echo "node_load15{host=\"$HOSTNAME\"} $LOAD15"
  echo

}

get_power_state() {
  POWER=$(curl -s \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    "$HA_ADDRESS"/api/states/sensor.third_reality_inc_3rsp02028bz_power |
    jq -r '.state')

  echo cluster_power_draw{host=\"cluster\"} $POWER
}

# Function must be exported before it can be used with GNU Parallel.
export -f get_node_stats

# IP scheme for cluster is 192.168.5.5x.
# Use GNU Parallel to execute all iterations of the loop in parallel.
parallel get_node_stats ::: 192.168.5.5{0..6} >>$OUTPUT_FILE

get_power_state >>$OUTPUT_FILE

exit 0
