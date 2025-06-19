# Lab Assignment: Custom Linux Kernel for Hypervisor and Network Optimization


## Context

You are a system administrator working on infrastructure hosting/cloud provider. You are tasked with compiling a **custom Linux kernel** that will be used in two different server environments:

1. A **virtualization host** using KVM, for managing cloud VMs or container workloads.
2. A **network-focused server**, acting as a firewall, load balancer, or high-throughput proxy.

You must **prepare two custom kernels**—one for each use case—and ensure both are installed side-by-side on the same system, selectable from the GRUB bootloader.

---

## Your Tasks

### Step 1: Prepare the system

Install required packages for building the kernel
Download and extract kernel sources


---

### Step 2: Duplicate the current configuration

Start with the configuration of your current kernel


---

### Step 3: Configure the "hypervisor kernel"

Use the menuconfig interface:


Activate the following options:

| Category                          | Option                                                                              |
| --------------------------------- | ----------------------------------------------------------------------------------- |
| `Virtualization`                  | `<*> Kernel-based Virtual Machine (KVM)`                                            |
|                                   | `<*> KVM for Intel processors` or `<*> AMD support`                                 |
| `Device Drivers → Virtio drivers` | `<*> Virtio network driver`, `<*> Virtio block driver`, `[*] PCI driver for virtio` |
| `General Setup`                   | `[*] Control Group support`, `[*] Namespaces support`                               |
| `General Setup → Local version`   | Set this to `-kvm`                                                                  |

---

### Step 4: Configure the "network-optimized kernel"

Repeat the process (`make menuconfig`), and activate:

| Category                                  | Option                                                                                    |
| ----------------------------------------- | ----------------------------------------------------------------------------------------- |
| `Networking support → Networking options` | `[*] QoS and/or fair queueing`, `[*] FQ_CODEL`, `[*] HTB`, `[*] HFSC`                     |
| `Networking support → Netfilter`          | `[*] IP tables`, `[*] Connection tracking`                                                |
| `Device Drivers → Network device support` | Enable Intel/Broadcom drivers, `<*> Bonding driver`, `<*> Virtual Ethernet over bridging` |
| `General Setup → Local version`           | Set this to `-netopt`                                                                     |

---

### Step 5: Build both kernels

You will need to repeat the compilation steps for each configuration (save `.config` separately for each one).

Repeat for the second kernel (overwrite `.config` accordingly).

---

### Step 6: Reboot and test

Use GRUB to boot each kernel and verify with:

---

### Step 7: Documentation

