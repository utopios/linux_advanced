# Lab 3 — Advanced Exploration of `/proc` and `/sys` in Linux

## Context

As a Linux system administrator, you are required to monitor, inspect, and sometimes tune the Linux kernel or system behavior. For this, the virtual filesystems `/proc` and `/sys` provide access to a wide range of internal data structures and runtime configuration.


### Create the `audit_sysinfo.sh` Script

Your script must:

* Display CPU and memory information using `/proc`
* List all available CPU cores with their online status and governor using `/sys`
* Display the list of open file descriptors used by the `sshd` process
* Show the write cache policy for each detected disk using `/sys/block`


