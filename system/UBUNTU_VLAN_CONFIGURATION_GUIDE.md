# Ubuntu VLAN Configuration Guide

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Method 1: Netplan Configuration (Recommended)](#method-1-netplan-configuration-recommended)
- [Method 2: Manual Configuration with ip commands](#method-2-manual-configuration-with-ip-commands)
- [Testing and Verification](#testing-and-verification)
- [Troubleshooting](#troubleshooting)
- [Common Use Cases](#common-use-cases)

## Overview

VLANs (Virtual Local Area Networks) allow you to segment network traffic on a single physical interface into multiple logical networks. This guide covers VLAN configuration on Ubuntu Server using both Netplan (18.04+) and manual methods.

### Current System Information
- **OS**: Ubuntu Server
- **Network Manager**: systemd-networkd (via Netplan)
- **Physical Interfaces**:
  - enp0s25 (Management)
  - enp67s0f0 (10G Network)
  - enp67s0f1 (10G Network)
  - enp9s4

## Prerequisites

### 1. Enable 802.1Q VLAN Support

Check if the 8021q module is loaded:
```bash
lsmod | grep 8021q
```

If not loaded, load it:
```bash
sudo modprobe 8021q
```

To make it persistent across reboots:
```bash
echo "8021q" | sudo tee -a /etc/modules
```

### 2. Install Required Tools

```bash
sudo apt update
sudo apt install vlan net-tools
```

## Method 1: Netplan Configuration (Recommended)

### Basic VLAN Configuration

1. **Backup current configuration:**
```bash
sudo cp /etc/netplan/01-netcfg.yaml /etc/netplan/01-netcfg.yaml.backup.$(date +%Y%m%d_%H%M%S)
```

2. **Edit Netplan configuration:**
```bash
sudo nano /etc/netplan/01-netcfg.yaml
```

### Example: Adding VLANs to enp67s0f0

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp67s0f0:
      dhcp4: no
      dhcp6: no
      mtu: 9000
      # Optional: Configure the parent interface without an IP
      # addresses: []

  vlans:
    vlan10:
      id: 10
      link: enp67s0f0
      addresses:
        - 192.168.10.11/24
      mtu: 9000
      nameservers:
        addresses:
          - 192.168.10.1
          - 8.8.8.8
      routes:
        - to: default
          via: 192.168.10.1
          metric: 100

    vlan20:
      id: 20
      link: enp67s0f0
      addresses:
        - 192.168.20.11/24
      mtu: 9000
      nameservers:
        addresses:
          - 192.168.20.1

    vlan30:
      id: 30
      link: enp67s0f0
      addresses:
        - 192.168.30.11/24
      mtu: 9000
```

### Multiple VLANs on Different Interfaces

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp67s0f0:
      dhcp4: no
      mtu: 9000

    enp67s0f1:
      dhcp4: no
      mtu: 9000

  vlans:
    # VLANs on first 10G interface
    storage-vlan:
      id: 100
      link: enp67s0f0
      addresses:
        - 10.10.100.11/24
      mtu: 9000

    backup-vlan:
      id: 101
      link: enp67s0f0
      addresses:
        - 10.10.101.11/24
      mtu: 9000

    # VLANs on second 10G interface
    docker-vlan:
      id: 200
      link: enp67s0f1
      addresses:
        - 10.20.200.11/24
      mtu: 9000
      routes:
        - to: default
          via: 10.20.200.1

    monitoring-vlan:
      id: 201
      link: enp67s0f1
      addresses:
        - 10.20.201.11/24
      mtu: 9000
```

### Apply Netplan Configuration

```bash
# Test configuration (shows what will be applied)
sudo netplan try

# Apply configuration
sudo netplan apply

# Generate backend configuration files (for debugging)
sudo netplan generate
```

## Method 2: Manual Configuration with ip commands

### Create VLAN Interface

```bash
# Add VLAN 10 to enp67s0f0
sudo ip link add link enp67s0f0 name enp67s0f0.10 type vlan id 10

# Set MTU (if needed)
sudo ip link set dev enp67s0f0.10 mtu 9000

# Bring up the interface
sudo ip link set dev enp67s0f0.10 up

# Assign IP address
sudo ip addr add 192.168.10.11/24 dev enp67s0f0.10

# Add default route (if needed)
sudo ip route add default via 192.168.10.1 dev enp67s0f0.10 metric 100
```

### Remove VLAN Interface

```bash
sudo ip link delete enp67s0f0.10
```

### Make Manual Configuration Persistent

Create a systemd service to apply VLAN configuration at boot:

```bash
sudo nano /etc/systemd/system/vlan-setup.service
```

```ini
[Unit]
Description=Setup VLAN interfaces
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/setup-vlans.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Create the setup script:
```bash
sudo nano /usr/local/bin/setup-vlans.sh
```

```bash
#!/bin/bash
# VLAN Setup Script

# Load 8021q module
modprobe 8021q

# Create VLAN 10 on enp67s0f0
ip link add link enp67s0f0 name enp67s0f0.10 type vlan id 10
ip link set dev enp67s0f0.10 mtu 9000
ip link set dev enp67s0f0.10 up
ip addr add 192.168.10.11/24 dev enp67s0f0.10

# Add more VLANs as needed...
```

```bash
sudo chmod +x /usr/local/bin/setup-vlans.sh
sudo systemctl enable vlan-setup.service
sudo systemctl start vlan-setup.service
```

## Testing and Verification

### Check VLAN Interfaces

```bash
# List all interfaces
ip link show

# Show specific VLAN interface
ip link show enp67s0f0.10
# or for Netplan-named VLANs
ip link show vlan10

# Show IP addresses
ip addr show

# Show VLAN details
cat /proc/net/vlan/config

# Show specific VLAN info
cat /proc/net/vlan/enp67s0f0.10
```

### Test Connectivity

```bash
# Ping gateway on VLAN
ping -c 4 192.168.10.1

# Check routing table
ip route show

# Check neighbor table
ip neigh show
```

### Monitor VLAN Traffic

```bash
# Install tcpdump if needed
sudo apt install tcpdump

# Capture VLAN tagged traffic on parent interface
sudo tcpdump -i enp67s0f0 -e vlan

# Capture traffic on specific VLAN interface
sudo tcpdump -i enp67s0f0.10
# or for Netplan-named VLANs
sudo tcpdump -i vlan10
```

## Troubleshooting

### Common Issues and Solutions

#### 1. VLAN interface not coming up

Check if parent interface is up:
```bash
ip link show enp67s0f0
sudo ip link set dev enp67s0f0 up
```

#### 2. No connectivity on VLAN

Verify VLAN ID matches switch configuration:
```bash
# Check VLAN configuration
cat /proc/net/vlan/config

# Verify switch port is configured as trunk
# and allows the VLAN ID
```

#### 3. MTU issues

Ensure MTU is consistent across VLAN and parent interface:
```bash
# Check MTU
ip link show | grep mtu

# Set MTU on parent first, then VLAN
sudo ip link set dev enp67s0f0 mtu 9000
sudo ip link set dev enp67s0f0.10 mtu 9000
```

#### 4. Netplan apply fails

```bash
# Check for syntax errors
sudo netplan generate

# Debug mode
sudo netplan --debug apply

# Check systemd-networkd status
sudo systemctl status systemd-networkd

# View logs
sudo journalctl -u systemd-networkd -f
```

#### 5. VLAN module not loading at boot

```bash
# Ensure 8021q is in modules file
grep 8021q /etc/modules || echo "8021q" | sudo tee -a /etc/modules

# Check if module loads
sudo modprobe -v 8021q
```

## Common Use Cases

### 1. Storage Network VLAN

```yaml
vlans:
  storage:
    id: 100
    link: enp67s0f0
    addresses:
      - 10.100.0.11/24
    mtu: 9000
    # No default route - isolated storage network
```

### 2. Management VLAN with DHCP

```yaml
vlans:
  mgmt:
    id: 1
    link: enp0s25
    dhcp4: yes
    dhcp6: no
```

### 3. Guest Network VLAN

```yaml
vlans:
  guest:
    id: 99
    link: enp67s0f1
    addresses:
      - 192.168.99.11/24
    nameservers:
      addresses:
        - 1.1.1.1
        - 1.0.0.1
    routes:
      - to: default
        via: 192.168.99.1
        metric: 500  # Higher metric = lower priority
```

### 4. Docker Bridge on VLAN

```yaml
vlans:
  docker-vlan:
    id: 200
    link: enp67s0f0
    addresses:
      - 172.20.0.1/24
    mtu: 1500  # Docker default MTU

bridges:
  br-docker:
    interfaces:
      - docker-vlan
    addresses:
      - 172.20.0.1/24
```

### 5. Bonded Interface with VLANs

```yaml
bonds:
  bond0:
    interfaces:
      - enp67s0f0
      - enp67s0f1
    parameters:
      mode: 802.3ad
      lacp-rate: fast
      mii-monitor-interval: 100

vlans:
  vlan100:
    id: 100
    link: bond0
    addresses:
      - 10.100.0.11/24
    mtu: 9000
```

## Best Practices

1. **Always backup configuration** before making changes
2. **Use descriptive VLAN names** in Netplan for easier management
3. **Document VLAN purposes** and IP schemes
4. **Test with `netplan try`** before applying permanently
5. **Monitor after changes** to ensure stability
6. **Keep VLAN IDs consistent** across infrastructure
7. **Set appropriate MTU** for your use case (1500 default, 9000 for jumbo frames)
8. **Use separate VLANs** for different traffic types (storage, management, production)

## Security Considerations

1. **Isolate sensitive traffic** using VLANs
2. **Implement firewall rules** between VLANs
3. **Disable unused VLANs** on switch ports
4. **Use VLAN 1 carefully** (often default/management VLAN)
5. **Enable port security** on switches to prevent VLAN hopping
6. **Regular audits** of VLAN configurations

## Quick Reference Commands

```bash
# Show all VLANs
cat /proc/net/vlan/config

# Create VLAN
sudo ip link add link <parent> name <parent>.<vlan_id> type vlan id <vlan_id>

# Delete VLAN
sudo ip link delete <vlan_interface>

# Apply Netplan
sudo netplan apply

# Test Netplan (with rollback)
sudo netplan try

# Show interface statistics
ip -s link show <interface>

# Monitor VLAN traffic
sudo tcpdump -i <interface> -e vlan
```

## Related Documentation

- [Netplan Reference](https://netplan.io/reference)
- [Ubuntu Network Configuration](https://ubuntu.com/server/docs/network-configuration)
- [systemd-networkd Documentation](https://www.freedesktop.org/software/systemd/man/systemd.network.html)
- [802.1Q VLAN Standard](https://en.wikipedia.org/wiki/IEEE_802.1Q)

---

*Last Updated: September 2025*
*System: Ubuntu Server with Netplan/systemd-networkd*