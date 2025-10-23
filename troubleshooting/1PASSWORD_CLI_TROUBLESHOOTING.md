# 1Password CLI Troubleshooting Guide

**Last Updated:** 2025-10-22
**Author:** ealwais (via Claude)

## Quick Reference

### Common Error Messages
- ❌ **"Signin credentials are not compatible with the provided user auth from server"**
  - **Cause:** Expired or old service account token in configuration files
  - **Fix:** Rotate the service account token and update configuration files

### Key Configuration Files
- `~/.zshrc` - Contains `OP_SERVICE_ACCOUNT_TOKEN` exports (2 locations)
- `~/.op-alias.sh` - Contains 1Password CLI aliases
- `~/.op/` - CLI cache directory

---

## Problem: "Signin credentials are not compatible" Error

### Symptoms
```bash
$ op whoami
[ERROR] Signin credentials are not compatible with the provided user auth from server

$ op vault list
[ERROR] Signin credentials are not compatible with the provided user auth from server
```

### Root Cause
You have **old/expired 1Password service account tokens** in your shell configuration files. When the CLI tries to authenticate, it uses these expired credentials.

### Solution: Update Service Account Token

#### Step 1: Rotate the Service Account Token

1. Go to 1Password web interface: https://my.1password.com
2. Navigate to your service account settings
3. Click "Rotate Token" to generate a new token
4. Copy the new token (it starts with `ops_...`)

#### Step 2: Update Configuration Files

The token needs to be updated in **TWO locations** in `~/.zshrc`:

**Location 1 - SSH Section** (around line 815-818):
```bash
# 1Password MCP environment for SSH
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    export OP_SERVICE_ACCOUNT_TOKEN="ops_YOUR_NEW_TOKEN_HERE"
fi
```

**Location 2 - Main Export** (around line 833-834):
```bash
# 1Password Service Account (no authorization popups)
export OP_SERVICE_ACCOUNT_TOKEN="ops_YOUR_NEW_TOKEN_HERE"
```

#### Step 3: Verify Alias Configuration

Check `~/.op-alias.sh` to ensure it's NOT using the old `op_no_auth` wrapper function.

**Correct Configuration:**
```bash
#!/bin/bash

# 1Password CLI Aliases - Service Account Token (No Popups!)

# When using OP_SERVICE_ACCOUNT_TOKEN, no signin needed!
# Just use op directly

# Create convenient aliases
alias opl='op item list'
alias opget='op item get'
alias opotp='op item get --otp'

# For TOTP verification
verify_totp() {
    if [ -z "$1" ]; then
        echo "Usage: verify_totp <service_name>"
        return 1
    fi
    op item get "$1" --otp
}
```

**Incorrect Configuration (DO NOT USE):**
```bash
# ❌ This wrapper function causes issues with service accounts
function op_no_auth() {
    if ! op "$@" 2>/dev/null; then
        op signin --account D6MCGKYV5BGVRI26TZTTVUQY3E > /dev/null 2>&1
        op "$@"
    fi
}
alias op='op_no_auth'  # ❌ Don't use this with service accounts
```

#### Step 4: Apply Changes

```bash
# Reload shell configuration
source ~/.zshrc

# Test the configuration
op whoami
```

**Expected Output:**
```
URL:               https://my.1password.com
Integration ID:    XXXXXXXXXXXXXXXXXXXX
User Type:         SERVICE_ACCOUNT
```

#### Step 5: Verify Vault Access

```bash
# List available vaults
op vault list

# List items in a specific vault
op item list --vault "Eric"
```

---

## Understanding Service Account Authentication

### How It Works
- Service accounts use a **token-based authentication** (not username/password)
- The token is stored in the `OP_SERVICE_ACCOUNT_TOKEN` environment variable
- No interactive signin is required when using service accounts
- The token provides access to specific vaults configured in the service account

### Why Interactive Signin Doesn't Work
```bash
# ❌ This doesn't work with service accounts
op signin --account alwais@gmail.com

# ✅ Service accounts authenticate automatically via the token
export OP_SERVICE_ACCOUNT_TOKEN="ops_..."
op whoami  # Works immediately
```

---

## Complete Reset (If All Else Fails)

If you continue to have issues after rotating the token:

### 1. Sign Out and Clear Cache
```bash
# Sign out all accounts
op signout --forget

# Clear all cached data
rm -rf ~/.op

# Clear any session files
rm -rf ~/.op/*.session
```

### 2. Remove Old Tokens from Configuration
```bash
# Edit .zshrc
vim ~/.zshrc

# Find and remove or comment out old OP_SERVICE_ACCOUNT_TOKEN lines
# Then add the new token
```

### 3. Start Fresh
```bash
# Reload configuration
source ~/.zshrc

# Verify it works
op whoami
op vault list
```

---

## Common Mistakes to Avoid

### ❌ Don't Mix Personal and Service Account Authentication
```bash
# Bad: Using both at the same time
export OP_SERVICE_ACCOUNT_TOKEN="ops_..."
op signin --account alwais@gmail.com  # This conflicts!
```

### ❌ Don't Use Interactive Signin with Service Accounts
```bash
# Bad: Wrapper functions that call signin
function op_no_auth() {
    if ! op "$@" 2>/dev/null; then
        op signin --account XXXXX  # Service accounts don't need this!
        op "$@"
    fi
}
```

### ❌ Don't Store Tokens in Multiple Places
- Keep tokens ONLY in `~/.zshrc`
- Don't duplicate in other files
- Makes rotation easier

### ✅ Do Use Environment Variables Consistently
```bash
# Good: Single source of truth
export OP_SERVICE_ACCOUNT_TOKEN="ops_..."

# All commands use this automatically
op vault list
op item list
op item get "item-name"
```

---

## Verification Checklist

After making changes, verify everything works:

- [ ] `op whoami` shows SERVICE_ACCOUNT user type
- [ ] `op vault list` shows all accessible vaults
- [ ] `op item list --vault "Eric"` lists items successfully
- [ ] No authorization popups appear
- [ ] No "credentials not compatible" errors

---

## Quick Commands Reference

```bash
# Check authentication status
op whoami

# List vaults
op vault list

# List items in a vault
op item list --vault "VaultName"

# Get a specific item
op item get "ItemName" --vault "VaultName"

# Get TOTP code
op item get "ItemName" --otp

# Verify token is set
echo $OP_SERVICE_ACCOUNT_TOKEN | cut -c1-20
```

---

## Related Documentation

- [1Password CLI Documentation](https://developer.1password.com/docs/cli/)
- [Service Accounts Guide](https://developer.1password.com/docs/service-accounts/)
- Personal troubleshooting notes in: `/Users/ealwais/CLAUDE.md`

---

## Troubleshooting Log

### 2025-10-22 - Token Rotation Resolution
- **Issue:** Multiple "Signin credentials are not compatible" errors
- **Root Cause:** Old expired service account tokens in `.zshrc` (2 locations) and problematic `op_no_auth` wrapper function
- **Solution:** Rotated service account token and updated both locations in `.zshrc`, removed `op_no_auth` wrapper
- **Result:** ✅ Authentication successful, all vaults accessible
