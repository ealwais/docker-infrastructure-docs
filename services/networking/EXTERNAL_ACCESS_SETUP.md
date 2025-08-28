# Home Assistant External Access Setup Guide

## Current Status
- **Domain**: home.alwais.org
- **Your External IP**: 136.62.122.180
- **Current DNS**: Pointing to Cloudflare proxy (104.21.12.174, 172.67.152.215)
- **Local Access**: http://192.168.3.20:8123 ✅
- **External Access**: ❌ Not configured

## Options for External Access

### Option 1: Cloudflare Tunnel (Recommended - Most Secure)
No port forwarding required!

1. **Install Cloudflare Tunnel Add-on**:
   ```bash
   # In Home Assistant UI:
   # Settings → Add-ons → Add-on Store → Search "Cloudflare"
   # Install "Cloudflare Tunnel"
   ```

2. **Configure Cloudflare Tunnel**:
   - Get a tunnel token from: https://one.dash.cloudflare.com
   - Add to Add-on configuration:
   ```yaml
   tunnel_token: "YOUR_TUNNEL_TOKEN"
   ```

3. **No router changes needed!**

### Option 2: Direct Access with Port Forwarding

1. **Configure HTTP settings** in configuration.yaml:
   ```yaml
   http:
     use_x_forwarded_for: true
     trusted_proxies:
       - 172.30.33.0/24  # Docker network
       - 127.0.0.1
     ip_ban_enabled: true
     login_attempts_threshold: 5
   ```

2. **Router Port Forwarding**:
   - Forward external port 8123 → 192.168.3.20:8123
   - Or use 443 (HTTPS) → 192.168.3.20:8123

3. **Update Cloudflare DNS**:
   - Turn OFF proxy (orange cloud → gray cloud) for home.alwais.org
   - Or create a new subdomain like `direct-home.alwais.org`

4. **Configure SSL** (required for external access):
   - Use Let's Encrypt add-on
   - Or Cloudflare Origin Certificate

### Option 3: VPN Access (Most Secure)
Since you have `vpn.alwais.org`:

1. **Use existing VPN** to connect to home network
2. **Access locally** via http://192.168.3.20:8123
3. **No HA configuration needed**

## Quick Setup for Cloudflare Tunnel

```bash
# 1. Check if Supervisor add-ons are available
docker exec homeassistant ha addons list

# If not available, install HACS Cloudflare integration:
# HACS → Integrations → Search "Cloudflare Tunnel"
```

## Security Considerations

### If Using Direct Access:
1. **Always use HTTPS** (never HTTP over internet)
2. **Enable IP banning**
3. **Use strong passwords**
4. **Enable 2FA** in Home Assistant
5. **Restrict access** to specific IPs if possible

### Current Issues to Fix:
1. ❌ No SSL certificate configured
2. ❌ No external URL configured
3. ❌ Cloudflare DNS not pointing to your IP
4. ❌ No port forwarding set up

## Step-by-Step for Cloudflare Tunnel (Easiest)

1. **Login to Cloudflare Dashboard**
   - Go to: https://dash.cloudflare.com
   - Select your domain: alwais.org

2. **Create a Tunnel**
   - Zero Trust → Access → Tunnels
   - Create a tunnel
   - Name it: "HomeAssistant"
   - Save the token

3. **Install in Home Assistant**
   ```bash
   # Since you're using Docker without Supervisor, 
   # run Cloudflare Tunnel in a separate container:
   
   docker run -d \
     --name cloudflared \
     --restart unless-stopped \
     --network host \
     cloudflare/cloudflared:latest tunnel \
     --no-autoupdate run \
     --token YOUR_TUNNEL_TOKEN
   ```

4. **Configure Public Hostname**
   - In Cloudflare Dashboard
   - Public Hostname: home.alwais.org
   - Service: http://localhost:8123

## Alternative: Using Your Existing Setup

Since you already have Cloudflare integration configured:

1. **Check current IP setting**:
   ```bash
   # This will show if Cloudflare is updating your IP
   docker logs homeassistant 2>&1 | grep -i cloudflare | tail -10
   ```

2. **For direct access**, you need:
   - Disable Cloudflare proxy for home.alwais.org
   - Set up port forwarding on your router
   - Configure SSL certificate

## Testing External Access

1. **From outside network** (use mobile data):
   ```bash
   # Test DNS
   nslookup home.alwais.org
   
   # Test connection
   curl -I https://home.alwais.org:8123
   ```

2. **Check HA logs**:
   ```bash
   docker logs homeassistant -f | grep "Login attempt"
   ```

## Recommended Next Steps

1. **Easiest**: Set up Cloudflare Tunnel (no port forwarding needed)
2. **Most Secure**: Use your VPN at vpn.alwais.org
3. **Traditional**: Port forwarding + Let's Encrypt SSL

Would you like me to help you set up one of these methods?