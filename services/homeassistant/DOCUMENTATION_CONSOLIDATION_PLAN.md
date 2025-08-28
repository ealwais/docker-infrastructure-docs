# Documentation Consolidation Plan

## Current Documentation Analysis (26 .md files)

### Categories:

#### 1. **Setup & Installation Guides** (11 files)
- API_KEYS_SETUP_GUIDE.md
- ARLO_SETUP_GUIDE.md
- GOOGLE_DRIVE_MOUNT_GUIDE.md
- PORTAINER_SETUP.md
- tesla_setup_instructions.md
- hdhomerun_myq_setup.md
- integration_setup_guide.md (lowercase)
- INTEGRATION_SETUP_GUIDE.md (uppercase)
- INTEGRATIONS_TO_ADD.md
- ZHA_SETUP_GUIDE.md
- ZIGBEE_MACOS_SETUP.md

#### 2. **UniFi Specific** (3 files)
- FIX_UNIFI_PROTECT.md
- UNIFI_PROTECT_SETUP_STEPS.md
- UNIFI_SETUP_INSTRUCTIONS.md

#### 3. **System Status & Issues** (7 files)
- CURRENT_ISSUES_AND_STATUS.md
- WORKING_STATE_DOCUMENTATION.md
- SETUP_COMPLETE.md
- SESSION_CHANGES_20250110.md
- CHECK_DASHBOARD_ACCESS.md
- DEBUG_DASHBOARD_ISSUE.md
- NEXT_STEPS_TO_FIX_DASHBOARD.md

#### 4. **Dashboard Related** (2 files)
- DASHBOARD_FIX_SUMMARY.md
- (Plus 3 dashboard debug files above)

#### 5. **System Management** (3 files)
- BACKUP_AND_RESTORE_GUIDE.md
- HA_BLUEGREEN_DEPLOYMENT.md
- README_Integration_Monitoring.md

#### 6. **General Docs** (2 files)
- INFRASTRUCTURE_OVERVIEW.md
- TROUBLESHOOTING.md

## Duplicates/Overlaps Found:

1. **Zigbee Guides**: 
   - ZHA_SETUP_GUIDE.md
   - ZIGBEE_MACOS_SETUP.md
   (Both cover Zigbee setup on macOS)

2. **Integration Guides**:
   - integration_setup_guide.md
   - INTEGRATION_SETUP_GUIDE.md
   - INTEGRATIONS_TO_ADD.md
   (Overlapping content about setting up integrations)

3. **Dashboard Issues**:
   - Multiple files covering dashboard problems
   - Should be consolidated into one troubleshooting guide

4. **Status Documents**:
   - Multiple "current state" files
   - Should maintain only one current status file

## Proposed Consolidated Structure:

### 📁 docs/
```
├── README.md                          # Main documentation index
├── CURRENT_STATUS.md                  # Single source of truth for system state
├── setup/
│   ├── INITIAL_SETUP.md             # First-time setup guide
│   ├── INTEGRATIONS_GUIDE.md        # All integrations in one place
│   ├── ZIGBEE_SETUP.md              # Consolidated Zigbee guide
│   └── UNIFI_SETUP.md               # All UniFi related setup
├── guides/
│   ├── BACKUP_AND_RESTORE.md        # System backup procedures
│   ├── API_KEYS_AND_SECRETS.md     # Security and API setup
│   ├── DASHBOARD_MANAGEMENT.md      # Dashboard creation and fixes
│   └── INFRASTRUCTURE.md           # Network topology and services
├── troubleshooting/
│   ├── COMMON_ISSUES.md             # General troubleshooting
│   ├── DASHBOARD_ISSUES.md          # Dashboard-specific problems
│   └── INTEGRATION_ISSUES.md        # Integration-specific problems
└── archive/
    └── [old individual files]        # Keep originals for reference
```

## Benefits of Consolidation:
1. Eliminates duplicate information
2. Creates clear navigation structure
3. Reduces file count from 26 to ~12
4. Makes finding information easier
5. Prevents conflicting instructions