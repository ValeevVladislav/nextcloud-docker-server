# Installation Guide

This guide describes how to deploy the Nextcloud Docker Server on a Linux system.

## Requirements

Before starting, make sure the following software is installed:

- Linux
- Docker
- Docker Compose
- Git

Check Docker:

```bash
docker --version
docker compose version
```

Check Git:

```bash
git --version
```

## 1. Clone the Repository

Clone the project:

```bash
git clone <repository-url>
```

Enter the project directory:

```bash
cd nextcloud-docker-server
```

## 2. Configure Environment Variables

Create the environment file from the provided example:

```bash
cp .env.example .env
```

Edit the file:

```bash
nano .env
```

Replace the example passwords with strong passwords:

```dotenv
MYSQL_ROOT_PASSWORD=CHANGE_ME
MYSQL_DATABASE=nextcloud
MYSQL_USER=nextcloud
MYSQL_PASSWORD=CHANGE_ME
```

Never commit the `.env` file to Git.

## 3. Validate the Configuration

Before starting the containers, validate the Docker Compose configuration:

```bash
docker compose config
```

The command should complete without configuration errors.

## 4. Start the Application

Start all services in the background:

```bash
docker compose up -d
```

Docker will create the required network and persistent volumes automatically.

## 5. Check Container Status

Check the running services:

```bash
docker compose ps
```

The project contains three services:

- app
- db
- redis

## 6. Check Logs

View logs from all services:

```bash
docker compose logs
```

Follow logs in real time:

```bash
docker compose logs -f
```

View logs for a specific service:

```bash
docker compose logs app
docker compose logs db
docker compose logs redis
```

## 7. Open Nextcloud

Open the following address in a web browser:

```text
http://SERVER_IP:8080
```

Replace `SERVER_IP` with the IP address of your Linux server.

## 8. Stop the Application

Stop the containers:

```bash
docker compose stop
```

Start them again:

```bash
docker compose start
```

## 9. Remove Containers

To stop and remove the containers and project network:

```bash
docker compose down
```

Persistent Docker volumes are preserved.

Do not use the following command unless you intentionally want to remove the project volumes:

```bash
docker compose down -v
```

Removing volumes may permanently delete application and database data.
