# UniFi Network MCP Server Configuration

**Server Version:** 0.1.3
**Status:** ✅ Connected to 192.168.3.1
**Last Updated:** October 3, 2025

---

## Overview

The UniFi Network MCP server provides read-only access to UniFi network controller functionality through Claude Desktop's Model Context Protocol. It offers 60+ tools for network management, monitoring, and configuration.

**Connection:** 192.168.3.1 (local UniFi Dream Machine)
**Access Mode:** Read-only with confirmation for changes
**Site:** default

---

## Installation

### Location
```
/Users/ealwais/unifi-mcp-readonly/
```

### Directory Structure
```
unifi-mcp-readonly/
├── venv/                      # Python virtual environment
│   └── bin/
│       └── unifi-network-mcp  # Executable
├── config/
│   └── config.yaml           # Configuration file
└── README.md
```

---

## Configuration

### Main Configuration File

**Location:** `/Users/ealwais/unifi-mcp-readonly/config/config.yaml`

```yaml
# SAFE READ-ONLY CONFIGURATION
# This configuration only allows reading data, no changes possible

server:
  name: "UniFi Network (Read-Only)"
  version: "1.0.0"
  log_level: "INFO"

unifi:
  host: "192.168.3.1"
  username: "emalwais"
  password: "Dunc@n212025!"
  port: 443
  site: "default"
  verify_ssl: false

permissions:
  read: true
  write: false
  execute: false
```

### Claude Desktop Configuration

**Location:** `~/Library/Application Support/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "unifi-network-readonly": {
      "command": "/Users/ealwais/unifi-mcp-readonly/venv/bin/unifi-network-mcp",
      "args": [],
      "env": {
        "UNIFI_HOST": "192.168.3.1",
        "UNIFI_USERNAME": "emalwais",
        "UNIFI_PASSWORD": "Dunc@n212025!",
        "UNIFI_PORT": "443",
        "UNIFI_SITE": "default",
        "UNIFI_VERIFY_SSL": "false",
        "CONFIG_PATH": "/Users/ealwais/unifi-mcp-readonly/config/config.yaml"
      }
    }
  }
}
```

---

## Troubleshooting

### Issue 1: Missing `unifi:` Configuration Section

**Symptoms:**
```
omegaconf.errors.ConfigAttributeError: Missing key unifi
    full_key: unifi
    object_type=dict
```

**Root Cause:**
The config.yaml file was missing the `unifi:` section with connection details.

**Solution:**

Edit `/Users/ealwais/unifi-mcp-readonly/config/config.yaml` and add:

```yaml
unifi:
  host: "192.168.3.1"
  username: "emalwais"
  password: "Dunc@n212025!"
  port: 443
  site: "default"
  verify_ssl: false
```

Restart Claude Desktop.

---

### Issue 2: Connection Refused

**Symptoms:**
- Server disconnects immediately
- Log shows connection errors
- "Failed to connect to UniFi controller"

**Possible Causes:**
1. UniFi controller is offline
2. Wrong IP address
3. Firewall blocking port 443
4. Wrong credentials

**Solution:**

1. Verify UniFi controller is accessible:
```bash
curl -k https://192.168.3.1
```

2. Check credentials in config.yaml

3. Verify port 443 is open:
```bash
nc -zv 192.168.3.1 443
```

4. Check UniFi controller logs

---

### Issue 3: SSL Certificate Errors

**Symptoms:**
- SSL verification errors
- Certificate validation failures

**Solution:**

Set `verify_ssl: false` in config.yaml:

```yaml
unifi:
  verify_ssl: false
```

**Note:** Only disable SSL verification for local network connections.

---

## Available Tools (60+)

### Client Management (9 tools)

#### List & Query
- `unifi_list_clients` - List all connected devices
  - Filter by type (all/wired/wireless)
  - Include offline devices option
  - Limit results

- `unifi_get_client_details` - Get device details by MAC address
  - Full device information
  - Connection history
  - Statistics

