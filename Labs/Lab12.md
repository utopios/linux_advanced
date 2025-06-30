### Target Architecture

**VM1 (debian-vm)** → IP: `192.168.56.11`
➤ Provides metrics using `node_exporter` on port `9100`.

**VM2 (prometheus-vm)** → IP: `192.168.56.10`
➤ Hosts Prometheus (port `9090`) and Grafana (port `3000`)
➤ Scrapes metrics from VM1

---

### Step 1: Project Structure

Create a folder for your project:

```bash
mkdir vagrant-prometheus-lab && cd vagrant-prometheus-lab
```

---

### Step 2: Create the `Vagrantfile`

```ruby
Vagrant.configure("2") do |config|

  # Target VM to monitor
  config.vm.define "debian-vm" do |debian|
    debian.vm.box = "debian/bookworm64"
    debian.vm.hostname = "debian-vm"
    debian.vm.network "private_network", ip: "192.168.56.11"
    debian.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
    end
    debian.vm.provision "shell", inline: <<-SHELL
      apt-get update -y
      apt install -y wget curl net-tools vim

      # Install Node Exporter
      useradd --no-create-home --shell /bin/false node_exporter
      cd /tmp
      wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
      tar -xzf node_exporter-1.8.1.linux-amd64.tar.gz
      cp node_exporter-1.8.1.linux-amd64/node_exporter /usr/local/bin/

      cat <<EOF > /etc/systemd/system/node_exporter.service
      [Unit]
      Description=Node Exporter
      After=network.target

      [Service]
      User=node_exporter
      ExecStart=/usr/local/bin/node_exporter

      [Install]
      WantedBy=default.target
      EOF

      systemctl daemon-reexec
      systemctl daemon-reload
      systemctl enable node_exporter
      systemctl start node_exporter
    SHELL
  end

  # Prometheus + Grafana VM
  config.vm.define "prometheus-vm" do |prometheus|
    prometheus.vm.box = "debian/bookworm64"
    prometheus.vm.hostname = "prometheus-vm"
    prometheus.vm.network "private_network", ip: "192.168.56.10"
    prometheus.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
    prometheus.vm.provision "shell", inline: <<-SHELL
      apt-get update -y
      apt install -y wget curl vim net-tools software-properties-common apt-transport-https

      # Create Prometheus user
      useradd --no-create-home --shell /bin/false prometheus

      # Install Prometheus
      cd /tmp
      wget https://github.com/prometheus/prometheus/releases/download/v2.50.1/prometheus-2.50.1.linux-amd64.tar.gz
      tar -xzf prometheus-2.50.1.linux-amd64.tar.gz
      cd prometheus-2.50.1.linux-amd64
      cp prometheus promtool /usr/local/bin/
      mkdir -p /etc/prometheus /var/lib/prometheus
      cp -r consoles/ console_libraries/ /etc/prometheus/
      cp prometheus.yml /etc/prometheus/

      # Prometheus configuration with debian-vm as target
      cat <<EOF > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'debian-node'
    static_configs:
      - targets: ['192.168.56.11:9100']
EOF

      chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
      chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool

      cat <<EOF > /etc/systemd/system/prometheus.service
      [Unit]
      Description=Prometheus
      Wants=network-online.target
      After=network-online.target

      [Service]
      User=prometheus
      ExecStart=/usr/local/bin/prometheus \\
        --config.file=/etc/prometheus/prometheus.yml \\
        --storage.tsdb.path=/var/lib/prometheus \\
        --web.listen-address=:9090

      [Install]
      WantedBy=default.target
      EOF

      systemctl daemon-reload
      systemctl enable prometheus
      systemctl start prometheus

      # Install Grafana
      mkdir -p /etc/apt/keyrings
      wget -q -O - https://apt.grafana.com/gpg.key | tee /etc/apt/keyrings/grafana.asc
      echo "deb [signed-by=/etc/apt/keyrings/grafana.asc] https://apt.grafana.com stable main" | tee /etc/apt/sources.list.d/grafana.list

      apt-get update -y
      apt-get install -y grafana
      systemctl enable grafana-server
      systemctl start grafana-server
    SHELL
  end
end
```

---

### Step 3: Start the VMs

```bash
vagrant up
```

If you later modify the Vagrantfile, use:

```bash
vagrant reload --provision
```

---

### Step 4: Access the Interfaces

| Service       | Host Access Address                                    |
| ------------- | ------------------------------------------------------ |
| Prometheus    | [http://192.168.56.10:9090](http://192.168.56.10:9090) |
| Grafana       | [http://192.168.56.10:3000](http://192.168.56.10:3000) |
| Node Exporter | [http://192.168.56.11:9100](http://192.168.56.11:9100) |

---

### Step 5: Configure Grafana

* Visit: `http://192.168.56.10:3000`
* Login: `admin / admin`
* Add Data Source → Choose **Prometheus**
* URL: `http://localhost:9090`
* Save & Test
* Import a Node Exporter dashboard (e.g., ID: `1860`)

---

### Final Result

* `node_exporter` exposes metrics on `192.168.56.11:9100`
* `prometheus` scrapes them every 10 seconds
* `grafana` visualizes the results with beautiful dashboards
