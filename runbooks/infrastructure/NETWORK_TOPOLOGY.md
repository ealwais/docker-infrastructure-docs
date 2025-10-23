# Network Topology & Architecture

## Network Diagram
```
Internet
    │
    ├─► UniFi Dream Machine Pro SE (192.168.3.1)
    │   ├── Gateway/Firewall/IDS/IPS
    │   ├── DHCP Server
    │   ├── UniFi Network Controller
    │   └── UniFi Protect (Cameras)
    │
    ├─► Main LAN (192.168.3.0/24)
    │   ├── Mac Mini (192.168.3.20) - Home Assistant
    │   ├── Docker Server (192.168.3.11) - GPU Host
    │   ├── QNAP NAS (192.168.3.10) - Storage
    │   ├── Synology NAS (192.168.3.120) - Backup
    │   └── Workstations (.50-.99)
    │
    ├─► IoT VLAN (192.168.10.0/24)
    │   ├── Zigbee Devices
    │   ├── Smart Switches
    │   ├── Sensors
    │   └── Smart Plugs
    │
    └─► Guest VLAN (192.168.20.0/24)
        └── Isolated Guest Devices
```

## IP Allocation Table

### Static Assignments (192.168.3.0/24)

| IP Range | Purpose | Devices |
|----------|---------|---------|
| .1-.9 | Network Infrastructure | Routers, Switches |
| .10-.19 | Storage Systems | NAS devices |
| .20-.29 | Servers | Physical hosts |
| .30-.39 | Virtual Machines | VMs if any |
| .40-.49 | Management | IPMI, iDRAC |
| .50-.99 | Workstations | Dev machines |
| .100-.254 | DHCP Pool | Dynamic clients |

### Detailed IP Assignments

| IP | Hostname | MAC Address | Type | Notes |
|----|----------|-------------|------|-------|
| 192.168.3.1 | unifi-dream | xx:xx:xx:xx:xx:01 | Gateway | Dream Machine Pro SE |
| 192.168.3.10 | qnap-nas | xx:xx:xx:xx:xx:10 | NAS | QNAP TS-453Be |
| 192.168.3.11 | docker-server | xx:xx:xx:xx:xx:11 | Server | GPU Docker Host |
| 192.168.3.20 | mac-mini | xx:xx:xx:xx:xx:20 | Server | Home Assistant Host |
| 192.168.3.120 | synology-nas | xx:xx:xx:xx:xx:78 | NAS | Synology DS920+ |

## Port Forwarding Rules

| External Port | Internal IP | Internal Port | Service | Protocol |
|---------------|-------------|---------------|---------|----------|
| 443 | 192.168.3.20 | 8123 | Home Assistant | TCP |
| 32400 | 192.168.3.11 | 32400 | Plex | TCP |
| - | - | - | All internal only | - |

## Firewall Rules

### Inbound Rules
```
1. ALLOW established connections
2. ALLOW from Management subnet to all
3. ALLOW ICMP echo (ping)
4. DENY all other inbound
```

### Inter-VLAN Rules
```
1. IoT → Main: ALLOW Home Assistant (8123)
2. IoT → Main: ALLOW MQTT (1883)
3. IoT → Internet: ALLOW NTP, DNS
4. IoT → Guest: DENY all
5. Guest → Main: DENY all
6. Guest → IoT: DENY all
```

## DNS Configuration

### Local DNS Records
| Hostname | IP | Type |
|----------|-----|------|
| ha.local | 192.168.3.20 | A |
| docker.local | 192.168.3.11 | A |
| qnap.local | 192.168.3.10 | A |
| synology.local | 192.168.3.120 | A |
| unifi.local | 192.168.3.1 | A |

### External DNS
- Primary: 1.1.1.1 (Cloudflare)
- Secondary: 8.8.8.8 (Google)

## Network Services

### DHCP Configuration
```yaml
Server: UniFi Dream Machine
Range: 192.168.3.100 - 192.168.3.254
Lease Time: 86400 (24 hours)
DNS: 192.168.3.1
Gateway: 192.168.3.1
```

### VLAN Configuration
| VLAN ID | Name | Network | Tagged Ports |
|---------|------|---------|--------------|
| 1 | Default | 192.168.3.0/24 | All |
| 10 | IoT | 192.168.10.0/24 | Trunk ports |
| 20 | Guest | 192.168.20.0/24 | Trunk ports |

## Bandwidth Allocation

| Service | Priority | Min Guarantee | Max Limit |
|---------|----------|---------------|-----------|
| Home Assistant | High | 10 Mbps | Unlimited |
| Plex/Jellyfin | Medium | 50 Mbps | 200 Mbps |
| Backups | Low | 5 Mbps | 50 Mbps |
| Guest Network | Low | 1 Mbps | 25 Mbps |

## Monitoring Points

### Network Monitoring
- UniFi Controller: https://192.168.3.1
- SNMP: Enabled on all managed devices
- Syslog Server: 192.168.3.11:514

### Key Metrics
- WAN throughput
- Inter-VLAN traffic
- Error rates on interfaces
- Client connection count
- DPI statistics (when enabled)