- `unifi_list_blocked_clients` - Show blocked devices
  - All blocked devices
  - Block reason
  - When blocked

#### Management (Requires Confirmation)
- `unifi_block_client` - Block device from network
- `unifi_unblock_client` - Unblock previously blocked device
- `unifi_rename_client` - Rename device
- `unifi_force_reconnect_client` - Force device to reconnect

#### Guest Access
- `unifi_authorize_guest` - Authorize guest with limits
  - Duration (minutes)
  - Upload/download speed limits
  - Bandwidth quota

- `unifi_unauthorize_guest` - Revoke guest authorization

---

### Device Management (6 tools)

#### Query
- `unifi_list_devices` - List all UniFi hardware
  - Filter by type (AP/Switch/Gateway/etc)
  - Filter by status (online/offline)
  - Include detailed info

- `unifi_get_device_details` - Get specific device info
  - Model, firmware version
  - Uptime, load
  - Port configuration

#### Operations (Requires Confirmation)
- `unifi_reboot_device` - Reboot device
- `unifi_rename_device` - Rename device
- `unifi_adopt_device` - Adopt new device
- `unifi_upgrade_device` - Firmware upgrade

---

### Network Configuration (4 tools)

- `unifi_list_networks` - List all networks (LAN/WAN/VLAN)
- `unifi_get_network_details` - Get network configuration
- `unifi_update_network` - Modify network (requires confirmation)
- `unifi_create_network` - Create new network

---

### WiFi Management (4 tools)

- `unifi_list_wlans` - List all wireless networks
- `unifi_get_wlan_details` - Get SSID configuration
- `unifi_update_wlan` - Modify SSID (requires confirmation)
- `unifi_create_wlan` - Create new SSID

---

### Firewall & Security (9 tools)

#### Policy Management
- `unifi_list_firewall_policies` - List all firewall rules
- `unifi_get_firewall_policy_details` - Get rule details
- `unifi_toggle_firewall_policy` - Enable/disable rule
- `unifi_create_firewall_policy` - Create new rule
- `unifi_update_firewall_policy` - Modify existing rule
- `unifi_create_simple_firewall_policy` - Simplified rule creation

#### Infrastructure
- `unifi_list_firewall_zones` - List network zones
- `unifi_list_ip_groups` - List IP groups

---

### Port Forwarding (5 tools)

- `unifi_list_port_forwards` - List all port forward rules
- `unifi_get_port_forward` - Get specific rule details
- `unifi_toggle_port_forward` - Enable/disable rule
- `unifi_create_port_forward` - Create new port forward
- `unifi_update_port_forward` - Modify existing rule
- `unifi_create_simple_port_forward` - Simplified creation

---

### Traffic & Routing (6 tools)

- `unifi_list_traffic_routes` - List routing rules (PBR)
- `unifi_get_traffic_route_details` - Get route config
- `unifi_toggle_traffic_route` - Enable/disable route
- `unifi_update_traffic_route` - Modify route
- `unifi_create_traffic_route` - Create new route
- `unifi_create_simple_traffic_route` - Simplified creation

---

### QoS Management (5 tools)

- `unifi_list_qos_rules` - List QoS rules
- `unifi_get_qos_rule_details` - Get QoS configuration
- `unifi_toggle_qos_rule_enabled` - Enable/disable QoS
- `unifi_update_qos_rule` - Modify QoS rule
- `unifi_create_qos_rule` - Create new QoS rule
- `unifi_create_simple_qos_rule` - Simplified creation

---

### VPN Configuration (4 tools)

- `unifi_list_vpn_clients` - List VPN clients (WireGuard/OpenVPN)
- `unifi_get_vpn_client_details` - Get VPN client config
- `unifi_list_vpn_servers` - List VPN servers
- `unifi_get_vpn_server_details` - Get VPN server config

---

### Statistics & Monitoring (9 tools)

#### Network Stats
- `unifi_get_network_stats` - Overall network statistics
  - Duration: hourly/daily/weekly/monthly
  - Bandwidth usage
  - Client counts

