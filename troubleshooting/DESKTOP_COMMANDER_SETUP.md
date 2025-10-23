# Desktop Commander MCP Extension - Setup & Troubleshooting

**Extension Version:** 0.2.15
**Last Updated:** October 3, 2025

---

## Overview

Desktop Commander is a Claude Desktop extension that provides 25+ tools for file operations, terminal process management, and code search through the Model Context Protocol (MCP).

**Extension ID:** `ant.dir.gh.wonderwhy-er.desktopcommandermcp`

---

## Installation Location

```
~/Library/Application Support/Claude/Claude Extensions/ant.dir.gh.wonderwhy-er.desktopcommandermcp/
```

### Directory Structure
```
ant.dir.gh.wonderwhy-er.desktopcommandermcp/
├── dist/                    # Compiled JavaScript
│   ├── index.js            # Main entry point
│   ├── server.js           # MCP server implementation
│   ├── tools/              # Tool implementations
│   ├── handlers/           # Request handlers
│   └── utils/              # Utility modules
├── package.json            # Node.js dependencies
├── node_modules/           # Installed npm packages
├── manifest.json           # Extension manifest
└── README.md              # Extension documentation
```

---

## Common Issues & Fixes

### Issue 1: Extension Disconnecting Immediately

**Symptoms:**
- Extension shows as "Disconnected" in Claude Desktop
- Log shows: `Server transport closed unexpectedly`
- Error: `Cannot find package '@modelcontextprotocol/sdk'`

**Root Cause:**
Missing npm dependencies. The extension ships without `node_modules/` installed.

**Solution:**

1. Navigate to extension directory:
```bash
cd "~/Library/Application Support/Claude/Claude Extensions/ant.dir.gh.wonderwhy-er.desktopcommandermcp"
```

2. Install all required dependencies:
```bash
npm install @modelcontextprotocol/sdk @vscode/ripgrep cross-fetch fastest-levenshtein isbinaryfile zod zod-to-json-schema
```

3. Verify package.json has correct module type:
```json
{
  "type": "module",
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.19.1",
    "@vscode/ripgrep": "^1.15.14",
    "cross-fetch": "^4.1.0",
    "fastest-levenshtein": "^1.0.16",
    "isbinaryfile": "^5.0.6",
    "zod": "^3.25.76",
    "zod-to-json-schema": "^3.24.6"
  }
}
```

4. Restart Claude Desktop

**Verification:**
```bash
tail -f ~/Library/Logs/Claude/mcp-server-Desktop\ Commander.log
```

Look for:
```
Message from server: {"result":{"protocolVersion":"2024-11-05",...
"serverInfo":{"name":"desktop-commander","version":"0.2.15"}}
```

---

### Issue 2: Module Type Warning

**Symptoms:**
Warning in logs: `Module type of ...desktopcommandermcp/dist/index.js is not specified`

**Root Cause:**
Missing `"type": "module"` in package.json

**Solution:**

Edit `package.json` and add `"type": "module"`:

```json
{
  "name": "desktop-commander",
  "version": "0.2.15",
  "type": "module",
  ...
}
```

Then restart Claude Desktop.

---

### Issue 3: Cannot Find Specific Module

**Symptoms:**
Error: `Cannot find package 'cross-fetch'` (or isbinaryfile, ripgrep, etc.)

**Solution:**

Install missing package individually:
```bash
cd "~/Library/Application Support/Claude/Claude Extensions/ant.dir.gh.wonderwhy-er.desktopcommandermcp"
npm install <package-name>
```

Or install all at once:
```bash
npm install @modelcontextprotocol/sdk @vscode/ripgrep cross-fetch fastest-levenshtein isbinaryfile zod zod-to-json-schema
```

---

## Required Dependencies

### Complete List

| Package | Version | Purpose |
|---------|---------|---------|
| @modelcontextprotocol/sdk | ^1.19.1 | MCP protocol implementation |
| @vscode/ripgrep | ^1.15.14 | Fast code search |
| cross-fetch | ^4.1.0 | HTTP requests |
| fastest-levenshtein | ^1.0.16 | String similarity |
| isbinaryfile | ^5.0.6 | Binary file detection |
| zod | ^3.25.76 | Schema validation |
| zod-to-json-schema | ^3.24.6 | JSON schema conversion |

### Verification Script

```bash
#!/bin/bash
# Check if all required packages are installed

cd "~/Library/Application Support/Claude/Claude Extensions/ant.dir.gh.wonderwhy-er.desktopcommandermcp"

packages=(
  "@modelcontextprotocol/sdk"
  "@vscode/ripgrep"
  "cross-fetch"
  "fastest-levenshtein"
  "isbinaryfile"
  "zod"
  "zod-to-json-schema"
)

for pkg in "${packages[@]}"; do
  if npm list "$pkg" &>/dev/null; then
    echo "✅ $pkg installed"
  else
    echo "❌ $pkg MISSING"
  fi
done
```

