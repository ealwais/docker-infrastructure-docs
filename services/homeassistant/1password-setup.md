# 1Password Integration Setup for n8n

## Prerequisites

1. **Install 1Password CLI**:
```bash
# Download and install
curl -sS https://downloads.1password.com/linux/debian/amd64/stable/1password-cli-amd64-latest.deb -o op.deb
sudo dpkg -i op.deb

# Or via snap
sudo snap install 1password-cli
```

2. **Sign in to 1Password**:
```bash
# First time setup
op account add --address my.1password.com --email your@email.com

# Sign in
eval $(op signin)
```

## Workflow Features

### Workflow #16: 1Password Integration
- **Retrieve credentials** on demand via webhook
- **Get TOTP codes** for 2FA automation
- **Check credential age** and identify old passwords
- **Prepare service updates** with retrieved secrets

### Workflow #17: 1Password Secret Sync
- **Automatic sync** of secrets to environment files
- **Multi-service support**: Claude, GitHub, Docker, PostgreSQL, Gmail, OpenWeatherMap
- **Update .env files** automatically
- **Create Docker secrets** from 1Password items
- **Hourly sync** with error handling

## Setting Up Your 1Password Items

Create these items in 1Password for the workflows:

1. **Claude API**
   - Type: API Credential
   - Field: credential = your-claude-api-key

2. **GitHub Token**
   - Type: Login
   - Field: token = your-github-pat

3. **Docker Hub**
   - Type: Login
   - Username: your-docker-username
   - Password: your-docker-password

4. **PostgreSQL n8n**
   - Type: Database
   - Field: password = your-postgres-password

5. **Gmail App Password**
   - Type: Login
   - Field: password = your-gmail-app-password

6. **OpenWeatherMap API**
   - Type: API Credential
   - Field: api_key = your-openweather-key

## Usage Examples

### Retrieve a Credential:
```bash
curl -X POST http://localhost:5678/webhook/rotate-credentials \
  -H "Content-Type: application/json" \
  -d '{"item_name": "GitHub Token", "service": "github"}'
```

### Manual Secret Sync:
```bash
# Get secret from 1Password
op item get "Claude API" --fields credential

# Update n8n environment
op item get "Claude API" --fields credential > /tmp/secret && \
  sed -i "s|CLAUDE_API_KEY=.*|CLAUDE_API_KEY=$(cat /tmp/secret)|" /mnt/docker/n8n/.env && \
  rm /tmp/secret
```

## Security Best Practices

1. **Use biometric unlock** for 1Password CLI:
   ```bash
   op account add --shorthand myaccount --signin --biometric
   ```

2. **Set session timeout**:
   ```bash
   export OP_SESSION_TIMEOUT=300  # 5 minutes
   ```

3. **Restrict item access**: Create a separate vault for automation

4. **Audit logs**: Monitor 1Password activity logs

5. **Rotate service account**: Use a dedicated 1Password service account

## Automation Ideas

1. **Password Rotation**
   - Weekly check for passwords older than 90 days
   - Generate new passwords with 1Password
   - Update services automatically

2. **Certificate Management**
   - Store SSL certificates in 1Password
   - Auto-deploy before expiration
   - Update reverse proxies

3. **API Key Distribution**
   - Central storage in 1Password
   - Deploy to containers on startup
   - Revoke and rotate on schedule

4. **Team Credential Sharing**
   - Shared vaults for team secrets
   - Automated deployment to dev environments
   - Audit trail for compliance

## Troubleshooting

- **"not signed in" error**: Run `eval $(op signin)`
- **"item not found"**: Check item name and vault
- **Permission denied**: Ensure user has vault access
- **CLI not found**: Add to PATH: `export PATH=$PATH:/usr/local/bin`

## Docker Integration

To use 1Password CLI in n8n container:

```yaml
# Add to docker-compose.yml
volumes:
  - ~/.op:/home/node/.op  # Share 1Password config
  - ~/.config/op:/home/node/.config/op  # Share biometric config
```

Or install in container:
```bash
docker exec -it n8n sh -c "apk add --no-cache curl && \
  curl -sS https://downloads.1password.com/linux/alpine/stable/1password-cli-latest.tar.gz | \
  tar -xz -C /usr/local/bin"
```