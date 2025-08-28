# Documentation Sync Configuration

## Current Setup

### 📁 Local Master Location
```
/mnt/docker/documentation/
```
This is your **single source of truth** for all documentation.

### ☁️ Google Drive Sync

**Status:** ✅ ACTIVE  
**Direction:** One-way (Local → Google Drive)  
**Schedule:** Daily at 2:00 AM  

```
Local:  /mnt/docker/documentation/
Remote: drive:Docker/Documentation/
Script: /mnt/docker/scripts/sync_documentation.sh
```

**What syncs:**
- All markdown files in documentation folder
- Excludes archive folder
- Excludes hidden files and temp files

**Cron job:**
```bash
0 2 * * * /mnt/docker/scripts/sync_documentation.sh
```

### 🐙 GitHub Integration

**Status:** ✅ CONNECTED  
**Repository:** https://github.com/ealwais/docker-infrastructure-docs  
**Branch:** main  
**Sync:** Automatic with Google Drive sync (Daily 2AM)  

The `/mnt/docker/documentation/` folder is now a git repository connected to GitHub.

## Data Flow

```
/mnt/docker/documentation/
         |
         ├──[Daily 2AM]──> Google Drive: Docker/Documentation/
         |
         └──[Daily 2AM]──> GitHub: ealwais/docker-infrastructure-docs
```

## How to Set Up GitHub Sync (If Desired)

### Option 1: Create New GitHub Repository
```bash
cd /mnt/docker/documentation
git init
git add README.md QUICK_ACCESS.md
git commit -m "Initial documentation structure"
git remote add origin https://github.com/yourusername/docker-docs.git
git push -u origin main
```

### Option 2: Sync Select Files Only
Keep documentation local/Google Drive only, but sync key files:
```bash
# Copy key files to a git repo
cp /mnt/docker/documentation/QUICK_ACCESS.md /path/to/your/repo/
cp /mnt/docker/documentation/services/homeassistant/*_COMPLETE.md /path/to/your/repo/
```

## Current Sync Summary

| Location | Type | Status | Schedule | Content |
|----------|------|--------|----------|---------|
| Local `/mnt/docker/documentation/` | Master | ✅ Active | - | 108 files |
| Google Drive `Docker/Documentation/` | Backup | ✅ Active | Daily 2AM | Mirrors local |
| GitHub | Version Control | ❌ Not Connected | - | - |

## Key Points

1. **Local documentation** is the master copy
2. **Google Drive** gets automatic nightly backups
3. **GitHub** is currently NOT connected
4. All changes should be made in `/mnt/docker/documentation/`
5. Google Drive sync is one-way (local → cloud)

## To Check Sync Status

```bash
# Check last Google Drive sync
tail /mnt/docker/logs/docker_docs_sync.log

# Check what will sync
/mnt/docker/scripts/sync_documentation.sh --dry-run

# Force immediate sync
/mnt/docker/scripts/sync_documentation.sh
```

---
*Last updated: 2025-08-28*