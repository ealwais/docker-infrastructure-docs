# API Keys Setup Guide

This guide will help you obtain and configure all the missing API keys in your secrets.yaml file.

## Priority 1: Essential Services

### 1. Telegram Bot (For Notifications)
**Get your API key:**
1. Open Telegram and search for `@BotFather`
2. Send `/newbot` to create a new bot
3. Choose a name for your bot (e.g., "My Home Assistant")
4. Choose a username ending in `bot` (e.g., "myhomeassistant_bot")
5. Copy the token that looks like: `1234567890:ABCdefGHIjklMNOpqrsTUVwxyz`

**Get your chat ID:**
1. Send a message to your new bot
2. Visit: `https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates`
3. Find your chat ID in the response (usually a number like `123456789`)

**Update secrets.yaml:**
```yaml
telegram_bot_api_key: "1234567890:ABCdefGHIjklMNOpqrsTUVwxyz"
telegram_chat_id: "123456789"
```

### 2. OpenWeather API (For Weather Data)
**Get your API key:**
1. Go to https://openweathermap.org/api
2. Sign up for a free account
3. Go to "API keys" in your account
4. Generate a new API key
5. Copy the key (looks like: `a1b2c3d4e5f6g7h8i9j0`)

**Update secrets.yaml:**
```yaml
openweather_api_key: "a1b2c3d4e5f6g7h8i9j0"
```

## Priority 2: Media Server Integration

### 3. Plex Token
**Get your token:**
1. Sign in to Plex Web App
2. Browse to a library item (movie/show)
3. Click "..." → "Get Info" → "View XML"
4. Check the URL for `X-Plex-Token=` parameter
5. Copy the token value

**Alternative method:**
```bash
curl -X POST https://plex.tv/users/sign_in.json \
  -H 'Content-Type: application/json' \
  -d '{"user": {"login": "YOUR_EMAIL", "password": "YOUR_PASSWORD"}}'
```

**Update secrets.yaml:**
```yaml
plex_token: "your_actual_plex_token"
```

### 4. Radarr API Key
**Get your API key:**
1. Open Radarr web interface
2. Go to Settings → General
3. Copy the API Key

**Update secrets.yaml:**
```yaml
radarr_api_key: "your_radarr_api_key_32_chars"
```

### 5. Sonarr API Key
**Get your API key:**
1. Open Sonarr web interface
2. Go to Settings → General
3. Copy the API Key

**Update secrets.yaml:**
```yaml
sonarr_api_key: "your_sonarr_api_key_32_chars"
```

### 6. SABnzbd API Key
**Get your API key:**
1. Open SABnzbd web interface
2. Go to Config → General
3. Copy the API Key

**Update secrets.yaml:**
```yaml
sabnzbd_api_key: "your_sabnzbd_api_key"
```

### 7. Overseerr API Key
**Get your API key:**
1. Open Overseerr web interface
2. Go to Settings → General
3. Copy the API Key

**Update secrets.yaml:**
```yaml
overseerr_api_key: "your_overseerr_api_key"
```

## Priority 3: NAS Access

### 8. Synology Credentials
**Setup:**
1. Create a dedicated user for Home Assistant in DSM
2. Grant necessary permissions (read access to folders)
3. Enable 2FA if needed

**Update secrets.yaml:**
```yaml
synology_username: "homeassistant"
synology_password: "your_secure_password"
```

### 9. QNAP Credentials
**Setup:**
1. Create a dedicated user in QNAP
2. Grant SSH access if needed for monitoring
3. Set appropriate permissions

**Update secrets.yaml:**
```yaml
qnap_username: "homeassistant"
qnap_password: "your_secure_password"
```

## Priority 4: Optional Services

### 10. Aqara Gateway Key (If using local control)
**Get your key:**
1. Enable developer mode on Aqara Gateway
2. Find the key in Mi Home app
3. Or use the gateway's web interface

**Update secrets.yaml:**
```yaml
aqara_key: "your_16_character_key"
```

### 11. MQTT Credentials (If using authentication)
**Setup:**
1. Configure mosquitto with authentication
2. Create a user for Home Assistant

**Update secrets.yaml:**
```yaml
mqtt_username: "homeassistant"
mqtt_password: "your_mqtt_password"
```

## Quick Commands to Test Services

After updating secrets.yaml:

```bash
# Restart Home Assistant
docker restart homeassistant

# Test Telegram
curl -X POST "https://api.telegram.org/bot<YOUR_TOKEN>/sendMessage" \
  -d "chat_id=<YOUR_CHAT_ID>&text=Test from Home Assistant"

# Test OpenWeather
curl "https://api.openweathermap.org/data/2.5/weather?q=Chicago&appid=<YOUR_API_KEY>"
```

## Security Notes
- Never commit secrets.yaml to git
- Use strong, unique passwords for each service
- Consider using a password manager
- Rotate API keys periodically
- Monitor for unauthorized access