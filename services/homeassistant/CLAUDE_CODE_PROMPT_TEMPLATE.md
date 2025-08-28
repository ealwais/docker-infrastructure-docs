# Claude Code Prompt Template for Home Assistant

## Recommended Starting Prompt

Use this template when starting a new Claude Code session for Home Assistant work:

---

**PROMPT TEMPLATE:**

```
I need help with my Home Assistant setup. Please start by reading the documentation in the /mnt/docker/homeassistant/docs/ directory, particularly:

1. docs/README.md - Main documentation index
2. docs/CURRENT_STATUS.md - Current system state and issues
3. docs/setup/INTEGRATIONS_GUIDE.md - Integration configurations
4. configuration.yaml - Current configuration
5. secrets.yaml - API keys and credentials (handle securely)

After reading, please:
1. Verify which information is still accurate by checking the actual files and system state
2. Update any outdated information in the documentation
3. Comment out or mark deprecated sections with "⚠️ MAY BE OUTDATED - VERIFY"
4. Add "✅ VERIFIED [date]" to confirmed accurate sections
5. Create a summary of what needs to be fixed or updated

My current goal is: [DESCRIBE YOUR SPECIFIC TASK HERE]

Please use the existing documentation as reference but verify everything against the actual system state before making changes.
```

---

## Enhanced Prompts for Specific Tasks

### For System Health Check:
```
Please perform a health check of my Home Assistant system:
1. Read docs/CURRENT_STATUS.md
2. Check if the listed issues are still present
3. Verify all services are running: docker ps
4. Check for errors in logs: docker logs homeassistant | tail -50
5. Update the CURRENT_STATUS.md with findings
6. Mark fixed issues as "✅ RESOLVED [date]"
```

### For Integration Work:
```
I need to work on Home Assistant integrations:
1. Read docs/setup/INTEGRATIONS_GUIDE.md
2. Check which integrations are actually installed vs documented
3. Verify API keys in secrets.yaml are being used
4. Test connectivity to external services
5. Update documentation with current state
6. Flag any non-working integrations
```

### For Dashboard Fixes:
```
Help me fix Home Assistant dashboards:
1. Read docs/troubleshooting/DASHBOARD_ISSUES.md
2. Check if the sync issue still exists
3. Compare dashboard files between host and container
4. Test the suggested fixes
5. Document what actually works
6. Update troubleshooting guide with results
```

## Documentation Update Conventions

When Claude Code updates documentation, it should use these markers:

### Status Markers
- `✅ VERIFIED [YYYY-MM-DD]` - Information confirmed accurate
- `⚠️ NEEDS VERIFICATION` - Unsure if still accurate
- `❌ OUTDATED` - Confirmed no longer accurate
- `🔄 UPDATED [YYYY-MM-DD]` - Information was corrected
- `📝 TODO` - Needs investigation or action

### Example Updates
```markdown
## Docker Containers
| Service | Status | Port | Notes |
|---------|--------|------|-------|
| homeassistant | ✅ Running | 8123 | ✅ VERIFIED 2025-08-12 |
| homeassistant-mcp | ⚠️ Unhealthy | 3000 | ⚠️ NEEDS VERIFICATION - health check fails but service works |
| matter-server | ❌ OUTDATED | - | 🔄 UPDATED 2025-08-12: No longer used, removed from docker-compose |
```

### Commenting Out Outdated Sections
```markdown
<!-- ❌ OUTDATED 2025-08-12: This method no longer works
### Old Method
1. Step 1
2. Step 2
-->

### New Method 🔄 UPDATED 2025-08-12
1. New Step 1
2. New Step 2
```

## Best Practices for Claude Code

### 1. Always Verify First
- Don't trust documentation blindly
- Check actual file contents
- Test commands before documenting
- Verify services are actually running

### 2. Update Incrementally
- Make small, verifiable changes
- Test each change
- Update documentation immediately
- Keep a changelog of updates

### 3. Preserve History
- Don't delete old information, mark it outdated
- Keep notes about why something changed
- Date all updates
- Maintain audit trail

### 4. Handle Secrets Carefully
- Never display full API keys or passwords
- Reference secrets.yaml entries by name
- Mask sensitive data in outputs
- Note when credentials were last verified

## Quick Reference Commands

Claude Code should know these commands for verification:

```bash
# Check system state
docker ps
docker logs homeassistant | tail -100
docker exec homeassistant ha core info

# Verify files
ls -la /mnt/docker/homeassistant/
docker exec homeassistant ls -la /config/

# Test integrations
docker exec homeassistant curl -s http://localhost:8123/api/config/core/check_config

# Check for differences
diff <(cat file) <(docker exec homeassistant cat /config/file)
```

## Documentation Files Priority

When updating, focus on these files in order:
1. `CURRENT_STATUS.md` - Most important, keep always current
2. `INTEGRATIONS_GUIDE.md` - Critical for functionality
3. `DASHBOARD_ISSUES.md` - If working on UI problems
4. `BACKUP_AND_RESTORE.md` - Update if backup procedures change
5. Other guides as needed

## Remember
- The documentation is a living reference
- Always verify before trusting
- Update documentation as you work
- Future Claude Code sessions will rely on your updates