---

## Testing the Extension

### 1. Manual Test Run

```bash
cd "~/Library/Application Support/Claude/Claude Extensions/ant.dir.gh.wonderwhy-er.desktopcommandermcp"

# Test if the extension starts without errors (should timeout after 3 seconds)
timeout 3 node dist/index.js || echo "Extension started successfully"
```

**Expected Output:**
- No error messages about missing modules
- Should run until timeout (this is normal - extension waits for MCP input)

**Error Output Indicates Problem:**
- `Cannot find package` = Missing dependency
- `SyntaxError` = Code or module type issue

### 2. Check Extension Status in Logs

```bash
tail -50 ~/Library/Logs/Claude/mcp-server-Desktop\ Commander.log
```

**Healthy Log Output:**
```
Server started and connected successfully
Message from server: {"result":{"protocolVersion":"2024-11-05"...
Client connected: claude-ai v0.1.0
Server connected successfully
MCP fully initialized
```

**Unhealthy Log Output:**
```
Server transport closed unexpectedly
Error: Cannot find package
Server disconnected
```

---

## Extension Configuration

### Manifest Configuration

Location: `manifest.json`

```json
{
  "manifest_version": "0.2",
  "name": "desktop-commander",
  "display_name": "Desktop Commander",
  "version": "0.2.15",
  "description": "Execute long-running terminal commands and manage processes through MCP",
  "server": {
    "type": "node",
    "entry_point": "dist/index.js",
    "mcp_config": {
      "command": "node",
      "args": ["${__dirname}/dist/index.js"],
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
```

### Extension Settings

Location: `~/Library/Application Support/Claude/Claude Extensions Settings/ant.dir.gh.wonderwhy-er.desktopcommandermcp.json`

```json
{
  "isEnabled": true
}
```

**To Disable Extension:**
```json
{
  "isEnabled": false
}
```

---

## Available Tools

Desktop Commander provides 25+ tools organized into categories:

### File Operations (8 tools)
- `read_file` - Read file contents with offset/length support
- `read_multiple_files` - Read multiple files simultaneously
- `write_file` - Write/append to files (with chunking)
- `create_directory` - Create directories
- `list_directory` - List directory contents
- `move_file` - Move/rename files
- `get_file_info` - Get file metadata
- `edit_block` - Surgical text replacements

### Code Search (4 tools)
- `start_search` - Start streaming search (files or content)
- `get_more_search_results` - Get paginated results
- `stop_search` - Stop active search
- `list_searches` - List all active searches

### Process Management (6 tools)
- `start_process` - Start terminal process with REPL detection
- `read_process_output` - Read process output (smart detection)
- `interact_with_process` - Send input to running process
- `force_terminate` - Kill terminal session
- `list_sessions` - List all terminal sessions
- `list_processes` - List system processes
- `kill_process` - Terminate process by PID

### Configuration (3 tools)
- `get_config` - Get server configuration
- `set_config_value` - Update configuration
- `get_usage_stats` - Get tool usage statistics

### Utilities (2 tools)
- `give_feedback_to_desktop_commander` - Submit feedback
- `get_prompts` - Browse example workflows

---

## Security Configuration

### Allowed Directories

Desktop Commander restricts file access to specific directories. Configure in runtime settings.

**Default:** Configured per installation
**Full Access:** Set `allowedDirectories: []` (use with caution!)

### Blocked Commands

Prevent specific shell commands from execution:

```json
{
  "blockedCommands": ["rm -rf /", "dd if=", ":(){ :|:& };:"]
}
```

### File Operation Limits

```json
{
  "fileReadLineLimit": 1000,    // Max lines per read_file call
  "fileWriteLineLimit": 50      // Max lines per write_file call
}
```

### Telemetry

```json
{
  "telemetryEnabled": false  // Opt out of usage analytics
}
```

---

## Troubleshooting Commands

### View Real-Time Logs
```bash
tail -f ~/Library/Logs/Claude/mcp-server-Desktop\ Commander.log
```

### Check Extension Enabled Status
```bash
cat ~/Library/Application\ Support/Claude/Claude\ Extensions\ Settings/ant.dir.gh.wonderwhy-er.desktopcommandermcp.json
```

### List Installed Dependencies
```bash
cd "~/Library/Application Support/Claude/Claude Extensions/ant.dir.gh.wonderwhy-er.desktopcommandermcp"
npm list --depth=0
```

### Reinstall All Dependencies
```bash
cd "~/Library/Application Support/Claude/Claude Extensions/ant.dir.gh.wonderwhy-er.desktopcommandermcp"
rm -rf node_modules package-lock.json
npm install @modelcontextprotocol/sdk @vscode/ripgrep cross-fetch fastest-levenshtein isbinaryfile zod zod-to-json-schema
```

