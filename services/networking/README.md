# n8n Docker Setup

This is a production-ready n8n setup with PostgreSQL, Redis, and optional Nginx reverse proxy.

## Components

- **n8n**: Workflow automation platform
- **PostgreSQL**: Database for storing workflows and credentials
- **Redis**: Queue management for scalable execution
- **Nginx**: (Optional) Reverse proxy with SSL support

## Quick Start

1. Run the setup script:
   ```bash
   ./setup.sh
   ```

2. Edit `.env` file to change default passwords

3. Start the services:
   ```bash
   # Development (without SSL)
   docker compose up -d

   # Production (with SSL)
   docker compose --profile production up -d
   ```

## Access

- Without Nginx: http://localhost:5678
- With Nginx: https://localhost
- Default credentials: admin / admin_password

## Directory Structure

```
.
├── data/           # n8n workflows and credentials
├── postgres-data/  # PostgreSQL data
├── redis-data/     # Redis persistence
├── custom-nodes/   # Custom n8n nodes
├── backups/        # Backup directory
└── nginx/          # Nginx configuration and SSL certificates
```

## Security Notes

1. **Change default passwords** in `.env` file
2. **Generate encryption key**: The setup script will do this automatically
3. **SSL certificates**: Add your certificates to `nginx/ssl/` for production
4. **Firewall**: Only expose necessary ports (80, 443, or 5678)

## Backup

To backup your workflows:
```bash
docker exec n8n n8n export:workflow --all --output=/backups/workflows_$(date +%Y%m%d).json
docker exec n8n n8n export:credentials --all --output=/backups/credentials_$(date +%Y%m%d).json
```

## Monitoring

Check service health:
```bash
docker compose ps
docker compose logs n8n
```

## Scaling

This setup uses queue mode with Redis, allowing you to scale n8n workers:
```bash
docker compose up -d --scale n8n=3
```

## Troubleshooting

- Check logs: `docker compose logs -f [service_name]`
- Restart services: `docker compose restart`
- Reset everything: `docker compose down -v` (WARNING: This deletes all data!)

## Custom Nodes

Place custom nodes in the `custom-nodes/` directory. They will be automatically loaded.