- `unifi_get_client_stats` - Client usage statistics
  - Traffic patterns
  - Connection history
  - Bandwidth consumption

- `unifi_get_device_stats` - Device performance stats
  - Load, temperature
  - Port statistics
  - Radio performance (for APs)

- `unifi_get_top_clients` - Top bandwidth users
  - Sorted by total bytes
  - Duration filter
  - Configurable limit

#### Deep Inspection
- `unifi_get_dpi_stats` - Deep Packet Inspection stats
  - Applications detected
  - Category breakdown
  - Traffic patterns

#### System Health
- `unifi_get_alerts` - Recent system alerts
  - Limit results
  - Include archived
  - Alert severity

- `unifi_get_system_info` - Controller information
  - Version
  - Uptime
  - System resources

- `unifi_get_network_health` - Network health summary
  - WAN status
  - Device counts
  - Performance metrics

- `unifi_get_site_settings` - Site configuration
  - Country code
  - Timezone
  - Connectivity monitoring

---

## Safety Features

### Read-Only Mode

**Default Behavior:**
- All read operations execute immediately
- All write operations require explicit confirmation
- Configuration changes show preview before applying

### Confirmation Required For:
- Blocking/unblocking clients
- Rebooting devices
- Modifying configurations
- Creating/deleting rules
- Firmware upgrades
- Network changes

### Dry-Run Mode

Most "create" and "update" operations support dry-run:

```
unifi_create_simple_firewall_policy({
  policy: {...},
  confirm: false  // Shows preview only
})
```

Set `confirm: true` to actually apply changes.

---

## Example Use Cases

### Network Monitoring

**Check connected devices:**
```
"Show me all connected wireless devices"
→ unifi_list_clients(filter_type="wireless", include_offline=false)
```

**Find bandwidth hogs:**
```
"Who's using the most bandwidth today?"
→ unifi_get_top_clients(duration="daily", limit=10)
```

**Check network health:**
```
"What's my network health status?"
→ unifi_get_network_health()
```

### Device Management

**List all access points:**
```
"Show me all my WiFi access points"
→ unifi_list_devices(device_type="uap", status="all")
```

**Check device details:**
```
"Get details for device with MAC XX:XX:XX:XX:XX:XX"
→ unifi_get_device_details(mac_address="XX:XX:XX:XX:XX:XX")
```

**Reboot problematic AP:**
```
"Reboot the access point at XX:XX:XX:XX:XX:XX"
→ unifi_reboot_device(mac_address="XX:XX:XX:XX:XX:XX", confirm=true)
```

### Security Management

**List firewall rules:**
```
"Show all my firewall rules"
→ unifi_list_firewall_policies(include_predefined=false)
```

**Block suspicious device:**
```
"Block device with MAC XX:XX:XX:XX:XX:XX"
→ unifi_block_client(mac_address="XX:XX:XX:XX:XX:XX", confirm=true)
```

**Create firewall rule:**
```
"Create a firewall rule to block port 22 from WAN"
→ unifi_create_simple_firewall_policy({
  rule: {
    name: "Block SSH from WAN",
    action: "drop",
    protocol: "tcp",
    dst_port: 22,
    src_zone: "WAN"
  },
  confirm: true
})
```

### Guest Network

**Authorize guest for 4 hours:**
```
"Give guest device XX:XX:XX:XX:XX:XX internet access for 4 hours"
→ unifi_authorize_guest(
  mac_address="XX:XX:XX:XX:XX:XX",
  minutes=240,
  down_kbps=10000,  // 10 Mbps
  up_kbps=5000      // 5 Mbps
)
```

### Statistics & Reporting

**Get DPI statistics:**
```
"What applications are being used on my network?"
→ unifi_get_dpi_stats()
```

**Device usage report:**
```
"Show me usage stats for device XX:XX:XX:XX:XX:XX over the past week"
→ unifi_get_client_stats(client_id="XX:XX:XX:XX:XX:XX", duration="weekly")
```

