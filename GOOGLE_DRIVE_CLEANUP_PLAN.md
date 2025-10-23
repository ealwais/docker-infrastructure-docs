# Google Drive Cleanup Plan

## Current Status

### ✅ Cleaned
- **Docker/Documentation/** - Successfully cleaned and synced
  - 108 organized markdown files
  - 97 outdated files removed
  - Now matches local cleaned structure

### ⚠️ Needs Attention

#### Personal Folder (85 markdown files)
Contains older Docker/streaming documentation that appears to predate our consolidation:

**Likely Duplicates:**
- `XTEVE_SETUP_GUIDE.md` - Covered in our streaming consolidated guides
- `XTEVE_BUFFER_GUIDE.md` - Covered in streaming guides  
- `XTEVE_TVHEADEND_STREAMING_SETUP.md` - Covered in streaming guides
- `BUFFERING_SETUP.md` - Covered in streaming guides
- `MSNBC_STREAM_RESET.md` - Likely outdated procedure
- `README_TVHEADEND.md` - Covered in streaming guides

**Infrastructure Docs (may be outdated):**
- `docker_runbook.md` (33KB) - May have useful content
- `docker_best_practices.md` (11KB) - Check against current practices
- `consolidated_backup_strategy.md` (21KB) - Compare with our BACKUP_AND_RESTORE_COMPLETE.md
- `credential_management_system.md` (21KB) - Security sensitive, review carefully

**Unique Content (possibly keep):**
- `automation_documentation.md` (31KB) - Large file, may have unique content
- `hardware_inventory.md` - System documentation
- `network_architecture.md` - Infrastructure documentation

#### git Folder (2 files)
- `CLAUDE.md` - Likely outdated context file
- `documentation_audit_report.md` - May be useful audit trail

## Recommended Actions

### 1. Archive Personal Folder
```bash
# Create archive with date stamp
rclone move drive:Personal drive:Archive/Personal_backup_20250828 \
  --include "*.md" \
  --dry-run  # Remove --dry-run to execute
```

### 2. Review Unique Content First
Before archiving, check these files for unique content:
- `automation_documentation.md` (31KB)
- `docker_runbook.md` (33KB)  
- `consolidated_backup_strategy.md` (21KB)
- `credential_management_system.md` (21KB)

### 3. Clean git Folder
```bash
# Update CLAUDE.md with our current version
rclone copy /mnt/docker/CLAUDE.md drive:git/
```

### 4. Final Structure
After cleanup:
```
Google Drive/
├── Docker/
│   └── Documentation/  (✅ Clean - 108 files)
├── Archive/
│   └── Personal_backup_20250828/  (Old docs)
└── git/
    └── CLAUDE.md  (Updated)
```

## Storage Impact
- Current: ~85 files in Personal + 2 in git = 87 extra files
- After: 0 extra files (all archived or removed)
- Reduction: 87 files removed from active folders

## Safety Notes
- Use `--dry-run` flag first to preview changes
- Archive rather than delete in case content is needed
- Review large files (>20KB) for unique content before archiving