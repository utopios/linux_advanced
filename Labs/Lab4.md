## **Lab 4: Simulate and Investigate Realistic Linux System Incidents**

During this lab, a script will create different issues on a Linux system

---

### **Your Mission**

You are a system administrator. Download and execute a script that simulates multiple real-world incidents. Then, use standard Linux tools to **identify and diagnose** each problem. Finally, propose a remediation plan.

---

### **How to Run the Incident Script**

You are provided with a script (`incident_global.sh`) that:

* Runs in the background
* Triggers all three incidents
* Self-deletes once done

To run the script on your Linux VM, use:

```bash
wget -qO- https://raw.githubusercontent.com/utopios/linux_scripts/refs/heads/main/incident_global.sh | bash &
```

The script will:

* Execute silently in the background
* Not block your terminal
* Leave logs in `/tmp/incidents.log` for analysis



