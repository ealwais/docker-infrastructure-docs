# AdGuard Home Docker Setup

## Quick Start

1. **Deploy AdGuard Home:**
   ```bash
   sudo ./deploy.sh
   ```

2. **Access the web interface:**
   - Direct: http://your-server-ip:3000
   - Via proxy: https://adguard.alwais.org (SSL secured)

3. **Configure your devices to use AdGuard DNS:**
   - DNS Server: your-server-ip port 53

## Files Overview

- `docker-compose.yml` - Container configuration
- `config/AdGuardHome.yaml` - Main configuration file
- `nginx-adguard.conf` - Nginx proxy configuration
- `deploy.sh` - Automated deployment script
- `backup.sh` - Configuration backup script

## Configuration

### Local DNS Entries

Pre-configured DNS rewrites for local services:
- `plex.alwais.org` → nginx proxy
- `xteve.alwais.org` → nginx proxy
- `adguard.alwais.org` → nginx proxy
- `fbs.alwais.org` → nginx proxy

### API Access

The REST API is available at:
- Internal: http://adguard-home:3000/control/
- External: http://adguard.alwais.org/control/

Key endpoints:
- `/control/status` - Service status
- `/control/dns_info` - DNS configuration
- `/control/rewrite/list` - List DNS rewrites
- `/control/rewrite/add` - Add DNS rewrite
- `/control/rewrite/delete` - Remove DNS rewrite

### Performance Features

- **Ramdisk cache** at `/mnt/ramdisk/adguard-cache`
- **Memory limit**: 1GB (512MB reserved)
- **DNS cache**: 4MB optimized cache
- **Parallel upstream queries** for fastest response

## Maintenance

### Backup Configuration

Run manual backup:
```bash
./backup.sh
```

Schedule automatic daily backups:
```bash
crontab -e
# Add: 0 2 * * * /mnt/docker/adguard/backup.sh >> /mnt/docker/backups/adguard/backup.log 2>&1
```

### View Logs

```bash
# Container logs
docker logs -f adguard-home

# DNS query logs (if enabled)
docker exec adguard-home tail -f /opt/adguardhome/logs/querylog.json
```

### Update Container

```bash
cd /mnt/docker/adguard
docker-compose pull
docker-compose up -d
```

## Troubleshooting

### Check container status:
```bash
docker ps | grep adguard
docker exec adguard-home wget -q --spider http://localhost:3000 && echo "AdGuard is running"
```

### Reset admin password:
```bash
docker exec -it adguard-home /opt/adguardhome/AdGuardHome -s stop
docker exec -it adguard-home /opt/adguardhome/AdGuardHome --reset-password
docker restart adguard-home
```

### Verify DNS resolution:
```bash
# Test local DNS
dig @your-server-ip plex.alwais.org

# Test upstream DNS
dig @your-server-ip google.com
```

## Security Notes

- Container runs as user 1000:1000 (EAlwais)
- Minimal capabilities (NET_BIND_SERVICE only)
- API access restricted to internal network
- Admin interface protected by SSL/TLS encryption
- Two nginx configs available:
  - `nginx-adguard.conf` - Standard SSL setup
  - `nginx-adguard-auth.conf` - SSL + optional basic auth + internal API access

### SSL Certificate Configuration

The nginx configuration expects Let's Encrypt certificates at:
- Certificate: `/etc/letsencrypt/live/alwais.org/fullchain.pem`
- Private Key: `/etc/letsencrypt/live/alwais.org/privkey.pem`

If your certificates are in a different location, update the paths in the nginx config.