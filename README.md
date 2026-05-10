# DevOps Sandbox Platform (Stage 5)

## Overview

This project is a self-service DevOps sandbox platform that allows users to:

* Create isolated, temporary environments using Docker
* Deploy lightweight applications into each environment
* Route traffic dynamically through Nginx
* Monitor health status of each environment
* Simulate outages (crash, pause, network failure)
* Automatically destroy expired environments via a cleanup daemon

Each environment is short-lived and fully isolated, mimicking a mini "Heroku-like" internal platform with chaos engineering capabilities.

---

## Architecture

```
                    USER
                      |
                      v
               +-------------+
               |   NGINX     |
               | Reverse Proxy|
               +-------------+
                 |       |
        /env-id  |       | /env-id-2
                 v       v

          +------------+  +------------+
          | Container  |  | Container  |
          | Env A App  |  | Env B App  |
          +------------+  +------------+

                 ^
                 |
     +------------------------+
     | create/destroy scripts |
     | (platform/*.sh)        |
     +------------------------+

                 ^
                 |
     +------------------------+
     | cleanup daemon         |
     | (auto TTL remover)     |
     +------------------------+

                 ^
                 |
     +------------------------+
     | monitor/poller         |
     | (health checks)        |
     +------------------------+

                 ^
                 |
     +------------------------+
     | Flask Control API      |
     +------------------------+
```

---

## Tech Stack

* Docker
* Docker Compose (optional)
* Nginx (reverse proxy)
* Bash scripting
* Python (Flask + monitoring)
* Linux VM environment

---

## Project Structure

```
devops-sandbox/
├── platform/
│   ├── create_env.sh
│   ├── destroy_env.sh
│   ├── cleanup_daemon.sh
│   ├── simulate_outage.sh
│   └── api.py
├── nginx/
│   ├── nginx.conf
│   └── conf.d/
├── monitor/
│   └── poller.py
├── logs/
│   ├── archived/
├── envs/
├── Makefile
└── README.md
```

---

## Prerequisites

Before running this project, install:

```bash
sudo apt update
sudo apt install docker.io nginx python3 python3-pip jq -y
pip install flask requests
```

Enable Docker:

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

---

## Quick Start (Minimal Steps)

Follow exactly:

```bash
git clone <your-repo>
cd devops-sandbox
docker build -t sandbox-app ./demo-app
docker run -d -p 80:80 --name sandbox-nginx nginx
nohup ./platform/cleanup_daemon.sh &
python3 monitor/poller.py &
python3 platform/api.py
```

Now create your first environment:

```bash
./platform/create_env.sh test-env 600
```

Open in browser:

```
http://localhost/env-xxxxxx/
```

---

## Core Commands

### Create Environment

```bash
./platform/create_env.sh <name> <ttl_in_seconds>
```

Example:

```bash
./platform/create_env.sh myapp 1800
```

---

### Destroy Environment

```bash
./platform/destroy_env.sh <env_id>
```

Example:

```bash
./platform/destroy_env.sh env-abc123
```

---

### List Logs

```bash
make logs ENV=env-abc123
```

---

### Simulate Outage

```bash
./platform/simulate_outage.sh --env env-abc123 --mode crash
```

Modes:

* crash → kills container
* pause → pauses container
* recover → restores container

---

### Health Status

```bash
make health
```

---

### API Usage

Start API:

```bash
python3 platform/api.py
```

Endpoints:

* Create env → `POST /envs`
* List envs → `GET /envs`
* Destroy env → `DELETE /envs/:id`
* Logs → `GET /envs/:id/logs`
* Health → `GET /envs/:id/health`
* Outage → `POST /envs/:id/outage`

---

## Automation (Cleanup Daemon)

The cleanup daemon runs every 60 seconds:

* Reads `envs/` state files
* Checks TTL expiry
* Automatically destroys expired environments

Run it:

```bash
nohup ./platform/cleanup_daemon.sh &
```

Logs:

```
logs/cleanup.log
```

---

## Health Monitoring

A Python poller:

* Checks `/health` endpoint every 30 seconds
* Logs response time and status
* Flags degraded environments after 3 failures

Logs stored in:

```
logs/<env_id>/health.log
```

---

## Log System

Each environment has logs:

```
logs/<env_id>/app.log
```

Archived on destroy:

```
logs/archived/<env_id>/
```

---

## Demo Walkthrough

1. Create environment

```bash
./platform/create_env.sh demo 300
```

2. Access app

```
http://localhost/env-demo/
```

3. Check health logs

```bash
cat logs/demo/health.log
```

4. Simulate crash

```bash
./platform/simulate_outage.sh --env demo --mode crash
```

5. Recover

```bash
./platform/simulate_outage.sh --env demo --mode recover
```

6. Wait for auto-destroy or run:

```bash
./platform/destroy_env.sh demo
```

---

## Makefile Commands

```bash
make up
make down
make create
make destroy ENV=env-id
make logs ENV=env-id
make simulate ENV=env-id MODE=crash
make clean
```

---

## Screenshots (IMPORTANT FOR SUBMISSION)

Include screenshots of:

* Environment creation output
* Browser showing `/env-id/`
* Health logs
* Outage simulation
* Auto-destroy logs
* Nginx conf files auto-generated

---

## Known Limitations

* Single VM only (not distributed)
* No authentication layer
* Basic log shipping (file-based)
* No persistent database (uses JSON files)
* Limited scaling (not production-ready)

---

## What Makes This Project Strong

* Fully automated environment lifecycle
* Dynamic reverse proxy routing
* TTL-based auto cleanup system
* Real-time health monitoring
* Chaos engineering simulation
* Script-based DevOps orchestration

---

## Author

Built as part of DevOps Stage 5 Training Project.

---

## Final Note

If the reviewer can:

```bash
git clone <repo>
make up
make create
```

and see everything working — the project passes.
