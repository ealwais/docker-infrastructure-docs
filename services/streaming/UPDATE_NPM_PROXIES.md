# NPM Proxy Updates Required

## Container Changes
Since we've migrated to the consolidated stack, update your NPM proxy hosts:

### 1. Update `xteve.alwais.org`
**Current:** Points to `192.168.3.11:34400` or old container
**Change to:** 
- **Forward Hostname/IP:** `xteve-streaming` (container name) or `172.30.0.X` (container IP)
- **Forward Port:** `34400`

### 2. Create `msnbc.alwais.org` 
**New proxy host for streaming:**
- **Forward Hostname/IP:** `xteve-streaming`
- **Forward Port:** `34401`
- **Custom Nginx Config:**
```nginx
# Streaming optimizations
proxy_connect_timeout 3600;
proxy_send_timeout 3600;
proxy_read_timeout 3600;
send_timeout 3600;

# Disable buffering for live streams
proxy_buffering off;
proxy_cache off;

# Large buffer sizes
proxy_buffer_size 256k;
proxy_buffers 8 512k;
proxy_busy_buffers_size 512k;

# Headers
proxy_http_version 1.1;
proxy_set_header Connection "";
proxy_set_header Accept-Encoding "";

# CORS
add_header 'Access-Control-Allow-Origin' '*' always;
```

### 3. Update `plex.alwais.org`
**Current:** Points to `192.168.3.11:32400`
**Keep as is** - Plex is using host networking, so the IP remains the same

## How to Update in NPM:

1. **Access NPM:** http://192.168.253.51:81 (or your existing NPM)
2. **Edit `xteve.alwais.org`:**
   - Click the proxy host
   - Change Forward Hostname to `xteve-streaming`
   - Save

3. **Add `msnbc.alwais.org`:**
   - Add Proxy Host
   - Domain: `msnbc.alwais.org`
   - Forward to: `xteve-streaming:34401`
   - Add custom Nginx config above
   - Request SSL certificate

## Test URLs:
- https://xteve.alwais.org (Xteve management)
- https://msnbc.alwais.org/stream/215 (MSNBC stream)
- https://plex.alwais.org (Plex interface)

## Container IP Addresses (if needed):
You can find the exact IP of xteve-streaming:
```bash
docker inspect xteve-streaming | grep IPAddress
```

## Verify Connectivity:
Test from NPM container to xteve:
```bash
docker exec nginx-proxy-manager ping xteve-streaming
```