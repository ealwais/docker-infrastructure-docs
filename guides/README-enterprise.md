# Enterprise HEVC Conversion Service

Production-grade video conversion service with distributed processing, monitoring, and alerting.

## Features

### Core Components
- **Redis**: Job queue and result backend
- **Celery**: Distributed task processing
- **Prometheus**: Metrics collection
- **Grafana**: Visualization dashboards
- **AlertManager**: Alert routing and notifications
- **Flask API**: REST API for control and monitoring

### Capabilities
- Distributed processing across multiple workers
- Real-time GPU and system metrics
- Automatic failure recovery and retries
- Queue management (pause/resume/purge)
- Health checks and alerting
- Horizontal scaling support

## Quick Start

```bash
# Start all services
docker-compose -f docker-compose-enterprise.yml up -d

# Check status
docker-compose -f docker-compose-enterprise.yml ps

# View logs
docker-compose -f docker-compose-enterprise.yml logs -f hevc-worker

# Scale workers
docker-compose -f docker-compose-enterprise.yml up -d --scale hevc-worker=3
```

## Service URLs

- **API**: http://localhost:8000
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin)
- **AlertManager**: http://localhost:9093

## API Endpoints

### Health Check
```bash
curl http://localhost:8000/health
```

### Get Statistics
```bash
curl http://localhost:8000/stats
```

### Check File Status
```bash
curl http://localhost:8000/status/path/to/file.mp4
```

### Queue Management
```bash
# List queue
curl http://localhost:8000/queue

# Add to queue
curl -X POST http://localhost:8000/queue \
  -H "Content-Type: application/json" \
  -d '{"filepath": "/data/movie.mp4"}'

# Pause processing
curl -X POST http://localhost:8000/queue/control \
  -H "Content-Type: application/json" \
  -d '{"action": "pause"}'
```

## Monitoring

### Grafana Dashboard
1. Access http://localhost:3000
2. Login with admin/admin
3. Import provided dashboards from `grafana-dashboards/`

### Prometheus Queries
- Active conversions: `hevc_active_conversions`
- Queue size: `hevc_queue_size`
- GPU encoder usage: `hevc_gpu_encoder_utilization_percent`
- Conversion rate: `rate(hevc_conversions_total[5m])`
- Space saved: `hevc_bytes_saved_total`

## Alerts

Configured alerts include:
- GPU encoder saturation (>95%)
- High failure rate (>10%)
- Queue backup (>1000 files)
- No active workers
- Low disk space (<10%)

## Configuration

Edit `.env` file:
```env
# Redis
REDIS_URL=redis://redis:6379/0

# Workers
MAX_CONCURRENT_JOBS=8
GPU_ENCODER_THRESHOLD=90
GPU_UTIL_THRESHOLD=80
IOWAIT_THRESHOLD=20

# Alerts
ALERT_EMAIL=admin@example.com
SMTP_HOST=smtp.example.com
SMTP_PORT=587
```

## Scaling

### Add More Workers
```bash
docker-compose -f docker-compose-enterprise.yml up -d --scale hevc-worker=5
```

### Multi-GPU Setup
1. Edit docker-compose to add GPU mapping
2. Modify worker to distribute across GPUs
3. Update metrics for multi-GPU monitoring

## Troubleshooting

### Check Worker Status
```bash
docker exec hevc-worker celery -A hevc_tasks inspect active
```

### Clear Failed Jobs
```bash
docker exec hevc-worker celery -A hevc_tasks purge
```

### Reset State
```bash
rm upgrade/upgrade_state.pkl
docker-compose -f docker-compose-enterprise.yml restart hevc-worker
```