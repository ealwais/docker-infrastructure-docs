# NGINX Proxy Manager Configuration Guide

## Initial Setup

1. Access NPM admin panel at `http://your-server-ip:81`
2. Default credentials:
   - Email: `admin@example.com`
   - Password: `changeme`
3. Change these credentials immediately after first login

## Proxy Host Configuration

### 1. Xteve Management Interface Proxy

**Domain/Subdomain:** `xteve.alwais.org`

**Proxy Host Settings:**
- **Scheme:** `http`
- **Forward Hostname/IP:** `xteve` (container name)
- **Forward Port:** `34400`
- **Cache Assets:** ✓ Enabled
- **Block Common Exploits:** ✓ Enabled
- **Websockets Support:** ✓ Enabled

**SSL Configuration:**
- **SSL Certificate:** Request a new SSL certificate
- **Force SSL:** ✓ Enabled
- **HTTP/2 Support:** ✓ Enabled
- **HSTS Enabled:** ✓ Enabled
- **HSTS Subdomains:** ✓ Enabled

**Custom Nginx Configuration:**
```nginx
# Increase timeouts for streaming
proxy_connect_timeout 600;
proxy_send_timeout 600;
proxy_read_timeout 600;
send_timeout 600;

# Increase buffer sizes
proxy_buffer_size 4k;
proxy_buffers 8 16k;
proxy_busy_buffers_size 32k;

# Headers for Xteve
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
```

### 2. MSNBC Stream Proxy (Channel 215)

**Domain/Subdomain:** `msnbc.alwais.org`

**Proxy Host Settings:**
- **Scheme:** `http`
- **Forward Hostname/IP:** `xteve`
- **Forward Port:** `34401`
- **Cache Assets:** ✗ Disabled (important for live streams)
- **Block Common Exploits:** ✓ Enabled
- **Websockets Support:** ✓ Enabled

**SSL Configuration:**
- **SSL Certificate:** Request a new SSL certificate
- **Force SSL:** ✓ Enabled
- **HTTP/2 Support:** ✓ Enabled

**Custom Nginx Configuration:**
```nginx
# Streaming optimizations
proxy_connect_timeout 3600;
proxy_send_timeout 3600;
proxy_read_timeout 3600;
send_timeout 3600;

# Disable buffering for live streams
proxy_buffering off;
proxy_cache off;
proxy_set_header Connection "";

# Large buffer sizes for streaming
proxy_buffer_size 256k;
proxy_buffers 8 512k;
proxy_busy_buffers_size 512k;

# Headers
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;

# Handle streaming content types
proxy_set_header Accept-Encoding "";
proxy_http_version 1.1;

# CORS headers if needed
add_header 'Access-Control-Allow-Origin' '*' always;
add_header 'Access-Control-Allow-Methods' 'GET, OPTIONS' always;
add_header 'Access-Control-Allow-Headers' 'Range' always;
add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range' always;

# Handle OPTIONS requests
if ($request_method = 'OPTIONS') {
    add_header 'Access-Control-Allow-Origin' '*';
    add_header 'Access-Control-Allow-Methods' 'GET, OPTIONS';
    add_header 'Access-Control-Max-Age' 1728000;
    add_header 'Content-Type' 'text/plain; charset=utf-8';
    add_header 'Content-Length' 0;
    return 204;
}
```

### 3. Stream-Specific Location for MSNBC

For direct MSNBC stream access, add this custom location:

**Domain/Subdomain:** `msnbc.alwais.org`
**Custom Locations:**

```nginx
location /msnbc {
    proxy_pass http://xteve:34401/stream/215;
    
    # Streaming headers
    proxy_http_version 1.1;
    proxy_set_header Connection "";
    proxy_buffering off;
    proxy_cache off;
    
    # Timeouts
    proxy_connect_timeout 3600;
    proxy_send_timeout 3600;
    proxy_read_timeout 3600;
    
    # Content type
    add_header Content-Type "video/mp2t";
    
    # CORS
    add_header 'Access-Control-Allow-Origin' '*' always;
}

location /msnbc.m3u8 {
    proxy_pass http://xteve:34401/playlist/215.m3u8;
    
    # M3U8 specific headers
    add_header Content-Type "application/vnd.apple.mpegurl";
    proxy_buffering off;
    
    # CORS
    add_header 'Access-Control-Allow-Origin' '*' always;
}
```

