# Btrfs Lab 6: RAID, Subvolumes, Snapshots, Disk Expansion

---

## Lab Steps

### 1. Environment Setup

* Launch a virtual machine with Debian.
* Create three virtual disk files.
* Attach them as loopback devices.

### 2. Create a Btrfs RAID Volume

* Create a Btrfs file system in RAID1 mode across two loop devices.
* Mount the Btrfs filesystem on a mount point.

### 3. Create and Manage Subvolumes

* Create a subvolume for root (`@`).
* Create a subvolume for `/home` (`@home`).
* List the subvolumes and confirm their creation.

### 4. Snapshot Management

* Create a snapshot of the root subvolume.
* List the snapshots.
* Mount a snapshot if needed for inspection.

### 5. Add a New Disk to the RAID

* Add the third loopback device to the Btrfs volume.
* Rebalance the filesystem to distribute data and metadata across all devices.
* Check the volume status after rebalancing.

### 6. Filesystem Monitoring and Integrity

* Run a scrub operation on the mounted filesystem.
* Display device statistics.
* Show filesystem usage statistics.

### 7. Optional: Simulate Disk Failure

* Detach one of the loopback devices.
* Try to remount the filesystem using the remaining devices.
* Analyze behavior and document observations.

---

## Vagrantfile

Create a file named `Vagrantfile` in a new directory and paste the following:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end

  config.vm.define "btrfs-lab" do |node|
    node.vm.hostname = "btrfs-lab"
    node.vm.network "private_network", type: "dhcp"
    node.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y btrfs-progs
      dd if=/dev/zero of=/btrfs-disk1.img bs=1M count=1024
      dd if=/dev/zero of=/btrfs-disk2.img bs=1M count=1024
      dd if=/dev/zero of=/btrfs-disk3.img bs=1M count=1024
      losetup /dev/loop10 /btrfs-disk1.img
      losetup /dev/loop11 /btrfs-disk2.img
      losetup /dev/loop12 /btrfs-disk3.img
    SHELL
  end
end
```

To start the lab:

```bash
vagrant up
vagrant ssh
```