# Architecture

## Overview

This project deploys a self-hosted Nextcloud instance using Docker Compose.

The application consists of three services:

- Nextcloud
- MariaDB
- Redis

All services communicate through an internal Docker network.

## Architecture Diagram

```text
                 User
                  |
                  | HTTP :8080
                  v
        +---------------------+
        |    Linux Server     |
        |                     |
        |  +---------------+  |
        |  |   Nextcloud   |  |
        |  |    Apache     |  |
        |  +-------+-------+  |
        |          |          |
        |     +----+----+     |
        |     |         |     |
        |     v         v     |
        | +-------+ +-------+ |
        | |MariaDB| | Redis | |
        | +-------+ +-------+ |
        |                     |
        +---------------------+