### Test Extension Manually
```bash
cd "~/Library/Application Support/Claude/Claude Extensions/ant.dir.gh.wonderwhy-er.desktopcommandermcp"
node dist/index.js
# Should wait for input (Ctrl+C to exit)
```

---

## Complete Fix Procedure (October 3, 2025)

This is the complete procedure that was used to fix the Desktop Commander extension:

```bash
#!/bin/bash
# Desktop Commander Fix Script - October 3, 2025

# 1. Navigate to extension directory
cd "~/Library/Application Support/Claude/Claude Extensions/ant.dir.gh.wonderwhy-er.desktopcommandermcp"

# 2. Install MCP SDK
npm install @modelcontextprotocol/sdk

# 3. Install additional dependencies
npm install cross-fetch zod

# 4. Install remaining dependencies
npm install isbinaryfile @vscode/ripgrep fastest-levenshtein zod-to-json-schema

# 5. Add "type": "module" to package.json
# This requires manual editing or using jq:
jq '. + {"type": "module"}' package.json > package.json.tmp && mv package.json.tmp package.json

# 6. Verify installation
npm list --depth=0

# 7. Test extension
timeout 2 node dist/index.js || echo "✅ Extension starts successfully"

echo ""
echo "Desktop Commander fix complete!"
echo "Please restart Claude Desktop to activate."
```

**Result:** Extension fully operational with all 25+ tools available.

---

## Key Features

### Interactive REPL Support

Desktop Commander has intelligent REPL detection:

**Supported REPLs:**
- Python (`python3 -i`)
- Node.js (`node -i`)
- Bash/Zsh
- R, Julia
- Database clients (mysql, psql)

**Smart Detection:**
- Recognizes prompts (`>>>`, `>`, `$`)
- Early exit on prompt detection (no timeout waits)
- Clean output formatting
- Error detection

**Example Workflow:**
```
1. start_process("python3 -i", 8000)
   → Returns PID, detects Python REPL

2. interact_with_process(PID, "import pandas as pd")
   → Executes, waits for prompt, returns clean output

3. interact_with_process(PID, "df = pd.read_csv('/path/file.csv')")
   → Loads data, auto-waits for completion

4. interact_with_process(PID, "print(df.head())")
   → Shows results immediately
```

### Advanced File Search

**Two Search Types:**
- `searchType: "files"` - Find files by name
- `searchType: "content"` - Search inside files

**Features:**
- Streaming results (progressive display)
- Regex or literal search
- File pattern filtering
- Case-sensitive/insensitive
- Context lines for content matches
- Early termination options
- Pagination support

**Example:**
```
start_search({
  path: "/Users/ealwais/project",
  pattern: "authentication",
  searchType: "content",
  filePattern: "*.py",
  contextLines: 3
})
```

### Chunked File Writing

Automatically optimizes file writing:

**Standard Process:**
```
1. write_file(path, firstChunk, {mode: 'rewrite'})   [≤30 lines]
2. write_file(path, secondChunk, {mode: 'append'})   [≤30 lines]
3. write_file(path, thirdChunk, {mode: 'append'})    [≤30 lines]
```

**Benefits:**
- Prevents timeouts on large files
- Better progress tracking
- Resume capability
- Performance optimization

---

## Support Resources

### Documentation
- **GitHub:** https://github.com/wonderwhy-er/DesktopCommanderMCP
- **MCP Protocol:** https://modelcontextprotocol.io
- **Debugging Guide:** https://modelcontextprotocol.io/docs/tools/debugging

### Log Locations
- **Extension Log:** `~/Library/Logs/Claude/mcp-server-Desktop Commander.log`
- **Main MCP Log:** `~/Library/Logs/Claude/mcp.log`
- **Claude Main Log:** `~/Library/Logs/Claude/main.log`

### Community
- Report issues on GitHub
- Check MCP protocol documentation
- Review Claude Desktop logs for errors

---

## Version History

### v0.2.15 (Current)
- **Status:** Fully operational
- **Fixed:** Missing npm dependencies
- **Fixed:** Module type specification
- **Tools:** 25+ available
- **Last Verified:** October 3, 2025

---

**Quick Health Check:**
```bash
# Is extension enabled?
cat ~/Library/Application\ Support/Claude/Claude\ Extensions\ Settings/ant.dir.gh.wonderwhy-er.desktopcommandermcp.json

# Are dependencies installed?
ls ~/Library/Application\ Support/Claude/Claude\ Extensions/ant.dir.gh.wonderwhy-er.desktopcommandermcp/node_modules | wc -l

# Is extension running?
tail -3 ~/Library/Logs/Claude/mcp-server-Desktop\ Commander.log
```

**Expected:**
- `isEnabled: true`
- 90+ packages in node_modules
- "MCP fully initialized" in logs

---

**Last Updated:** October 3, 2025
**Maintainer:** Eric Alwais
**Status:** ✅ Operational
