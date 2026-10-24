# Production Notes

This Docker Compose configuration is suitable as a foundation for a self-hosted Nextcloud deployment, but additional steps should be taken before exposing it to the Internet.

## HTTPS and Reverse Proxy

Do not expose a production Nextcloud instance directly over plain HTTP.

Use a reverse proxy such as:

- Nginx
- Traefik
- Caddy

The reverse proxy should terminate TLS and forward traffic to the Nextcloud application container.

A production deployment should use a valid TLS certificate, for example from Let's Encrypt.

Typical traffic flow:

```text
Internet
   |
 HTTPS :443
   |
Reverse Proxy
   |
Docker / internal network
   |
Nextcloud
```

## Firewall

Only ports that are actually required should be exposed by the server firewall.

Typical public ports are:

```text
22   SSH
80   HTTP
443  HTTPS
```

SSH access should be restricted where possible.

Database and Redis ports should not be exposed publicly.

In this project, Redis communicates with Nextcloud through the internal Docker Compose network and therefore does not require a published host port.

## Secrets

Do not commit passwords or other secrets to Git.

The `.env` file is excluded from version control.

Create the local environment file from:

```bash
cp .env.example .env
```

Then configure strong passwords locally.

The `.env.example` file should contain placeholders only.

For more advanced production environments, consider using a dedicated secrets-management solution.

## Backups

Production systems should be backed up regularly.

This project includes:

```text
scripts/backup.sh
scripts/restore.sh
```

A backup contains:

```text
database.sql
nextcloud-data.tar.gz
```

Backups should also be copied to storage outside the Docker host.

Keeping backups only on the same server does not protect against disk failure, hardware failure, or complete host loss.

Regular restore tests are strongly recommended.

The backup and restore workflow in this project was tested using a disposable Docker Compose environment.

## Docker Volumes

Docker volumes contain persistent application data.

Be especially careful with:

```bash
docker compose down -v
```

The `-v` option removes the project's named volumes.

On a production system this can destroy persistent application and database data.

Use it only when volume deletion is intentional.

## Updates

Container images should be updated regularly.

Before upgrading:

1. Read the release notes.
2. Create a verified backup.
3. Check compatibility between Nextcloud, MariaDB, Redis and other components.
4. Test the upgrade when possible.
5. Perform the production upgrade.
6. Verify application health after the update.

Avoid automatically upgrading major versions without testing.

## Health Checks

MariaDB and Redis use Docker health checks.

The Nextcloud application waits for these services to become healthy before starting.

Check container status with:

```bash
sudo docker compose ps
```

Inspect logs with:

```bash
sudo docker compose logs
```

or:

```bash
sudo docker compose logs -f
```

## Monitoring

A production server should be monitored for:

- container availability
- CPU usage
- memory usage
- disk usage
- Docker volume growth
- failed backups
- application errors
- database health
- TLS certificate expiration

Useful basic commands include:

```bash
docker stats
df -h
docker system df
docker compose ps
docker compose logs
```

For larger environments, dedicated monitoring systems such as Prometheus and Grafana can be added.

## SSH Security

For Internet-facing servers:

- prefer SSH key authentication
- disable password authentication when appropriate
- avoid direct root login
- keep OpenSSH updated
- restrict SSH access using firewall rules when possible

## Database and Redis Exposure

MariaDB and Redis should normally be reachable only from containers that require them.

They should not be published directly to the Internet.

The Compose network provides service discovery using service names such as:

```text
db
redis
```

This allows Nextcloud to communicate with its dependencies without exposing those services externally.

## Disaster Recovery

A backup is useful only if it can actually be restored.

A recovery procedure should include:

```text
new Docker environment
        |
        v
restore database
        |
        v
restore Nextcloud files
        |
        v
start services
        |
        v
verify application
```

The restore workflow in this repository has been tested with both database and file recovery.

## Production Checklist

Before exposing the service to the Internet, verify:

- HTTPS is configured
- TLS certificate is valid
- firewall rules are configured
- strong passwords are used
- `.env` is not tracked by Git
- Redis is not publicly exposed
- MariaDB is not publicly exposed
- backups are scheduled
- backups are stored outside the server
- restore procedure has been tested
- available disk space is monitored
- Docker images are kept up to date
- Nextcloud trusted domains are configured correctly
- logs are monitored
