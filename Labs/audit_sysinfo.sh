#!/bin/bash

show_help() {
    echo "Usage: $0 [-h]"
    echo
    echo "This script audits system information using /proc and /sys."
    echo
    echo "Outputs:"
    echo " - CPU model and core count"
    echo " - Memory and swap details"
    echo " - Online CPUs and current governors"
    echo " - sshd process file descriptors"
    echo " - Disk write cache status"
    exit 0
}

if [[ "$1" == "-h" ]]; then
    show_help
fi

echo "========== CPU INFO =========="
grep "model name" /proc/cpuinfo | head -1
grep -m1 "cpu cores" /proc/cpuinfo

echo
echo "========== MEMORY INFO =========="
grep -E 'MemTotal|MemFree|SwapTotal|SwapFree' /proc/meminfo

echo
echo "========== CPU STATUS =========="
for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
    name=$(basename "$cpu")
    online_file="$cpu/online"
    governor_file="$cpu/cpufreq/scaling_governor"

    if [[ -f "$online_file" ]]; then
        online=$(cat "$online_file")
    else
        online="always online"
    fi

    if [[ -f "$governor_file" ]]; then
        governor=$(cat "$governor_file")
    else
        governor="N/A"
    fi

    echo "$name - Online: $online - Governor: $governor"
done

echo
echo "========== SSHD OPEN FILES =========="
sshd_pid=$(pgrep -o sshd)

if [[ -n "$sshd_pid" ]]; then
    echo "sshd PID: $sshd_pid"
    ls -l /proc/$sshd_pid/fd
else
    echo "sshd is not running."
fi

echo
echo "========== DISK WRITE CACHE =========="
for disk in /sys/block/*; do
    disk_name=$(basename "$disk")
    model_file="$disk/device/model"
    cache_file="$disk/queue/write_cache"

    model=$(cat "$model_file" 2>/dev/null || echo "Unknown")
    cache=$(cat "$cache_file" 2>/dev/null || echo "Not supported")

    echo "$disk_name - Model: $model - Write Cache: $cache"
done
