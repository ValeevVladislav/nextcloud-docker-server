# Troubleshooting Guide

This guide contains basic troubleshooting steps for the Nextcloud Docker deployment.

## 1. Check Container Status

Start by checking the status of all services:

```bash
docker compose ps
```

Expected services:

- app
- db
- redis

If a container is stopped or restarting, check its logs.

## 2. Check Application Logs

View Nextcloud logs:

```bash
docker compose logs app
```

Follow logs in real time:

```bash
docker compose logs -f app
```

## 3. Check Database Logs

If Nextcloud cannot connect to the database:

```bash
docker compose logs db
```

Check that the database container is running:

```bash
docker compose ps db
```

## 4. Check Redis

Check the Redis container:

```bash
docker compose ps redis
```

View Redis logs:

```bash
docker compose logs redis
```

Test Redis from inside the container:

```bash
docker compose exec redis redis-cli ping
```

Expected response:

```text
PONG
```

## 5. Test the Web Service

Test Nextcloud from the Linux server:

```bash
curl -I http://localhost:8080
```

A working web server should return an HTTP response.

## 6. Check the Published Port

Check whether port 8080 is listening:

```bash
ss -lntp | grep 8080
```

## 7. Restart a Service

Restart only the affected service:

```bash
docker compose restart app
```

For example:

```bash
docker compose restart db
docker compose restart redis
```

## 8. Check Docker Resources

View container resource usage:

```bash
docker stats
```

Check disk usage:

```bash
df -h
```

Check Docker disk usage:

```bash
docker system df
```

## 9. Validate Docker Compose

If the Compose configuration was modified:

```bash
docker compose config
```

Fix any configuration errors before restarting the project.

## 10. General Troubleshooting Workflow

Use the following workflow when the service is unavailable:

```text
Nextcloud unavailable
        |
        v
docker compose ps
        |
        v
Are all containers running?
        |
     +--+--+
     |     |
    No    Yes
     |     |
     v     v
  logs   curl :8080
     |     |
     v     v
Find error  Check port/network
     |
     v
Fix configuration
     |
     v
Restart affected service
     |
     v
Verify again
```

## Important

Avoid deleting Docker volumes during troubleshooting unless you have a verified backup.

The following command removes persistent project volumes:

```bash
docker compose down -v
```

This may permanently delete application and database data.
