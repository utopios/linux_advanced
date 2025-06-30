# Lab: Network Performance Optimization on Debian

## Scenario

The **Client VM** sends traffic to the **Server VM** through a **Router VM**.
We will:

* Enable **BBR** to improve TCP congestion control
* Tune **TCP buffers** to optimize bandwidth
* **Limit connection speed** using `tc` and measure the impact
* Evaluate bandwidth **before and after** optimization

---

## 1. Installing and Configuring the Lab

### Create the Vagrantfile

This file defines the three virtual machines to launch:

```ruby
Vagrant.configure("2") do |config|
  # Router VM
  config.vm.define "router" do |router|
    router.vm.box = "debian/bookworm64"
    router.vm.network "private_network", ip: "192.168.56.1"
    router.vm.provider "virtualbox" do |vb|
      vb.memory = 512
      vb.cpus = 1
    end
  end

  # Client VM
  config.vm.define "client" do |client|
    client.vm.box = "debian/bookworm64"
    client.vm.network "private_network", ip: "192.168.56.10"
    client.vm.provider "virtualbox" do |vb|
      vb.memory = 512
      vb.cpus = 1
    end
  end

  # Server VM
  config.vm.define "server" do |server|
    server.vm.box = "debian/bookworm64"
    server.vm.network "private_network", ip: "192.168.56.20"
    server.vm.provider "virtualbox" do |vb|
      vb.memory = 512
      vb.cpus = 1
    end
  end
end
```

### Start the VMs

```bash
vagrant up
```

### Connect to the VMs

```bash
vagrant ssh router
vagrant ssh client
vagrant ssh server
```

---

## 2. Network Configuration

### Enable routing and NAT on the router

#### Enable IP packet forwarding:

```bash
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

#### Add a NAT rule so client and server can access the Internet:

```bash
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

#### Set the router as the default gateway on client and server:

```bash
sudo ip route add default via 192.168.56.1
```

#### Test connectivity from client to server:

```bash
ping -c 4 192.168.56.20
```

---

## 3. Testing Bandwidth Before Optimization

### Install `iperf3` on client and server:

```bash
sudo apt update && sudo apt install -y iperf3
```

### Start the iperf3 server on the server VM:

```bash
iperf3 -s
```

### Run a bandwidth test from the client:

```bash
iperf3 -c 192.168.56.20
```

### Example output before optimization:

```
[ ID] Interval       Transfer     Bandwidth
[  5]  0.0-10.0 sec  112 MBytes  94.1 Mbits/sec
```

---

## 4. Apply Network Optimizations

### Enable BBR for TCP congestion control

On the **router and server**:

```bash
echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

#### Verify that BBR is enabled:

```bash
sysctl net.ipv4.tcp_congestion_control
```

Expected output:

```
net.ipv4.tcp_congestion_control = bbr
```

---

### Adjust TCP Buffers to Increase Bandwidth

On **router**, **client**, and **server**:

```bash
sudo sysctl -w net.core.rmem_max=26214400
sudo sysctl -w net.core.wmem_max=26214400
```

Make the changes persistent:

```bash
echo "net.core.rmem_max=26214400" | sudo tee -a /etc/sysctl.conf
echo "net.core.wmem_max=26214400" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

Verify:

```bash
sysctl net.core.rmem_max
sysctl net.core.wmem_max
```

Expected output:

```
net.core.rmem_max = 26214400
net.core.wmem_max = 26214400
```

---

### Limit Bandwidth with `tc`

Limit bandwidth to 100 Mbps on the router:

```bash
sudo tc qdisc add dev eth0 root tbf rate 100mbit burst 32kbit latency 400ms
```

Check configuration:

```bash
tc qdisc show dev eth0
```

Expected output:

```
qdisc tbf 8001: root refcnt 2 rate 100Mbit burst 32Kb lat 400.0ms
```

---

## 5. Verify Performance Improvements

Re-run the `iperf3` test from client to server:

```bash
iperf3 -c 192.168.56.20
```

Example result after optimization:

```
[ ID] Interval       Transfer     Bandwidth
[  5]  0.0-10.0 sec  118 MBytes  98.7 Mbits/sec
```

**Conclusion**: Network throughput improved thanks to TCP buffer tuning and BBR congestion control.

---

## 6. Clean Up and Restore Defaults

### Remove the bandwidth limitation:

```bash
sudo tc qdisc del dev eth0 root
```

### Reset TCP settings:

```bash
sudo sysctl -w net.ipv4.tcp_congestion_control=cubic
sudo sysctl -w net.core.rmem_max=212992
sudo sysctl -w net.core.wmem_max=212992
```

### Restart the network service:

```bash
sudo systemctl restart networking
```


