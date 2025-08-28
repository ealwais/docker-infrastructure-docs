# Home Assistant Complete Documentation

*Consolidated on: 2025-08-27*

## Table of Contents

1. [Readme](#readme)
2. [Readme Integration Monitoring](#readme_integration_monitoring)
3. [Readme Homeassistant-Mcp](#readme_homeassistant-mcp)
4. [Readme Docs](#readme_docs)
5. [Readme Mcp](#readme_mcp)
6. [Readme Smart Home](#readme_smart_home)
7. [Readme Validate](#readme_validate)

---

## Readme
*Source: README.md*

Welcome to the consolidated Home Assistant documentation. This README serves as an index to all documentation.

## 📚 Documentation Structure

### 🚀 [CURRENT_STATUS.md](CURRENT_STATUS.md)
The current state of the Home Assistant system, active issues, and recent changes.

### 📁 Setup Guides
- **[INITIAL_SETUP.md](setup/INITIAL_SETUP.md)** - First-time Home Assistant setup
- **[INTEGRATIONS_GUIDE.md](setup/INTEGRATIONS_GUIDE.md)** - Complete guide to all integrations
- **[ZIGBEE_SETUP.md](setup/ZIGBEE_SETUP.md)** - Zigbee/ZHA setup on macOS with Docker
- **[UNIFI_SETUP.md](setup/UNIFI_SETUP.md)** - UniFi Network and Protect setup

### 📖 How-To Guides
- **[BACKUP_AND_RESTORE.md](guides/BACKUP_AND_RESTORE.md)** - Backup procedures and recovery
- **[API_KEYS_AND_SECRETS.md](guides/API_KEYS_AND_SECRETS.md)** - API keys, tokens, and security
- **[DASHBOARD_MANAGEMENT.md](guides/DASHBOARD_MANAGEMENT.md)** - Creating and managing dashboards
- **[INFRASTRUCTURE.md](guides/INFRASTRUCTURE.md)** - Network topology and service locations

### 🔧 Troubleshooting
- **[COMMON_ISSUES.md](troubleshooting/COMMON_ISSUES.md)** - General troubleshooting guide
- **[DASHBOARD_ISSUES.md](troubleshooting/DASHBOARD_ISSUES.md)** - Dashboard-specific problems
- **[INTEGRATION_ISSUES.md](troubleshooting/INTEGRATION_ISSUES.md)** - Integration-specific fixes
- **[DOCKER_SYNC_ISSUES.md](troubleshooting/DOCKER_SYNC_ISSUES.md)** - Docker Desktop file sync problems

### 🛡️ Monitoring & Maintenance
- **[INTEGRATION_MONITORING.md](INTEGRATION_MONITORING.md)** - Automatic integration monitoring system
- **[SYSTEM_HEALTH_AND_MONITORING.md](docs/SYSTEM_HEALTH_AND_MONITORING.md)** - Complete health check and recovery guide
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Quick command reference card

## 🏠 System Information

**Home Assistant URL**: http://192.168.3.20:8123  
**Configuration**: YAML mode  
**Platform**: macOS Docker (Colima)  
**Backup Location**: `/mnt/docker/homeassistant.backup_20250810_083925_WORKING`

### Docker Environments
- **Mac Mini** (192.168.3.20): Primary HA host - ✅ Working
- **Docker Server** (192.168.3.11): Additional services - ✅ Working  
- **QNAP NAS** (192.168.3.10): Container Station - ✅ Working
- **Synology NAS** (192.168.3.120): Docker Package - ⚠️ Requires login

## 🔍 Quick Links

### Most Common Tasks:
- [Add a new integration](setup/INTEGRATIONS_GUIDE.md#adding-integrations)
- [Fix dashboard sync issues](troubleshooting/DASHBOARD_ISSUES.md#sync-issues)
- [Restore from backup](guides/BACKUP_AND_RESTORE.md#restore-process)
- [Setup Zigbee devices](setup/ZIGBEE_SETUP.md)

### Critical Files:
- `configuration.yaml` - Main configuration
- `secrets.yaml` - API keys and passwords
- `docker-compose.yaml` - Docker setup
- `.storage/` - UI-configured integrations (DO NOT DELETE)

## 📝 Documentation Updates

**Last Updated**: August 15, 2025

### Recent Updates:
- Added Docker sync troubleshooting guide
- Created integration monitoring documentation  
- Updated system status with MCP and monitor fixes
- Added Tesla Powerwall and SABnzbd integrations
- Documented all Docker environments and infrastructure
- Fixed Portainer access and updated dashboard  
**Consolidated From**: 26 individual documentation files  
**Archive Location**: `docs/archive/` contains all original files

---

For questions or issues, check the troubleshooting section first.

---

## Readme Integration Monitoring
*Source: README_Integration_Monitoring.md*

This collection of scripts and configurations helps automatically detect and fix "Session is closed" errors in Home Assistant integrations.

## Files Created

### 1. **Python Integration Monitor** (`scripts/integration_monitor.py`)
- Continuously monitors for session closed errors
- Automatically restarts failed integrations (bond, unifi, sonarr, sabnzbd)
- Implements cooldown periods and retry limits
- Logs all activities

### 2. **HA Automations** (`automations/integration_error_monitor.yaml`)
- Monitors system logs for errors
- Counts errors per integration
- Sends notifications when errors detected
- Auto-restarts integrations after threshold reached
- Includes Zigbee coordinator error detection

### 3. **Shell Health Check Script** (`scripts/check_integrations.sh`)
- Tests network connectivity to services
- Verifies API endpoints are responding
- Can restart integrations via HA API
- Provides detailed logging

### 4. **Zigbee Reset Script** (`scripts/zigbee_reset.sh`)
- Detects Zigbee coordinator failures
- Resets USB device multiple ways
- Restarts ZHA integration
- Can run in monitor mode for continuous checking

### 5. **Timeout Configuration** (`packages/integration_timeouts.yaml`)
- Increases timeouts for all affected integrations
- Configures connection pooling
- Adds system monitoring sensors
- Creates binary sensors for integration health

### 6. **Setup Script** (`scripts/setup_monitoring.sh`)
- Helps configure all monitoring components
- Creates necessary directories
- Sets up cron jobs or systemd services

## Installation Steps

1. **Set Home Assistant Token**:
   ```bash
   export HA_TOKEN='your-long-lived-access-token-here'
   ```
   Create token in HA UI: Profile → Long-Lived Access Tokens

2. **Update configuration.yaml**:
   ```yaml
   # Add packages support
   homeassistant:
     packages: !include_dir_named packages
   
   # Add automation directory
   automation: !include_dir_merge_list automations/
   ```

3. **Copy helper entities** from `automations/integration_error_monitor.yaml` to your configuration.yaml

4. **Run setup script**:
   ```bash
   docker exec homeassistant /config/scripts/setup_monitoring.sh
   ```

5. **Restart Home Assistant**

## Usage

### Manual Commands

- **Check integration health**:
  ```bash
  docker exec homeassistant /config/scripts/check_integrations.sh
  ```

- **Reset Zigbee coordinator**:
  ```bash
  docker exec homeassistant /config/scripts/zigbee_reset.sh reset
  ```

- **Start integration monitor**:
  ```bash
  docker exec -e HA_TOKEN='your-token' homeassistant python3 /config/scripts/integration_monitor.py
  ```

### Monitoring

- Check logs in `/config/logs/`
- View integration health in HA UI via binary sensors
- Receive notifications when integrations fail
- Error counts tracked in counter entities

## Troubleshooting

1. **Scripts not working**: Ensure HA_TOKEN is set correctly
2. **Zigbee reset fails**: May need to run container in privileged mode for USB access
3. **Services unreachable**: Update host IPs in scripts to match your network
4. **Too many restarts**: Adjust MAX_RESTART_ATTEMPTS and RESTART_COOLDOWN in scripts

## Security Notes

- Store HA_TOKEN securely, not in scripts
- Restrict script permissions: `chmod 750 /config/scripts/*.sh`
- Review logs regularly for unusual activity
- Consider network isolation for critical services

---

## Readme Homeassistant-Mcp
*Source: README_homeassistant-mcp.md*

The server uses the MCP protocol to share access to a local Home Assistant instance with an LLM application.

A powerful bridge between your Home Assistant instance and Language Learning Models (LLMs), enabling natural language control and monitoring of your smart home devices through the Model Context Protocol (MCP). This server provides a comprehensive API for managing your entire Home Assistant ecosystem, from device control to system administration.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Node.js](https://img.shields.io/badge/node-%3E%3D20.10.0-green.svg)
![Docker Compose](https://img.shields.io/badge/docker-compose-%3E%3D1.27.0-blue.svg)
![NPM](https://img.shields.io/badge/npm-%3E%3D7.0.0-orange.svg)
![TypeScript](https://img.shields.io/badge/typescript-%5E5.0.0-blue.svg)
![Test Coverage](https://img.shields.io/badge/coverage-95%25-brightgreen.svg)

## Features

- 🎮 **Device Control**: Control any Home Assistant device through natural language
- 🔄 **Real-time Updates**: Get instant updates through Server-Sent Events (SSE)
- 🤖 **Automation Management**: Create, update, and manage automations
- 📊 **State Monitoring**: Track and query device states
- 🔐 **Secure**: Token-based authentication and rate limiting
- 📱 **Mobile Ready**: Works with any HTTP-capable client

## Real-time Updates with SSE

The server includes a powerful Server-Sent Events (SSE) system that provides real-time updates from your Home Assistant instance. This allows you to:

- 🔄 Get instant state changes for any device
- 📡 Monitor automation triggers and executions
- 🎯 Subscribe to specific domains or entities
- 📊 Track service calls and script executions

### Quick SSE Example

```javascript
const eventSource = new EventSource(
  'http://localhost:3000/subscribe_events?token=YOUR_TOKEN&domain=light'
);

eventSource.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('Update received:', data);
};
```

See [SSE_API.md](docs/SSE_API.md) for complete documentation of the SSE system.

## Table of Contents

- [Key Features](#key-features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Basic Setup](#basic-setup)
  - [Docker Setup (Recommended)](#docker-setup-recommended)
- [Configuration](#configuration)
- [Development](#development)
- [API Reference](#api-reference)
  - [Device Control](#device-control)
  - [Add-on Management](#add-on-management)
  - [Package Management](#package-management)
  - [Automation Management](#automation-management)
- [Natural Language Integration](#natural-language-integration)
- [Troubleshooting](#troubleshooting)
- [Project Status](#project-status)
- [Contributing](#contributing)
- [Resources](#resources)
- [License](#license)

## Key Features

### Core Functionality 🎮
- **Smart Device Control**
  - 💡 **Lights**: Brightness, color temperature, RGB color
  - 🌡️ **Climate**: Temperature, HVAC modes, fan modes, humidity
  - 🚪 **Covers**: Position and tilt control
  - 🔌 **Switches**: On/off control
  - 🚨 **Sensors & Contacts**: State monitoring
  - 🎵 **Media Players**: Playback control, volume, source selection
  - 🌪️ **Fans**: Speed, oscillation, direction
  - 🔒 **Locks**: Lock/unlock control
  - 🧹 **Vacuums**: Start, stop, return to base
  - 📹 **Cameras**: Motion detection, snapshots

### System Management 🛠️
- **Add-on Management**
  - Browse available add-ons
  - Install/uninstall add-ons
  - Start/stop/restart add-ons
  - Version management
  - Configuration access

- **Package Management (HACS)**
  - Integration with Home Assistant Community Store
  - Multiple package types support:
    - Custom integrations
    - Frontend themes
    - Python scripts
    - AppDaemon apps
    - NetDaemon apps
  - Version control and updates
  - Repository management

- **Automation Management**
  - Create and edit automations
  - Advanced configuration options:
    - Multiple trigger types
    - Complex conditions
    - Action sequences
    - Execution modes
  - Duplicate and modify existing automations
  - Enable/disable automation rules
  - Trigger automation manually

### Architecture Features 🏗️
- **Intelligent Organization**
  - Area and floor-based device grouping
  - State monitoring and querying
  - Smart context awareness
  - Historical data access

- **Robust Architecture**
  - Comprehensive error handling
  - State validation
  - Secure API integration
  - TypeScript type safety
  - Extensive test coverage

## Prerequisites

- **Node.js** 20.10.0 or higher
- **NPM** package manager
- **Docker Compose** for containerization
- Running **Home Assistant** instance
- Home Assistant long-lived access token ([How to get token](https://community.home-assistant.io/t/how-to-get-long-lived-access-token/162159))
- **HACS** installed for package management features
- **Supervisor** access for add-on management

## Installation

### Basic Setup

```bash

git clone https://github.com/jango-blockchained/homeassistant-mcp.git
cd homeassistant-mcp


npm install


npm run build
```

### Docker Setup (Recommended)

The project includes Docker support for easy deployment and consistent environments across different platforms.

1. **Clone the repository:**
    ```bash
    git clone https://github.com/jango-blockchained/homeassistant-mcp.git
    cd homeassistant-mcp
    ```

2. **Configure environment:**
    ```bash
    cp .env.example .env
    ```
    Edit the `.env` file with your Home Assistant configuration:
    ```env
    # Home Assistant Configuration
    HASS_HOST=http://homeassistant.local:8123
    HASS_TOKEN=your_home_assistant_token
    HASS_SOCKET_URL=ws://homeassistant.local:8123/api/websocket

    # Server Configuration
    PORT=3000
    NODE_ENV=production
    DEBUG=false
    ```

3. **Build and run with Docker Compose:**
    ```bash
    # Build and start the containers
    docker compose up -d

    # View logs
    docker compose logs -f

    # Stop the service
    docker compose down
    ```

4. **Verify the installation:**
    The server should now be running at `http://localhost:3000`. You can check the health endpoint at `http://localhost:3000/health`.

5. **Update the application:**
    ```bash
    # Pull the latest changes
    git pull

    # Rebuild and restart the containers
    docker compose up -d --build
    ```

#### Docker Configuration

The Docker setup includes:
- Multi-stage build for optimal image size
- Health checks for container monitoring
- Volume mounting for environment configuration
- Automatic container restart on failure
- Exposed port 3000 for API access

#### Docker Compose Environment Variables

All environment variables can be configured in the `.env` file. The following variables are supported:
- `HASS_HOST`: Your Home Assistant instance URL
- `HASS_TOKEN`: Long-lived access token for Home Assistant
- `HASS_SOCKET_URL`: WebSocket URL for Home Assistant
- `PORT`: Server port (default: 3000)
- `NODE_ENV`: Environment (production/development)
- `DEBUG`: Enable debug mode (true/false)

## Configuration

### Environment Variables

```env

HASS_HOST=http://homeassistant.local:8123  # Your Home Assistant instance URL
HASS_TOKEN=your_home_assistant_token       # Long-lived access token
HASS_SOCKET_URL=ws://homeassistant.local:8123/api/websocket  # WebSocket URL


PORT=3000                # Server port (default: 3000)
NODE_ENV=production     # Environment (production/development)
DEBUG=false            # Enable debug mode


TEST_HASS_HOST=http://localhost:8123  # Test instance URL
TEST_HASS_TOKEN=test_token           # Test token
```

### Configuration Files

1. **Development**: Copy `.env.example` to `.env.development`
2. **Production**: Copy `.env.example` to `.env.production`
3. **Testing**: Copy `.env.example` to `.env.test`

### Adding to Claude Desktop (or other clients)

To use your new Home Assistant MCP server, you can add Claude Desktop as a client. Add the following to the configuration. Note this will run the MCP within claude and does not work with the Docker method.

```
{
  "homeassistant": {
    "command": "node",
    "args": [<path/to/your/dist/folder>]
    "env": {
      NODE_ENV=development
      HASS_HOST=http://homeassistant.local:8123
      HASS_TOKEN=your_home_assistant_token
      PORT=3000
      HASS_SOCKET_URL=ws://homeassistant.local:8123/api/websocket
      LOG_LEVEL=debug
    }
  }
}

```



## API Reference

### Device Control

#### Common Entity Controls
```json
{
  "tool": "control",
  "command": "turn_on",  // or "turn_off", "toggle"
  "entity_id": "light.living_room"
}
```

#### Light Control
```json
{
  "tool": "control",
  "command": "turn_on",
  "entity_id": "light.living_room",
  "brightness": 128,
  "color_temp": 4000,
  "rgb_color": [255, 0, 0]
}
```

### Add-on Management

#### List Available Add-ons
```json
{
  "tool": "addon",
  "action": "list"
}
```

#### Install Add-on
```json
{
  "tool": "addon",
  "action": "install",
  "slug": "core_configurator",
  "version": "5.6.0"
}
```

#### Manage Add-on State
```json
{
  "tool": "addon",
  "action": "start",  // or "stop", "restart"
  "slug": "core_configurator"
}
```

### Package Management

#### List HACS Packages
```json
{
  "tool": "package",
  "action": "list",
  "category": "integration"  // or "plugin", "theme", "python_script", "appdaemon", "netdaemon"
}
```

#### Install Package
```json
{
  "tool": "package",
  "action": "install",
  "category": "integration",
  "repository": "hacs/integration",
  "version": "1.32.0"
}
```

### Automation Management

#### Create Automation
```json
{
  "tool": "automation_config",
  "action": "create",
  "config": {
    "alias": "Motion Light",
    "description": "Turn on light when motion detected",
    "mode": "single",
    "trigger": [
      {
        "platform": "state",
        "entity_id": "binary_sensor.motion",
        "to": "on"
      }
    ],
    "action": [
      {
        "service": "light.turn_on",
        "target": {
          "entity_id": "light.living_room"
        }
      }
    ]
  }
}
```

#### Duplicate Automation
```json
{
  "tool": "automation_config",
  "action": "duplicate",
  "automation_id": "automation.motion_light"
}
```

### Core Functions

#### State Management
```http
GET /api/state
POST /api/state
```

Manages the current state of the system.

**Example Request:**
```json
POST /api/state
{
  "context": "living_room",
  "state": {
    "lights": "on",
    "temperature": 22
  }
}
```

#### Context Updates
```http
POST /api/context
```

Updates the current context with new information.

**Example Request:**
```json
POST /api/context
{
  "user": "john",
  "location": "kitchen",
  "time": "morning",
  "activity": "cooking"
}
```

### Action Endpoints

#### Execute Action
```http
POST /api/action
```

Executes a specified action with given parameters.

**Example Request:**
```json
POST /api/action
{
  "action": "turn_on_lights",
  "parameters": {
    "room": "living_room",
    "brightness": 80
  }
}
```

#### Batch Actions
```http
POST /api/actions/batch
```

Executes multiple actions in sequence.

**Example Request:**
```json
POST /api/actions/batch
{
  "actions": [
    {
      "action": "turn_on_lights",
      "parameters": {
        "room": "living_room"
      }
    },
    {
      "action": "set_temperature",
      "parameters": {
        "temperature": 22
      }
    }
  ]
}
```

### Query Functions

#### Get Available Actions
```http
GET /api/actions
```

Returns a list of all available actions.

**Example Response:**
```json
{
  "actions": [
    {
      "name": "turn_on_lights",
      "parameters": ["room", "brightness"],
      "description": "Turns on lights in specified room"
    },
    {
      "name": "set_temperature",
      "parameters": ["temperature"],
      "description": "Sets temperature in current context"
    }
  ]
}
```

#### Context Query
```http
GET /api/context?type=current
```

Retrieves context information.

**Example Response:**
```json
{
  "current_context": {
    "user": "john",
    "location": "kitchen",
    "time": "morning",
    "activity": "cooking"
  }
}
```

### WebSocket Events

The server supports real-time updates via WebSocket connections.

```javascript
// Client-side connection example
const ws = new WebSocket('ws://localhost:3000/ws');

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('Received update:', data);
};
```

#### Supported Events

- `state_change`: Emitted when system state changes
- `context_update`: Emitted when context is updated
- `action_executed`: Emitted when an action is completed
- `error`: Emitted when an error occurs

**Example Event Data:**
```json
{
  "event": "state_change",
  "data": {
    "previous_state": {
      "lights": "off"
    },
    "current_state": {
      "lights": "on"
    },
    "timestamp": "2024-03-20T10:30:00Z"
  }
}
```

### Error Handling

All endpoints return standard HTTP status codes:

- 200: Success
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 500: Internal Server Error

**Error Response Format:**
```json
{
  "error": {
    "code": "INVALID_PARAMETERS",
    "message": "Missing required parameter: room",
    "details": {
      "missing_fields": ["room"]
    }
  }
}
```

### Rate Limiting

The API implements rate limiting to prevent abuse:

- 100 requests per minute per IP for regular endpoints
- 1000 requests per minute per IP for WebSocket connections

When rate limit is exceeded, the server returns:

```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests",
    "reset_time": "2024-03-20T10:31:00Z"
  }
}
```

### Example Usage

#### Using curl
```bash

curl -X GET \
  http://localhost:3000/api/state \
  -H 'Authorization: ApiKey your_api_key_here'


curl -X POST \
  http://localhost:3000/api/action \
  -H 'Authorization: ApiKey your_api_key_here' \
  -H 'Content-Type: application/json' \
  -d '{
    "action": "turn_on_lights",
    "parameters": {
      "room": "living_room",
      "brightness": 80
    }
  }'
```

#### Using JavaScript
```javascript
// Execute action
async function executeAction() {
  const response = await fetch('http://localhost:3000/api/action', {
    method: 'POST',
    headers: {
      'Authorization': 'ApiKey your_api_key_here',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      action: 'turn_on_lights',
      parameters: {
        room: 'living_room',
        brightness: 80
      }
    })
  });
  
  const data = await response.json();
  console.log('Action result:', data);
}
```

## Development

```bash

npm run dev


npm run build


npm run start


npx jest --config=jest.config.cjs


npx jest --coverage


npm run lint


npm run format
```

## Troubleshooting

### Common Issues

1. **Node.js Version (`toSorted is not a function`)**
   - **Solution:** Update to Node.js 20.10.0+
   ```bash
   nvm install 20.10.0
   nvm use 20.10.0
   ```

2. **Connection Issues**
   - Verify Home Assistant is running
   - Check `HASS_HOST` accessibility
   - Validate token permissions
   - Ensure WebSocket connection for real-time updates

3. **Add-on Management Issues**
   - Verify Supervisor access
   - Check add-on compatibility
   - Validate system resources

4. **HACS Integration Issues**
   - Verify HACS installation
   - Check HACS integration status
   - Validate repository access

5. **Automation Issues**
   - Verify entity availability
   - Check trigger conditions
   - Validate service calls
   - Monitor execution logs

## Project Status

✅ **Complete**
- Entity, Floor, and Area access
- Device control (Lights, Climate, Covers, Switches, Contacts)
- Add-on management system
- Package management through HACS
- Advanced automation configuration
- Basic state management
- Error handling and validation
- Docker containerization
- Jest testing setup
- TypeScript integration
- Environment variable management
- Home Assistant API integration
- Project documentation

🚧 **In Progress**
- WebSocket implementation for real-time updates
- Enhanced security features
- Tool organization optimization
- Performance optimization
- Resource context integration
- API documentation generation
- Multi-platform desktop integration
- Advanced error recovery
- Custom prompt testing
- Enhanced macOS integration
- Type safety improvements
- Testing coverage expansion

## Contributing

1. Fork the repository
2. Create a feature branch
3. Implement your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## Resources

- [MCP Documentation](https://modelcontextprotocol.io/introduction)
- [Home Assistant Docs](https://www.home-assistant.io)
- [HA REST API](https://developers.home-assistant.io/docs/api/rest)
- [HACS Documentation](https://hacs.xyz)
- [TypeScript Documentation](https://www.typescriptlang.org/docs)

## License

MIT License - See [LICENSE](LICENSE) file

---

## Readme Docs
*Source: README_docs.md*

Welcome to the consolidated Home Assistant documentation. This README serves as an index to all documentation.

## 📚 Documentation Structure

### 🚀 [CURRENT_STATUS.md](CURRENT_STATUS.md)
The current state of the Home Assistant system, active issues, and recent changes.

### 📁 Setup Guides
- **[INITIAL_SETUP.md](setup/INITIAL_SETUP.md)** - First-time Home Assistant setup
- **[INTEGRATIONS_GUIDE.md](setup/INTEGRATIONS_GUIDE.md)** - Complete guide to all integrations
- **[ZIGBEE_SETUP.md](setup/ZIGBEE_SETUP.md)** - Zigbee/ZHA setup on macOS with Docker
- **[UNIFI_SETUP.md](setup/UNIFI_SETUP.md)** - UniFi Network and Protect setup

### 📖 How-To Guides
- **[BACKUP_AND_RESTORE.md](guides/BACKUP_AND_RESTORE.md)** - Backup procedures and recovery
- **[API_KEYS_AND_SECRETS.md](guides/API_KEYS_AND_SECRETS.md)** - API keys, tokens, and security
- **[DASHBOARD_MANAGEMENT.md](guides/DASHBOARD_MANAGEMENT.md)** - Creating and managing dashboards
- **[INFRASTRUCTURE.md](guides/INFRASTRUCTURE.md)** - Network topology and service locations

### 🔧 Troubleshooting
- **[COMMON_ISSUES.md](troubleshooting/COMMON_ISSUES.md)** - General troubleshooting guide
- **[DASHBOARD_ISSUES.md](troubleshooting/DASHBOARD_ISSUES.md)** - Dashboard-specific problems
- **[INTEGRATION_ISSUES.md](troubleshooting/INTEGRATION_ISSUES.md)** - Integration-specific fixes
- **[DOCKER_SYNC_ISSUES.md](troubleshooting/DOCKER_SYNC_ISSUES.md)** - Docker Desktop file sync problems

### 🛡️ Monitoring & Maintenance
- **[INTEGRATION_MONITORING.md](INTEGRATION_MONITORING.md)** - Automatic integration monitoring system
- **[SYSTEM_HEALTH_AND_MONITORING.md](docs/SYSTEM_HEALTH_AND_MONITORING.md)** - Complete health check and recovery guide
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Quick command reference card

## 🏠 System Information

**Home Assistant URL**: http://192.168.3.20:8123  
**Configuration**: YAML mode  
**Platform**: macOS Docker (Colima)  
**Backup Location**: `/mnt/docker/homeassistant.backup_20250810_083925_WORKING`

### Docker Environments
- **Mac Mini** (192.168.3.20): Primary HA host - ✅ Working
- **Docker Server** (192.168.3.11): Additional services - ✅ Working  
- **QNAP NAS** (192.168.3.10): Container Station - ✅ Working
- **Synology NAS** (192.168.3.120): Docker Package - ⚠️ Requires login

## 🔍 Quick Links

### Most Common Tasks:
- [Add a new integration](setup/INTEGRATIONS_GUIDE.md#adding-integrations)
- [Fix dashboard sync issues](troubleshooting/DASHBOARD_ISSUES.md#sync-issues)
- [Restore from backup](guides/BACKUP_AND_RESTORE.md#restore-process)
- [Setup Zigbee devices](setup/ZIGBEE_SETUP.md)

### Critical Files:
- `configuration.yaml` - Main configuration
- `secrets.yaml` - API keys and passwords
- `docker-compose.yaml` - Docker setup
- `.storage/` - UI-configured integrations (DO NOT DELETE)

## 📝 Documentation Updates

**Last Updated**: August 15, 2025

### Recent Updates:
- Added Docker sync troubleshooting guide
- Created integration monitoring documentation  
- Updated system status with MCP and monitor fixes
- Added Tesla Powerwall and SABnzbd integrations
- Documented all Docker environments and infrastructure
- Fixed Portainer access and updated dashboard  
**Consolidated From**: 26 individual documentation files  
**Archive Location**: `docs/archive/` contains all original files

---

For questions or issues, check the troubleshooting section first.

---

## Readme Mcp
*Source: README_MCP.md*

## Overview
This directory contains comprehensive documentation for the Home Assistant MCP (Model Context Protocol) setup with Claude Desktop integration.

## Documentation Files

1. **[HOME_ASSISTANT_MCP_SETUP.md](./HOME_ASSISTANT_MCP_SETUP.md)**
   - Complete setup and configuration details
   - System architecture overview
   - Configuration files and settings
   - MCP server capabilities

2. **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)**
   - Common issues and solutions
   - Debug commands and scripts
   - Error message reference
   - Recovery procedures

3. **[QUICK_REFERENCE.md](./QUICK_REFERENCE.md)**
   - Essential commands at a glance
   - One-liners for common tasks
   - Service names and ports
   - Emergency commands

4. **[BACKUP_RECOVERY.md](./BACKUP_RECOVERY.md)**
   - Backup procedures and scripts
   - Recovery steps
   - Disaster recovery checklist
   - Automated backup setup

## Current Status (2025-08-07)
✅ Home Assistant: Running on Docker  
✅ MCP Server: Running on port 3000  
✅ Claude Desktop: Configured with hass-mcp  
✅ All services healthy and connected  

## Quick Health Check
```bash

docker ps | grep -E "(homeassistant|mcp)" && \
curl -s localhost:3000/health | jq .status && \
ps aux | grep hass-mcp | grep -v grep | wc -l | xargs -I {} echo "Claude MCP: {} process(es)"
```

## Support Information
- Home Assistant URL: http://192.168.3.20:8123
- MCP Server: http://localhost:3000
- Config Location: `~/Library/Application Support/Claude/claude_desktop_config.json`

## Getting Started
1. Read [HOME_ASSISTANT_MCP_SETUP.md](./HOME_ASSISTANT_MCP_SETUP.md) for full setup details
2. Keep [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) handy for daily use
3. Refer to [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) when issues arise
4. Set up backups using [BACKUP_RECOVERY.md](./BACKUP_RECOVERY.md)

---
*Documentation created for Home Assistant MCP integration with Claude Desktop*

---

## Readme Smart Home
*Source: README_SMART_HOME.md*

## Overview
This is a modern, best-practice Home Assistant configuration optimized for reliability and ease of use.

## 📁 Directory Structure
```
/mnt/docker/homeassistant/
├── configuration.yaml          # Main config (minimal)
├── secrets.yaml                # Sensitive data
├── packages/                   # Modular configurations
│   └── smart_home_essentials.yaml
├── dashboards/                 # Dashboard configurations
│   └── smart_home_main.yaml
├── automations/               # Advanced automations
├── scripts/                   # Custom scripts
└── custom_components/         # HACS integrations
```

## 🎛️ Core Features

### Dashboards
- **Main Dashboard** (`/dashboards/smart_home_main.yaml`)
  - Quick action buttons (Morning, Night, Away, Home)
  - Room-based controls
  - Energy monitoring
  - Security overview

### Automations & Scripts
- **Good Morning**: Brightens lights, turns off bedtime mode
- **Good Night**: Dims lights, turns off fans, activates bedtime
- **Away Mode**: Turns everything off, secures house
- **Welcome Home**: Restores comfortable lighting

### Helper Entities
- `input_boolean.bedtime_mode` - Tracks bedtime state
- `input_boolean.away_mode` - Tracks away state
- `input_boolean.guest_mode` - Disables auto-off when guests present
- `input_number.bedtime_brightness` - Adjustable bedtime dimming

## 🚀 Quick Start

### 1. Apply Dashboard
1. Go to **Settings → Dashboards**
2. Click **"+ Add Dashboard"**
3. Choose "Start with empty dashboard"
4. Name it "Smart Home"
5. Click 3-dot menu → **Raw configuration editor**
6. Paste contents of `/dashboards/smart_home_main.yaml`

### 2. Restart Home Assistant
```bash
docker restart homeassistant
```

### 3. Configure MQTT (for Meross devices)
1. Go to **Settings → Devices & Services**
2. Add Integration → MQTT
3. Enter: `localhost` port `1883`

## 🔧 Maintenance

### Daily Backups
Automated via Google Drive Backup add-on (configure in Supervisor)

### Check System Health
```bash

docker logs homeassistant --tail 50


docker exec homeassistant python -m homeassistant --script check_config
```

### Update Integrations
- **HACS**: Check weekly for updates
- **Core**: Update monthly after reading release notes

## 📝 Device Inventory

### Lights
- `light.hallway_main_lights` - Hallway
- `light.kitchen_main_lights` - Kitchen
- `light.primary_room_fan` - Primary Bedroom
- `light.office_ceiling_fan_light` - Office
- `light.ceiling_fan_down_light` - Fan Down Light
- `light.ceiling_fan_up_light` - Fan Up Light

### Fans
- `fan.ceiling_fan_2` - Living Room
- `fan.office_ceiling_fan` - Office
- `fan.primary_room_fan_2` - Primary Bedroom
- `fan.dyson_ceiling_fan` - Dyson

### Integration Types
- **ZHA**: Zigbee devices (lights, sensors)
- **MQTT**: Meross plugs (via Meross LAN)
- **UniFi**: Network devices
- **HACS**: Custom integrations

## 🐛 Troubleshooting

### Dashboard Not Loading
- Check for missing custom cards in HACS
- Validate YAML syntax
- Clear browser cache

### Devices Unavailable
- Check network connectivity
- Restart the integration
- Re-pair Zigbee devices if needed

### Automation Not Working
- Check traces in Automation editor
- Verify entity states
- Check conditions and time restrictions

## 📚 Next Steps

1. **Add presence detection** with phone GPS or room sensors
2. **Create adaptive lighting** that adjusts based on time
3. **Set up voice control** via Alexa/Google
4. **Add energy monitoring** for cost tracking
5. **Implement security cameras** with AI detection

---
Last Updated: August 2024
Version: 2.0

---

## Readme Validate
*Source: README_validate.md*

This is where the validation rules that run against the various repository categories live.

## Structure

- There is one file pr. rule.
- All rule needs tests to verify every possible outcome for the rule.
- It's better with multiple files than a big rule.
- All rules uses `ActionValidationBase` as the base class.
- Only use `validate` or `async_validate` methods to define validation rules.
- If a rule should fail, raise `ValidationException` with the failure message.


## Example

```python
from .base import (
    ActionValidationBase,
    ValidationBase,
    ValidationException,
)

class SuperAwesomeRepository(ActionValidationBase):
    category = "integration"

    async def async_validate(self):
        if self.repository != "super-awesome":
            raise ValidationException("The repository is not super-awesome")
```

---

