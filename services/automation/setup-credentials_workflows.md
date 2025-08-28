# n8n Credentials Setup Guide

This guide helps you set up credentials for the example workflows.

## 1. Home Assistant (Workflow #8)
**Credential Type**: Header Auth
- **Name**: Home Assistant
- **Header Name**: Authorization
- **Header Value**: Bearer YOUR_LONG_LIVED_ACCESS_TOKEN

To get token:
1. Go to Home Assistant profile
2. Create Long-Lived Access Token
3. Copy and use as header value

## 2. GitHub (Workflow #9)
**Credential Type**: Header Auth
- **Name**: GitHub Token
- **Header Name**: Authorization
- **Header Value**: token YOUR_GITHUB_PERSONAL_ACCESS_TOKEN

To get token:
1. Go to GitHub Settings > Developer settings
2. Personal access tokens > Generate new token
3. Select scopes: repo, workflow

## 3. Gmail OAuth2 (Workflow #11)
**Credential Type**: Gmail OAuth2
- Follow n8n's OAuth2 setup guide
- Enable Gmail API in Google Cloud Console
- Set redirect URL in Google OAuth config

## 4. OpenWeatherMap (Workflow #13)
**Credential Type**: OpenWeatherMap API
- **API Key**: Get from https://openweathermap.org/api
- Free tier includes 1000 calls/day

## 5. MQTT Broker (Workflow #14)
**Credential Type**: MQTT
- **Host**: Your MQTT broker address
- **Port**: 1883 (or 8883 for SSL)
- **Username/Password**: If required
- **Client ID**: n8n-client

## 6. Claude API (Already configured)
- Use the existing setup from workflow #6

## 7. Docker Access
No credentials needed - already configured via socket mount

## Setting Locations/Preferences

### Weather Automation (Workflow #13)
Edit the workflow to set your location:
- latitude: Your latitude
- longitude: Your longitude

### Home Assistant Webhook
Configure in Home Assistant:
```yaml
automation:
  - alias: "Send to n8n"
    trigger:
      - platform: state
        entity_id: sensor.temperature
    action:
      - service: webhook.send
        data:
          url: "http://YOUR_N8N_URL:5678/webhook/home-assistant-webhook"
          method: POST
          headers:
            content-type: application/json
          payload:
            event_type: "state_changed"
            event_data: "{{ trigger }}"
```

### GitHub Webhook
In your GitHub repository:
1. Settings > Webhooks > Add webhook
2. Payload URL: http://YOUR_N8N_URL:5678/webhook/github-webhook
3. Content type: application/json
4. Select events to trigger

## Testing Webhooks

### Test Claude Integration:
```bash
curl -X POST http://localhost:5678/webhook/ask-claude \
  -H "Content-Type: application/json" \
  -d '{"query": "Hello Claude!"}'
```

### Test Home Assistant:
```bash
curl -X POST http://localhost:5678/webhook/home-assistant-webhook \
  -H "Content-Type: application/json" \
  -d '{"event_type": "state_changed", "event_data": {"entity_id": "light.living_room", "new_state": {"state": "on"}}}'
```

### Test GitHub:
```bash
curl -X POST http://localhost:5678/webhook/github-webhook \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -d '{"ref": "refs/heads/main", "commits": [{"message": "Test commit"}]}'
```

## Security Best Practices

1. **Use environment variables** for sensitive credentials
2. **Rotate API keys** regularly
3. **Limit webhook access** with IP whitelisting if possible
4. **Use HTTPS** for production webhooks
5. **Monitor API usage** to detect anomalies

## Troubleshooting

- **Webhook not responding**: Check n8n logs and firewall rules
- **Authentication failing**: Verify credential format and API key validity
- **Rate limiting**: Check API provider limits and add delays
- **Connection refused**: Ensure services are running and ports are open