---

## Logging

### Log Location
```
~/Library/Logs/Claude/mcp-server-unifi-network-readonly.log
```

### View Real-Time Logs
```bash
tail -f ~/Library/Logs/Claude/mcp-server-unifi-network-readonly.log
```

### Healthy Log Output
```
INFO:mcp.server.lowlevel.server:Processing request of type ListToolsRequest
Message from server: {"result":{"tools":[{"name":"unifi_list_clients",...
Server connected successfully
```

### Unhealthy Log Output
```
ERROR: Failed to connect to UniFi controller
omegaconf.errors.ConfigAttributeError: Missing key unifi
Connection refused
```

---

## Performance Notes

### Rate Limiting

The UniFi controller has built-in rate limiting:
- Too many rapid requests may result in temporary blocks
- Recommend: Space requests 1-2 seconds apart
- Batch operations when possible

### Response Times

Typical response times:
- List operations: 500ms - 2s
- Get details: 200ms - 1s
- Modifications: 1s - 5s
- Statistics: 1s - 3s

Large networks (100+ devices) may see longer response times.

---

## Security Considerations

### Credentials in Environment

Credentials are stored in:
1. `config.yaml` (file permissions: 600)
2. Claude Desktop config (user-accessible)

**Best Practice:**
- Limit Claude Desktop access to trusted users
- Use a dedicated UniFi user with limited permissions
- Enable audit logging on UniFi controller

### SSL Verification

Current setup disables SSL verification (`verify_ssl: false`):
- Acceptable for local network (192.168.3.1)
- **Do NOT disable for remote connections**
- Consider using valid certificates for production

### Network Exposure

- MCP server runs locally (no network exposure)
- Only Claude Desktop can access the server
- UniFi controller connection is direct (no proxy)

---

## Maintenance

### Update Configuration

After editing config.yaml:
```bash
# Restart Claude Desktop (no manual commands needed)
```

### Check Server Status
```bash
# View recent log entries
tail -20 ~/Library/Logs/Claude/mcp-server-unifi-network-readonly.log

# Check if connected
grep "Server connected successfully" ~/Library/Logs/Claude/mcp-server-unifi-network-readonly.log | tail -1
```

### Verify Python Environment
```bash
# Check if executable exists
ls -lah /Users/ealwais/unifi-mcp-readonly/venv/bin/unifi-network-mcp

# Check Python version
/Users/ealwais/unifi-mcp-readonly/venv/bin/python --version
```

---

## Version History

### v0.1.3 (Current)
- **Status:** ✅ Operational
- **Fixed:** Added missing `unifi:` configuration section (Oct 3, 2025)
- **Tools:** 60+ available
- **Connected:** 192.168.3.1 (UniFi Dream Machine)

---

## Support Resources

### Documentation
- **Local Config:** `/Users/ealwais/unifi-mcp-readonly/config/config.yaml`
- **UniFi Controller:** https://192.168.3.1
- **MCP Protocol:** https://modelcontextprotocol.io

### Logs
- **Server Log:** `~/Library/Logs/Claude/mcp-server-unifi-network-readonly.log`
- **Main MCP Log:** `~/Library/Logs/Claude/mcp.log`

### UniFi Controller Access
- **Web UI:** https://192.168.3.1
- **Local Access:** Direct LAN connection
- **Username:** emalwais

---

**Quick Health Check:**
```bash
# Is server configured?
cat /Users/ealwais/unifi-mcp-readonly/config/config.yaml | grep "host:"

# Is server responding?
tail -3 ~/Library/Logs/Claude/mcp-server-unifi-network-readonly.log

# Test connection
curl -k https://192.168.3.1
```

**Expected:**
- Config shows `host: "192.168.3.1"`
- Logs show "Server connected successfully"
- Curl shows UniFi controller response

---

**Last Updated:** October 3, 2025
**Maintainer:** Eric Alwais
**Status:** ✅ Connected & Operational
