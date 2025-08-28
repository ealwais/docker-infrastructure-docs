# Nginx Proxy Manager Setup for AdGuard Home

## Overview
Your Nginx Proxy Manager is running at: http://192.168.3.11:81

## Setup Instructions

### Option 1: Using Nginx Proxy Manager GUI

1. Access Nginx Proxy Manager at http://192.168.3.11:81/login

2. Add a new Proxy Host:
   - **Domain Names**: `adguard.alwais.org`
   - **Scheme**: `http`
   - **Forward Hostname/IP**: `adguard-home`
   - **Forward Port**: `3000`
   - **Block Common Exploits**: ✓
   - **Websockets Support**: ✓

3. SSL Configuration:
   - **SSL Certificate**: Request new Let's Encrypt certificate
   - **Force SSL**: ✓
   - **HSTS Enabled**: ✓
   - **HSTS Subdomains**: ✓
   - **HTTP/2 Support**: ✓

4. Advanced Configuration (Custom Nginx Configuration):
   ```nginx
   # API access for N8N - allow internal networks without auth
   location /control/ {
       allow 192.168.0.0/16;
       allow 172.16.0.0/12;
       allow 10.0.0.0/8;
       deny all;
       
       proxy_set_header Accept 'application/json';
       limit_req off;
       limit_conn off;
   }
   ```

### Option 2: Manual Configuration File

If you prefer to manually add the configuration:

1. Copy the config file to your nginx container:
   ```bash
   docker cp /mnt/docker/adguard/nginx-adguard.conf nginx:/data/nginx/proxy_host/
   ```

2. Or create via the GUI with these settings:
   - Use the configuration from `nginx-adguard.conf`
   - Ensure the container names can resolve (both on same Docker network)

## Network Configuration

Ensure both containers are on the same Docker network:

```bash
# Check nginx network
docker inspect nginx | grep -A 5 Networks

# Check adguard network  
docker inspect adguard-home | grep -A 5 Networks

# If needed, connect adguard to nginx's network
docker network connect nginx_default adguard-home
```

## Testing the Setup

1. **Test DNS resolution inside nginx container:**
   ```bash
   docker exec nginx ping adguard-home
   ```

2. **Test from browser:**
   - https://adguard.alwais.org (should redirect to HTTPS)
   - Login with admin credentials

3. **Test N8N API access:**
   ```bash
   curl -X GET http://adguard.alwais.org/control/status
   ```

## Troubleshooting

### Cannot resolve adguard-home
- Ensure both containers are on the same Docker network
- Try using the container IP instead of hostname
- Check if the proxy network is external in docker-compose.yml

### 502 Bad Gateway
- Verify AdGuard is running: `docker ps | grep adguard`
- Check AdGuard logs: `docker logs adguard-home`
- Ensure port 3000 is correct

### SSL Certificate Issues
- Ensure domain points to your public IP
- Ports 80 and 443 must be accessible from internet for Let's Encrypt
- Check Nginx Proxy Manager logs for cert errors
- If using Cloudflare, ensure SSL/TLS mode is set to "Full" or "Full (strict)"