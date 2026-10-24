# Nextcloud Docker Server

A self-hosted private cloud deployment using Docker Compose.

This project demonstrates how to deploy Nextcloud with MariaDB and Redis on a Linux server using Docker Compose.

## Architecture

The application consists of three Docker services:

- **Nextcloud** — web application and file management
- **MariaDB** — database server
- **Redis** — caching and file locking

```text
                Client
                  |
                  | HTTP :8080
                  v
          +----------------+
          |   Nextcloud    |
          |     Apache     |
          +-------+--------+
                  |
          +-------+-------+
          |               |
          v               v
     +---------+      +---------+
     | MariaDB |      |  Redis  |
     | db:3306 |      |redis:6379|
     +---------+      +---------+
          |
          v
    Persistent Data
