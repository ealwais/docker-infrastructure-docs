─[ealwais@MacMini]─[~]
└─$ >....
```

---

## 4. NEXT STEPS

- [ ] Move Monarch Money credentials to 1Password
- [ ] Move Google Drive OAuth to 1Password
- [ ] Set up auto-start LaunchAgent for Claude Desktop on reboot
- [ ] Test remaining MCP servers (gdrive, gmail, calendar, etc.)
- [ ] Set up restart handling for offline services

---

## 5. RESTART PERSISTENCE

**Current Status:** Claude Desktop should auto-start via LaunchAgent
- LaunchAgent file: `/Users/ealwais/Library/LaunchAgents/com.anthropic.claudefordesktop.startup.plist`
- Verify with: `launchctl list | grep claude`

EOF

cat ~/MCP_SERVER_DOCUMENTATION.md
# MCP SERVER DOCUMENTATION
**Generated:** October 20, 2025
**System:** MacMini (192.168.3.20)
**MacOS:** 15.6 (Build 24G84)
**Claude Desktop:** Active

---

## 1. ACTIVE MCP SERVERS (18 Total)

### ✅ VERIFIED WORKING

| Server | Type | Status | Notes |
|--------|------|--------|-------|
| 1password | Python venv | ✅ WORKING | Service account token updated, accessing 'eric' vault (352 items) |
| filesystem | npx | ✅ WORKING | Official Anthropic, access to /Users/ealwais, /Volumes/docker |
| sequential-thinking | npx | ✅ WORKING | Official Anthropic |
| memory | npx | ✅ WORKING | Official Anthropic |
| desktop-commander | Node | ✅ WORKING | Community, full system access |
| channels-dvr | Node custom | ✅ WORKING | Channels DVR on 192.168.3.11:8089 |
| puppeteer | npx | ✅ WORKING | Official Anthropic, browser automation |

### ⚠️ OFFLINE (But configured)

| Server | Type | Status | Notes |
|--------|------|--------|-------|
| hass-mcp | uvx | ❌ OFFLINE | Home Assistant not running |
| media-stack | Python venv | ❌ OFFLINE | Plex/Sonarr/Radarr/SABnzbd services down |
| unifi-network-readonly | Python venv | ❌ OFFLINE | UniFi controller not running |

### ✓ NOT YET TESTED

| Server | Type | Config | Notes |
|--------|------|--------|-------|
| gdrive-alwais | npx | OAuth configured | Google Drive access |
| gmail-mcp | npx | Auto-auth | Gmail access |
| google-calendar-mcp | npx | OAuth configured | Google Calendar access |
| imessage | uvx | Native | macOS Messages integration |
| chrome-devtools | npx | Browser control | Chrome/Brave automation |
| context7 | npx | Documentation tool | Context management |
| time | npx | Date/time utility | Timezone/time utilities |
| monarch-money | Shell script | Credentials in config | Personal finance (NOT in production) |

---

## 2. SECURITY STATUS

### 🔐 1Password (Primary Credential Store)
- ✅ Now working and accessible
- Vault: **eric** (352 items)
- Service Account Token: Updated Oct 20, 2025
- Recommendation: Move all credentials here from config file

### 🚨 CREDENTIALS IN CONFIG FILE (Should be moved to 1Password)
```json
"monarch-money": {
  "MONARCH_EMAIL": "alwais@gmail.com",
  "MONARCH_PASSWORD": "****",
  "MONARCH_MFA_SECRET": "****"
},
"gdrive-alwais": {
  "CLIENT_ID": "****",
  "CLIENT_SECRET": "****"
}
```

### ✅ Secure Credentials
- Google Calendar: Stored in `/Users/ealwais/.config/calendar/gcp-oauth.keys.json`
- Google Calendar MCP: Token at `/Users/ealwais/.config/google-calendar-mcp/tokens.json`

---

## 3. FILE LOCATIONS

**Active Config:**
```
/Users/ealwais/Library/Application Support/Claude/claude_desktop_config.json
```

**Backup Configs (Archived):**
```
/Users/ealwais/Library/Application Support/Claude/_archived_configs/
(31 old backup/test configs)
```

**MCP Server Code:**
```
/Users/ealwais/mcp-servers/
├── onepassword/
├── media-stack-mcp/
├── unifi-mcp-readonly/
├── desktop-commander/
├── channels-dvr-mcp/
└── (others)
```

---

## 4. NEXT STEPS

- [ ] Move Monarch Money credentials to 1Password
- [ ] Move Google Drive OAuth to 1Password
- [ ] Set up auto-start LaunchAgent for Claude Desktop on reboot
- [ ] Test remaining MCP servers (gdrive, gmail, calendar, etc.)
- [ ] Set up restart handling for offline services

---

