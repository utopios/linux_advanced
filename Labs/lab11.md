# **Linux Hardening Lab – Base and Identity Security**

## **Goal**

Your mission is to harden a freshly installed Debian-based Linux system to reduce its attack surface.
You are given SSH access to a server with default settings. You must apply hardening measures at both the **system level** (filesystem, kernel) and the **identity level** (users, authentication).

You are not allowed to install additional software unless the task explicitly permits it.

---

## **Context**

This machine:

* Is exposed to the internet
* Has SSH enabled
* Allows multiple users
* Uses default kernel and service configurations

You are acting as a system administrator preparing this server for production deployment in a sensitive environment.

---

## **Instructions**

Proceed step-by-step. Do not skip tasks. All changes must be made **persistently**, unless the task specifies otherwise.

Write your results, commands, and explanations in a `REPORT.txt` file for future audit.

---

## **Section 1 – System Hardening (Base Layer)**

### Task 1 – Disable Core Dumps

* Check if the system allows core dumps.
* Disable core dumps at runtime and make the change permanent.
* Describe what security risk is mitigated by disabling dumps.

---

### Task 2 – Secure /tmp Directory

* Verify the current mount options of `/tmp`.
* Modify the mount options to prevent execution, SUID, and device access in `/tmp`.
* Ensure this configuration remains after a reboot.

---

### Task 3 – Disable Unused Services

* List all active services at boot time.
* Identify at least **three unnecessary** or unused services.
* Disable and mask them appropriately.
* Justify why each service might represent a risk if left enabled.

---

### Task 4 – Harden Kernel Network Parameters

* Review the current kernel network security parameters.
* Apply settings to disable:

  * Source routing
  * ICMP redirects
  * IP spoofing through reverse path filtering
* Make these changes persist across reboots.

---

## **Section 2 – Identity and Access Hardening**

### Task 5 – Disable SSH Root Login

* Determine if root login via SSH is currently allowed.
* Disable it securely.
* Restrict SSH access to a specific list of users.

---

### Task 6 – Enforce Password Expiration Policy

* Configure the system to enforce:

  * Password expiry after a maximum number of days
  * A minimum time before passwords can be changed again
  * Warning before expiration
* Identify the appropriate file and parameters to edit.

---

### Task 7 – Enforce Password Complexity (PAM)

* Ensure passwords are at least 12 characters long and include upper/lowercase letters, digits, and special characters.
* Modify the appropriate PAM configuration file.
* Explain what each parameter in the PAM configuration does.

---

### Task 8 – Restrict Use of `su` Command

* Restrict the use of `su` to members of a dedicated group.
* Add your administrative user to that group.
* Confirm that unprivileged users cannot switch to root using `su`.

---

### Task 9 – Configure Secure `sudo` Usage

* Configure full session logging for all `sudo` usage.
* Allow your user to execute only one specific system command without requiring a password.
* Justify why such `NOPASSWD` rules must be used carefully.
