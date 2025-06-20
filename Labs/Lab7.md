# Lab 7: GRUB Bootloader Configuration and Troubleshooting

## Context

You are a system administrator responsible for system recovery and boot-time diagnostics. This lab will help you understand and manipulate the GRUB bootloader to access different system states, recover from errors, and adjust boot parameters.


## Lab Environment

Use the following Vagrant configuration to create the required environment with GUI access:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"
  config.vm.hostname = "grub-lab"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.memory = 1024
  end

  config.vm.provision "shell", inline: <<-SHELL
    sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=5/' /etc/default/grub
    sed -i 's/GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/' /etc/default/grub
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=""/' /etc/default/grub
    echo 'GRUB_TERMINAL=console' >> /etc/default/grub
    update-grub
  SHELL
end
```

## Instructions

### Step 1: Access the GRUB Menu

* Start the virtual machine using `vagrant up`.
* Observe the GUI window.
* When GRUB appears, wait for the countdown or press a key to access the menu.

### Step 2: Boot into Rescue Mode

* Select the default kernel and press `e` to edit it.
* At the end of the `linux` line, add:

  ```
  systemd.unit=rescue.target
  ```
* Press `Ctrl + x` or `F10` to boot.
* Observe the system behavior and login shell.

### Step 3: Boot into Emergency Mode

* Reboot the system.
* Edit the GRUB entry again and add:

  ```
  systemd.unit=emergency.target
  ```
* Boot and observe the differences from rescue mode.

### Step 4: Boot into Debug Mode

* Edit the GRUB entry and add:

  ```
  systemd.log_level=debug systemd.log_target=console
  ```
* Observe the detailed logs displayed during boot.

### Step 5: Reset the Root Password

* Edit the GRUB boot entry.
* Replace the `init=` section or add:

  ```
  init=/bin/bash
  ```
* After the system boots into a shell:

  * Remount the root filesystem with write permissions
  * Change the root password
  * Reboot the system

### Step 6: Simulate a Boot Failure and Recover

* Intentionally modify `/etc/fstab` with an incorrect device or mount point.
* Reboot the system.
* Use rescue or emergency mode to access the shell and correct the error.
* Reboot to confirm the system starts properly.

### Step 7: Rebuild GRUB Configuration

* If you install a new kernel or modify the GRUB configuration again, run:

  ```bash
  sudo update-grub
  ```