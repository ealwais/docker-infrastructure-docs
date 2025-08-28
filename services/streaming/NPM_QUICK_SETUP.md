# NPM Quick Setup Guide for alwais.org Domains

## Summary of Proxy Hosts to Create

You need to create **3 proxy hosts** in NPM:

### 1. Xteve Management - `xteve.alwais.org`
- **Forward to:** `xteve` port `34400`
- **Purpose:** Xteve web interface for configuration

### 2. MSNBC Stream - `msnbc.alwais.org`  
- **Forward to:** `xteve` port `34401`
- **Purpose:** Buffered MSNBC stream endpoint

### 3. Plex Media Server - `plex.alwais.org`
- **Forward to:** `[your-server-IP]` port `32400`
- **Purpose:** Plex web interface (Note: Use actual server IP, not container name since Plex uses host networking)

## Step-by-Step Setup

### Access NPM Admin Panel
1. Navigate to `http://your-server-ip:81`
2. Login (default: admin@example.com / changeme)
3. Change password immediately

### For Each Domain Above:

1. Click **"Add Proxy Host"**

2. **Details Tab:**
   - Domain Names: Enter the domain (e.g., `xteve.alwais.org`)
   - Scheme: `http`
   - Forward Hostname/IP: As specified above
   - Forward Port: As specified above
   - ✓ Cache Assets (except for msnbc.alwais.org)
   - ✓ Block Common Exploits
   - ✓ Websockets Support

3. **SSL Tab:**
   - SSL Certificate: "Request a new SSL certificate"
   - ✓ Force SSL
   - ✓ HTTP/2 Support
   - ✓ HSTS Enabled
   - ✓ HSTS Subdomains
   - Email: Your email for Let's Encrypt
   - ✓ I Agree to Terms

4. **Save**

## Important Notes

- For `plex.alwais.org`, replace `[your-server-IP]` with your actual server IP address (e.g., 192.168.1.100)
- Ensure DNS A records point all three domains to your server's public IP
- Ports 80 and 443 must be open and forwarded to your server
- Let's Encrypt certificates will auto-renew every 90 days

## Quick Test Commands

After setup, test each domain:

```bash
# Test Xteve management
curl -I https://xteve.alwais.org

# Test MSNBC stream
curl -I https://msnbc.alwais.org/msnbc

# Test Plex
curl -I https://plex.alwais.org
```

## DNS Requirements

Ensure these DNS A records exist:
```
xteve.alwais.org    → Your-Server-Public-IP
msnbc.alwais.org    → Your-Server-Public-IP  
plex.alwais.org     → Your-Server-Public-IP
```