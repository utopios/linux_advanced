## **Lab 5: Managing LVM (Logical Volume Manager)**

### **Context and Prerequisites**

You will be working on a dedicated virtual machine with two additional virtual disks:

* **Disk 1**: `/dev/sdb` – 10 GB
* **Disk 2**: `/dev/sdc` – 15 GB

### **Lab Objectives and Steps**

#### 1. Prepare the Disks

* Convert `/dev/sdb` and `/dev/sdc` into **LVM Physical Volumes**.
* Ensure there is no important data on the disks before converting them.

#### 2. Create a Volume Group

* Combine both physical volumes into a **Volume Group** named `vg_tp_lvm`.

#### 3. Create Logical Volumes

From `vg_tp_lvm`, create the following **Logical Volumes**:

* `lv_system`: **6 GB**, intended for system use
* `lv_data`: **10 GB**, intended for user data
* `lv_backup`: **5 GB**, intended for backups or miscellaneous use

> Ensure the total size does **not exceed** the capacity of the Volume Group.

#### 4. Extend a Logical Volume

* Choose the logical volume `lv_data`.
* Extend its size (only if enough free space is available in the Volume Group).
* Verify that the system correctly detects the new size.

#### 5. Clean-up and Removal

* Delete the three Logical Volumes: `lv_system`, `lv_data`, and `lv_backup`.
* Remove the Volume Group `vg_tp_lvm`.
* Remove the LVM metadata from `/dev/sdb` and `/dev/sdc` to restore them to their original state.

---

## Vagrantfile (LVM Lab Environment)

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"
  config.vm.hostname = "lvm-lab"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 1024
    vb.cpus = 1

    # Add 10 GB disk (/dev/sdb)
    vb.customize ['createhd', '--filename', 'disk1.vdi', '--size', 10240]
    vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', 'disk1.vdi']

    # Add 15 GB disk (/dev/sdc)
    vb.customize ['createhd', '--filename', 'disk2.vdi', '--size', 15360]
    vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', 'disk2.vdi']
  end

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y lvm2
  SHELL
end
```

---

#### solutions

```bash
sudo wipefs -a /dev/sdb
sudo wipefs -a /dev/sdc

sudo pvcreate /dev/sdb
sudo pvcreate /dev/sdc

sudo pvdisplay

sudo vgcreate vg_tp_lvm /dev/sdb /dev/sdc

sudo vgdisplay

sudo lvcreate -L 6G -n lv_system vg_tp_lvm
sudo lvcreate -L 10G -n lv_data vg_tp_lvm
sudo lvcreate -L 5G -n lv_backup vg_tp_lvm

sudo lvdisplay

sudo lvextend -L +2G /dev/vg_tp_lvm/lv_data

sudo resize2fs /dev/vg_tp_lvm/lv_data


sudo lvremove -y /dev/vg_tp_lvm/lv_system
sudo lvremove -y /dev/vg_tp_lvm/lv_data
sudo lvremove -y /dev/vg_tp_lvm/lv_backup

sudo vgremove -y vg_tp_lvm

sudo pvremove /dev/sdb
sudo pvremove /dev/sdc

new line
```

