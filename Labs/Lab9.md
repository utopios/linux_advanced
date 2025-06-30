
# LAB 9 – Investigate and Resolve System Performance Issues (Multi-Layer)

## Scenario:

You are given access to a Linux VM where a script is running in the background.
Users complain that the system is "very slow", especially during application usage and data processing.

Your mission is to:

* Identify what’s wrong
* Use the appropriate tools per layer (CPU, memory, I/O, application)
* Fix the problem and explain **why** each issue occurred

---

## Files provided:

You are given a single file:

### `lab_trigger.sh`

```bash
#!/bin/bash

python3 -c "
import threading
def burn(): 
    while True: 3.14*3.14
for _ in range(150): threading.Thread(target=burn).start()
" &

stress-ng --vm 2 --vm-bytes 90% --timeout 120 &

mkdir -p /tmp/lab_io
for i in $(seq 1 3000); do
  echo 'data line' > /tmp/lab_io/file_$i
  sync
done &

python3 -c "
import threading, time
lock = threading.Lock()
def deadlock():
    lock.acquire()
    time.sleep(300)
for _ in range(10): threading.Thread(target=deadlock).start()
" &

echo "All workload started. Investigate the system."
```

---



Investigate the performance problems using the tools below, and solve each issue.

---

## Required tools by layer

| Layer       | Tools the trainee must use                 |
| ----------- | ------------------------------------------ |
| CPU         | `uptime`, `mpstat`, `vmstat`, `top -H`     |
| Memory      | `free -h`, `vmstat`, `pidstat -r`, `dmesg` |
| Disk I/O    | `iostat -xz 1`, `iotop`, `vmstat`, `lsof`  |
| Application | `strace`, `ps -T`, `top -H`, code review   |

