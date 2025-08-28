# Portainer Google SSO Integration Guide

## Overview
Configure Portainer to use Google Single Sign-On (SSO) for authentication across all your Docker environments.

## Prerequisites
1. Google Cloud Console access
2. Admin access to Portainer
3. Public URL or reverse proxy for Portainer (for OAuth callbacks)

## Step 1: Create Google OAuth Application

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select or create a project
3. Navigate to **APIs & Services** → **Credentials**
4. Click **Create Credentials** → **OAuth client ID**
5. Configure the OAuth consent screen if needed
6. Application type: **Web application**
7. Add authorized redirect URIs:
   ```
   https://192.168.3.11:9443/api/auth/oauth/google/callback
   https://192.168.3.20:9001/api/auth/oauth/google/callback
   ```
8. Save and note the **Client ID** and **Client Secret**

## Step 2: Configure Portainer (Primary - 192.168.3.11)

1. Login to Portainer at https://192.168.3.11:9443
2. Go to **Settings** → **Authentication**
3. Select **OAuth** 
4. Choose **Custom OAuth Provider**
5. Configure with these settings:

```yaml
Provider Name: Google
Client ID: <your-google-client-id>
Client Secret: <your-google-client-secret>
Authorization URL: https://accounts.google.com/o/oauth2/v2/auth
Access Token URL: https://oauth2.googleapis.com/token
Resource URL: https://openidconnect.googleapis.com/v1/userinfo
Redirect URL: https://192.168.3.11:9443/
User Identifier: email
Scopes: openid email profile
```

6. Enable **Auto create users** if desired
7. Set **Default team** for new users
8. Save settings

## Step 3: Configure Portainer (Mac Mini - 192.168.3.20)

Repeat Step 2 for the Mac Mini Portainer instance at http://192.168.3.20:9001

## Step 4: Configure Home Assistant Integration

Add to `/config/configuration.yaml`:

```yaml
# Google SSO iframe integration
iframe_panel:
  portainer_primary:
    title: "Docker Server"
    icon: mdi:docker
    url: "https://192.168.3.11:9443"
    require_admin: true
    
  portainer_backup:
    title: "Mac Mini Docker"
    icon: mdi:apple
    url: "http://192.168.3.20:9001"
    require_admin: true
```

## Step 5: Alternative - Use Home Assistant as OAuth Provider

If you want to use Home Assistant as the SSO provider instead:

1. Install the **Home Assistant OAuth Provider** custom component via HACS
2. Configure OAuth in Portainer to use:
   ```
   Authorization URL: http://192.168.3.20:8123/auth/oauth2/authorize
   Token URL: http://192.168.3.20:8123/auth/oauth2/token
   Resource URL: http://192.168.3.20:8123/auth/oauth2/userinfo
   ```

## Step 6: Test SSO Login

1. Logout of Portainer
2. Click "Login with Google" (or your configured provider)
3. Authenticate with Google
4. You should be redirected back to Portainer logged in

## Security Considerations

1. **Internal Network Only**: These IPs are internal. For external access, use a reverse proxy with proper SSL
2. **User Permissions**: Configure teams and roles in Portainer for proper access control
3. **Token Expiry**: Google tokens expire - Portainer will handle refresh automatically

## Troubleshooting

### SSL Certificate Issues
If you get SSL errors with self-signed certificates:
1. Add certificate exceptions in your browser
2. Or use a reverse proxy with Let's Encrypt certificates

### Callback URL Mismatch
Ensure the callback URL in Google Console exactly matches Portainer's URL including protocol and port

### User Creation Failed
Check Portainer logs:
```bash
docker logs portainer
```

## Benefits of SSO Integration

1. **Single Login**: Use Google account across all Portainer instances
2. **No Password Management**: No need to manage Portainer-specific passwords
3. **Centralized Access Control**: Manage access via Google Workspace
4. **Audit Trail**: Google provides login audit logs
5. **2FA Support**: Inherits Google's 2FA if enabled