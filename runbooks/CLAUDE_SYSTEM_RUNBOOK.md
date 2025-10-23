# Claude System Operations Runbook

**Purpose:** Complete guide to understanding and using your Claude setup
**Audience:** You (future reference) and anyone maintaining this system
**Last Updated:** October 22, 2025

---

## 📚 Table of Contents

1. [Quick Start](#quick-start)
2. [System Overview](#system-overview)
3. [Daily Operations](#daily-operations)
4. [MCP Servers](#mcp-servers)
5. [Extensions](#extensions)
6. [Common Tasks](#common-tasks)
7. [Troubleshooting](#troubleshooting)
8. [Emergency Procedures](#emergency-procedures)
9. [Examples](#examples)

---

## 🚀 Quick Start

### First Time Setup
**Already done!** Your system is fully configured. Skip to [Daily Operations](#daily-operations).

### What You Have
- **29 connectors** (20 MCP servers + 9 extensions)
- **300+ tools** across all systems
- **Full automation** for home, network, media, and productivity

### How to Use
Just talk to Claude naturally! Examples:
```
"Show me all devices on my UniFi network"
"What's on TV right now?"
"Send an iMessage to John saying I'm running late"
"Create a PayPal invoice for $500"
```

---

## 🎯 System Overview

### What is MCP?
**Model Context Protocol (MCP)** = A way for Claude to connect to external tools and services.

Think of it like this:
- **Claude** = Your brain
- **MCP Servers** = Your hands (do things in the real world)
- **Extensions** = Built-in superpowers
- **Tools** = Individual actions you can take

### The 28 Connectors

#### Home & Network (4)
1. **Home Assistant** - Control 100+ smart devices
2. **UniFi Network** - Manage your entire network
3. **Media Stack** - Plex, Sonarr, Radarr
4. **Cloudflare DNS** - DNS analytics

#### Productivity & Communication (8)
5. **iMessages** - Send/receive texts
6. **Apple Notes** - Create/read notes
7. **Things** - Task management
8. **Gmail** - Email management
9. **Google Calendar** - Schedule management
10. **Google Drive** - File storage
11. **PayPal** - Create invoices
12. **1Password** - Access passwords

#### Browser & System (7)
13. **Control Chrome** - Automate Chrome
14. **Brave Browser** - Automate Brave
15. **Chrome DevTools** - Debug websites
16. **Puppeteer** - Web automation
17. **Desktop Commander** - Control your Mac
18. **Control your Mac** - AppleScript automation
19. **PDF Tools** - Work with PDFs

#### AI & Knowledge (4)
20. **Sequential Thinking** - Multi-step reasoning
21. **Memory** - Remember things long-term
22. **Context7** - Look up documentation
23. **Time** - Time zone utilities

#### File & System (3)
24. **Filesystem** - Read/write files
25. **Desktop Commander** - System control
26. **Monarch Money** - Finance (disabled for now)

---

## 📅 Daily Operations

### Starting Your Day
```
"What meetings do I have today?"
"Show me my Things tasks for today"
"Any important emails in Gmail?"
```

### Home Automation
```
"Turn off all the lights"
"What's the temperature in the bedroom?"
"Show me which devices are offline"
```

### Network Management
```
"Show all connected devices"
"Who's using the most bandwidth?"
"Block device XX:XX:XX:XX:XX:XX"
```

### Media & Entertainment
```
"What's on TV now?"
"Show me Plex server status"
"What's downloading in Sonarr?"
```

---

## 🔧 MCP Servers

### What Are They?
MCP Servers are programs that run locally and connect Claude to external services.

### Where Are They Configured?
**File:** `~/Library/Application Support/Claude/claude_desktop_config.json`

### How to See Them
```bash
# View config
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | jq

# View logs
tail -f ~/Library/Logs/Claude/mcp.log

# Check specific server
tail -f ~/Library/Logs/Claude/mcp-server-hass-mcp.log
```

### The 19 MCP Servers

#### Server List
1. **hass-mcp** - Home Assistant
2. **unifi-network-readonly** - UniFi
3. **media-stack** - Plex ecosystem
4. **1password** - Passwords
5. **gdrive-alwais** - Google Drive
6. **gmail-mcp** - Gmail
7. **google-calendar-mcp** - Calendar
8. **imessage** - Messages
9. **chrome-devtools** - Chrome tools
10. **puppeteer** - Web automation
11. **desktop-commander** - Mac control
12. **filesystem** - File operations
13. **sequential-thinking** - AI reasoning
14. **memory** - Long-term memory
15. **context7** - Documentation
16. **time** - Time utilities
17. **cloudflare-dns** - DNS analytics
18. **paypal** - Invoicing
19. **monarch-money** - Finance (disabled)

---

## 🎨 Extensions

### What Are They?
Built-in capabilities that Claude Desktop provides natively. No external server needed.

### Where Are They?
**Location:** `~/Library/Application Support/Claude/Claude Extensions/`
**Settings:** `~/Library/Application Support/Claude/Claude Extensions Settings/`

### The 9 Active Extensions

1. **Control Chrome** - Browser automation
2. **Apple Notes** - Notes management
3. **iMessages** - Messaging
4. **Control your Mac** - AppleScript
5. **Things** - Tasks
6. **PDF Tools** - PDF operations
7. **Brave Browser** - Browser control
8. **Desktop Commander** - System control
9. **Context7** - Documentation

### How to Enable/Disable
Extensions are managed through Claude Desktop UI - no manual config needed.

---

## 🛠️ Common Tasks

### Task 1: Check System Status

**What to do:**
```
"Show me the Home Assistant server status"
"What's the Plex server status?"
"Check network device status"
```

**Manual check:**
```bash
# View all MCP server logs
tail -f ~/Library/Logs/Claude/mcp.log

# Check specific service
curl http://192.168.3.11:8089/status | jq
```

---

### Task 2: Control Smart Home

**Common commands:**
```
"Turn off living room lights"
"Set bedroom temperature to 72"
"Show me all offline Zigbee devices"
"What's the current temperature in the house?"
```

**Behind the scenes:**
- Uses **hass-mcp** server
- Connects to Home Assistant at 192.168.3.20:8123
- 100+ tools available

---

### Task 3: Manage Network

**Common commands:**
```
"Show all devices on my network"
"What are the top 10 bandwidth users?"
"Block device with MAC address XX:XX:XX:XX:XX:XX"
"Show my Cloudflare DNS settings"
```

**Behind the scenes:**
- Uses **unifi-network-readonly** (60+ tools)
- Uses **cloudflare-dns** (4 tools)
- Read-only by default, requires confirmation for changes

---

### Task 4: Media Management

**Common commands:**
```
"What's on TV right now?"
"Show me recordings from last week"
"Search for The Office"
"What's in the Sonarr queue?"
```

**Behind the scenes:**
- Uses **media-stack** server
- Connects to services at 192.168.3.11

---

### Task 5: Send Messages

**Common commands:**
```
"Send iMessage to John: Running 10 minutes late"
"Read my recent iMessages"
"Send email to team@example.com"
```

**Behind the scenes:**
- Uses **imessage** MCP server
- Uses **Read and Send iMessages** extension
- Uses **gmail-mcp** for email

---

### Task 6: Productivity

**Common commands:**
```
"Create a note in Apple Notes with today's meeting summary"
"Add task to Things: Review MCP servers"
"What's on my calendar tomorrow?"
"Create PayPal invoice for client@example.com for $500"
```

**Behind the scenes:**
- Uses **Apple Notes** extension
- Uses **Things** extension
- Uses **google-calendar-mcp** server
- Uses **paypal** server

---

### Task 7: File Operations

**Common commands:**
```
"Read the file at /Users/ealwais/Desktop/report.txt"
"List all markdown files in /mnt/docker/documentation"
"Create a new directory at /Users/ealwais/projects/new-app"
```

**Behind the scenes:**
- Uses **filesystem** MCP server
- Access to `/Users/ealwais` and `/Volumes/docker`

---

### Task 8: Web Automation

**Common commands:**
```
"Navigate to example.com in Chrome and take a screenshot"
"Fill out the login form with my credentials"
"Run a performance test on this page"
```

**Behind the scenes:**
- Uses **chrome-devtools** MCP
- Uses **Control Chrome** extension
- Uses **puppeteer** MCP

---

## 🔥 Troubleshooting

### Problem: MCP Server Not Working

**Symptoms:**
- "Tool not available" error
- Server not responding
- Missing capabilities

**Solution:**
```bash
# 1. Check if server is running
tail -f ~/Library/Logs/Claude/mcp-server-<name>.log

# 2. Restart Claude Desktop
# Quit and reopen the app

# 3. Check config
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | jq

# 4. Test manually (for HTTP servers)
curl http://localhost:8089/status
```

---

### Problem: Authentication Failed

**Symptoms:**
- "Not authenticated" error
- OAuth redirect not working
- API key invalid

**Solution:**

**For OAuth servers (Cloudflare, Google):**
1. Quit Claude Desktop
2. Delete old tokens:
   ```bash
   rm ~/.config/gmail-mcp/tokens.json
   rm ~/.config/google-calendar-mcp/tokens.json
   ```
3. Restart Claude Desktop
4. Browser will open for re-auth

**For API key servers (Home Assistant, UniFi):**
1. Check token in config file
2. Verify token is still valid
3. Generate new token if expired
4. Update config and restart

---

### Problem: Extension Not Loading

**Symptoms:**
- Extension capabilities missing
- "Extension not found" error

**Solution:**
```bash
# 1. Check extension settings
cat ~/Library/Application\ Support/Claude/Claude\ Extensions\ Settings/<extension>.json

# 2. Verify extension is enabled
# Should show: {"isEnabled": true}

# 3. Reinstall extension
# Through Claude Desktop UI: Extensions → Reinstall

# 4. Check logs
tail -f ~/Library/Logs/Claude/main.log | grep -i extension
```

---

### Problem: High Memory Usage

**Symptoms:**
- Claude Desktop using lots of RAM
- System slow

**Solution:**
```bash
# 1. Check which servers are using memory
ps aux | grep -E "node|python|uvx" | grep -v grep

# 2. Check running containers
docker ps -a

# 3. Restart Claude Desktop to clear cache

# 4. Disable unused servers in config
```

---

### Problem: Cannot Connect to Local Service

**Symptoms:**
- "Connection refused" error
- Timeout errors

**Solution:**
```bash
# 1. Check if service is running
curl http://192.168.3.11:8089/status

# 2. Check network connectivity
ping 192.168.3.11

# 3. Verify port
netstat -an | grep 8089

# 4. Check firewall
# UniFi firewall rules might be blocking
```

---

## 🚨 Emergency Procedures

### Emergency 1: System Completely Broken

**What to do:**
```bash
# 1. Restore from backup
cp ~/Library/Application\ Support/Claude/claude_desktop_config.json.backup \
   ~/Library/Application\ Support/Claude/claude_desktop_config.json

# 2. Restart Claude Desktop

# 3. Check logs
tail -f ~/Library/Logs/Claude/mcp.log

# 4. If still broken, use archived config
cp ~/Library/Application\ Support/Claude/_archived_configs/claude_desktop_config_all_servers_20251020_132648.json \
   ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

---

### Emergency 2: Lost All Backups

**What to do:**
```bash
# 1. Recreate minimal config
cat > ~/Library/Application\ Support/Claude/claude_desktop_config.json << 'EOF'
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/ealwais"]
    }
  }
}
EOF

# 2. Restart Claude Desktop

# 3. Rebuild from documentation
# See: /mnt/docker/documentation/status_reports/MCP_COMPLETE_INVENTORY.md
```

---

### Emergency 3: Cannot Start Claude Desktop

**What to do:**
```bash
# 1. Check for corrupt config
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json

# 2. Validate JSON
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | jq .

# 3. If invalid, restore backup
cp ~/Library/Application\ Support/Claude/claude_desktop_config.json.backup \
   ~/Library/Application\ Support/Claude/claude_desktop_config.json

# 4. Clear cache
rm -rf ~/Library/Application\ Support/Claude/Cache
rm -rf ~/Library/Application\ Support/Claude/Code\ Cache

# 5. Restart
```

---

## 💡 Examples

### Example 1: Morning Routine

```
# Check schedule
"What's on my calendar today?"

# Check tasks
"Show me my Things tasks for today"

# Check emails
"Any important emails in Gmail from the last 24 hours?"

# Check home
"What's the temperature in the house?"

# Check network
"Any unusual network activity?"
```

---

### Example 2: Control Smart Home

```
# Turn off lights
"Turn off all living room lights"

# Set temperature
"Set bedroom thermostat to 72 degrees"

# Check status
"Show me all smart home devices that are offline"

# Create automation
"Create an automation to turn off all lights at 11 PM"
```

---

### Example 3: Network Management

```
# View devices
"Show all connected devices on my network"

# Check bandwidth
"Who are the top 5 bandwidth users right now?"

# Block device
"Block the device with MAC address XX:XX:XX:XX:XX:XX"

# Port forwarding
"Show me all active port forwarding rules"

# DNS
"What are my Cloudflare DNS settings for example.com?"
```

---

### Example 4: Media Center

```
# Plex status
"What's the Plex server status?"

# Search content
"Search for The Office in Plex"

# Downloads
"What's in the Sonarr download queue?"
"What's in the Radarr queue?"
```

---

### Example 5: Productivity Workflow

```
# Morning
"Create a note in Apple Notes: Daily Standup - [today's date]"
"Add today's tasks from Gmail to Things"

# During work
"Send iMessage to team: Meeting in 5 minutes"
"Create PayPal invoice for Client XYZ for $2,500"

# Scheduling
"What meetings do I have tomorrow?"
"Add to calendar: Team sync, tomorrow 2pm, 1 hour"

# End of day
"Create note with today's accomplishments"
"Archive all emails from today"
```

---

### Example 6: Automation & Web

```
# Web automation
"Navigate to login.example.com"
"Fill in username field with my email"
"Take a screenshot of the page"

# Testing
"Run a performance trace on example.com"
"Check the page for broken links"

# Browser control
"Open a new tab in Chrome with github.com"
"Close all tabs except the first one"
```

---

### Example 7: File Management

```
# Find files
"List all PDF files in /Users/ealwais/Documents"

# Read content
"Read the contents of /mnt/docker/documentation/README.md"

# Create structure
"Create directory /Users/ealwais/projects/new-project"
"Create subdirectories: src, tests, docs"

# Move files
"Move all .txt files from Downloads to Documents/Archive"
```

---

### Example 8: System Monitoring

```
# Check services
"Show status of all MCP servers"
"Check Home Assistant connection"
"Verify Channels DVR is responding"

# Network health
"Show UniFi network health summary"
"Check for any alerts or warnings"

# Storage
"How much space is available on the NAS?"
"What's using the most storage?"
```

---

## 📊 Understanding the Logs

### Main MCP Log
**Location:** `~/Library/Logs/Claude/mcp.log`

**What it shows:**
- Server startup/shutdown
- Tool calls
- Errors and warnings
- Connection status

**Example:**
```
2025-10-23T00:00:00.000Z [hass-mcp] [info] Initializing server...
2025-10-23T00:00:00.050Z [hass-mcp] [info] Server started and connected
```

---

### Individual Server Logs
**Location:** `~/Library/Logs/Claude/mcp-server-<name>.log`

**What it shows:**
- Server-specific activity
- API calls
- Response data
- Errors specific to that server

---

## 🔗 Reference Documentation

### Quick Links
- **System Inventory:** `/mnt/docker/documentation/status_reports/CLAUDE_COMPLETE_SYSTEM_INVENTORY.md`
- **MCP Servers:** `/mnt/docker/documentation/status_reports/MCP_SERVERS_STATUS.md`
- **Main Config:** `/mnt/docker/CLAUDE.md`
- **Plex Setup:** `/mnt/docker/documentation/services/homeassistant/PLEX_SETUP.md`

### Configuration Files
- **MCP Config:** `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Extensions:** `~/Library/Application Support/Claude/Claude Extensions Settings/`
- **Logs:** `~/Library/Logs/Claude/`

---

## 🎓 Learning More

### MCP Protocol
- Official docs: https://modelcontextprotocol.io
- Specification: https://spec.modelcontextprotocol.io

### Claude Desktop
- Help: Type `/help` in Claude Desktop
- Feedback: https://github.com/anthropics/claude-code/issues

### Your Setup
- All documentation in `/mnt/docker/documentation/`
- Status reports in `/mnt/docker/documentation/status_reports/`
- Service docs in `/mnt/docker/documentation/services/`

---

**Remember:** You have 300+ tools at your fingertips. Just ask naturally and Claude will use the right tool!

**Last Updated:** October 22, 2025
**Version:** 1.0
**Status:** All systems operational ✅
