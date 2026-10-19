# Dev infra

Shared local infrastructure for all my projects: **one** instance of each service, and each
project gets its own database, bucket and `*.localhost` site. Apps run natively on the host
(`cargo run`, `npm run dev`); only the infrastructure runs in containers.

| Service | Image | Local access |
|---|---|---|
| PostgreSQL 18 | `postgres:18-alpine` | `localhost:5432` (user/pass `postgres`) · UI http://db.localhost (pgweb) |
| S3 (SeaweedFS) | `chrislusf/seaweedfs` | `http://localhost:8333` (no auth in dev, any key works) · UI http://s3.localhost |
| Logto (OIDC) | `svhd/logto` | http://logto.localhost · console http://logto-admin.localhost |
| Mailpit (fake SMTP) | `axllent/mailpit` | SMTP `localhost:1025` · UI http://mail.localhost |
| Valkey (Redis) | `valkey/valkey` | `localhost:6379` — only with `./infra up --redis` |
| Caddy | `caddy:2-alpine` | `*.localhost` on port 80 → services and native apps |

Everything binds to `127.0.0.1`. Data lives in named volumes (`devinfra_*`), so `down` keeps it.

## Usage

```sh
./infra up                         # start (add --redis for Valkey)
./infra project create myapp 5173  # db + role + bucket + http://myapp.localhost -> :5173
./infra project env myapp          # print DATABASE_URL, S3_*, SMTP_URL, LOGTO_* for .env
./infra db reset myapp             # empty the project's database
./infra project drop myapp         # remove db, role, bucket and site (asks first)
./infra site add myapp 3000        # (re)point http://myapp.localhost and *.myapp.localhost
./infra psql [db] | logs [svc] | status | backup | down
```

`project create` is idempotent; a project's own setup script can call it and write the output to
its `.env`. Each project role has `CREATEDB`, so test helpers like `#[sqlx::test]` can create
throwaway databases.

### Logto per project

The first visit to http://logto-admin.localhost creates the admin account. For each project, create
an application in the console (e.g. *SPA* for the frontend + an *API resource* for the backend) and
copy its App ID into the project's `.env`. The backend validates tokens with `LOGTO_ISSUER` and
`LOGTO_JWKS_URL` from `project env` (the JWKS URL uses `localhost:3001` because non-browser
resolvers don't always resolve `*.localhost`).

## Podman (default) or Docker

Podman is the default engine: `./infra` uses `podman` when installed, otherwise `docker` (force
one with `INFRA_ENGINE=docker ./infra …`). The compose file sticks to the plain Compose spec and
works with both `podman-compose` and `docker-compose` as the `podman compose` provider.

Setup on macOS:

```sh
brew install podman podman-compose
brew install --cask podman-desktop          # optional GUI
podman machine init --cpus 4 --memory 4096 --disk-size 50
podman machine start
./infra up
```

On macOS, rootless Podman can't publish ports < 1024 on `127.0.0.1`, and its VM blocks them for
rootless containers. `./infra up` handles both: it publishes Caddy's port 80 on all interfaces
(Docker keeps it on `127.0.0.1`) and, once, sets `net.ipv4.ip_unprivileged_port_start=80` inside
the VM (`/etc/sysctl.d/99-unprivileged-ports.conf`). If you'd rather not, copy `.env.example` to
`.env` and uncomment the 8080 block, so URLs become `http://<name>.localhost:8080`.

Docker and Podman keep separate volumes, so switching engines starts with empty data.

## Notes

- MinIO isn't used: its community edition was archived in 2025.
- `host.docker.internal` (used by project sites) is mapped via `host-gateway`; works on both
  Docker and Podman (tested with Podman 6.1).
- `./infra backup` writes a `pg_dumpall` to `backups/` (gitignored).