### 4. Plex Media Server Proxy

**Domain/Subdomain:** `plex.alwais.org`

**Proxy Host Settings:**
- **Scheme:** `http`
- **Forward Hostname/IP:** `your-server-ip` (use actual server IP since Plex uses host networking)
- **Forward Port:** `32400`
- **Cache Assets:** ✓ Enabled
- **Block Common Exploits:** ✓ Enabled
- **Websockets Support:** ✓ Enabled

**SSL Configuration:**
- **SSL Certificate:** Request a new SSL certificate
- **Force SSL:** ✓ Enabled
- **HTTP/2 Support:** ✓ Enabled

**Custom Nginx Configuration:**
```nginx
# Plex specific headers
proxy_set_header X-Plex-Client-Identifier $http_x_plex_client_identifier;
proxy_set_header X-Plex-Device $http_x_plex_device;
proxy_set_header X-Plex-Device-Name $http_x_plex_device_name;
proxy_set_header X-Plex-Platform $http_x_plex_platform;
proxy_set_header X-Plex-Platform-Version $http_x_plex_platform_version;
proxy_set_header X-Plex-Product $http_x_plex_product;
proxy_set_header X-Plex-Token $http_x_plex_token;
proxy_set_header X-Plex-Version $http_x_plex_version;
proxy_set_header X-Plex-Nocache $http_x_plex_nocache;
proxy_set_header X-Plex-Provides $http_x_plex_provides;
proxy_set_header X-Plex-Device-Vendor $http_x_plex_device_vendor;
proxy_set_header X-Plex-Model $http_x_plex_model;

# Websockets
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";

# Buffering
proxy_buffering off;
client_max_body_size 100M;

# Timeouts
proxy_connect_timeout 600;
proxy_send_timeout 600;
proxy_read_timeout 600;
send_timeout 600;
```

## Access URLs After Configuration

- **Xteve Management:** `https://xteve.alwais.org`
- **MSNBC Stream (Direct):** `https://msnbc.alwais.org/msnbc`
- **MSNBC Stream (M3U8):** `https://msnbc.alwais.org/msnbc.m3u8`
- **Plex Media Server:** `https://plex.alwais.org`

## Testing the Configuration

1. **Test Xteve Management Access:**
```bash
curl -I https://xteve.alwais.org
```

2. **Test MSNBC Stream:**
```bash
# Test stream availability
curl -I https://msnbc.alwais.org/msnbc

# Test with VLC
vlc https://msnbc.alwais.org/msnbc.m3u8
```

3. **Test Plex Access:**
```bash
curl -I https://plex.alwais.org
```

4. **Test SSL Certificates:**
```bash
openssl s_client -connect xteve.alwais.org:443 -servername xteve.alwais.org
openssl s_client -connect msnbc.alwais.org:443 -servername msnbc.alwais.org
openssl s_client -connect plex.alwais.org:443 -servername plex.alwais.org
```

## Troubleshooting

### Common Issues:

1. **502 Bad Gateway:**
   - Check if Xteve container is running: `docker ps | grep xteve`
   - Verify network connectivity: `docker exec npm ping xteve`

2. **Stream Buffering Issues:**
   - Increase buffer sizes in NPM custom configuration
   - Check Xteve buffer settings

3. **SSL Certificate Issues:**
   - Ensure ports 80 and 443 are open in firewall
   - Check DNS records point to correct IP

4. **Authentication Issues:**
   - Xteve authentication is disabled by default in this setup
   - If enabled, add authentication headers in NPM configuration

## Security Recommendations

1. **Restrict Access:**
   - Add IP whitelist in NPM Access Lists
   - Use Basic Authentication for management interface

2. **Rate Limiting:**
```nginx
limit_req_zone $binary_remote_addr zone=stream:10m rate=10r/s;

location /msnbc {
    limit_req zone=stream burst=20 nodelay;
    # ... rest of configuration
}
```

3. **Monitoring:**
   - Enable NPM audit log
   - Monitor access logs: `docker logs npm`
   - Set up fail2ban for repeated failed attempts