# Hermes Agent + Hermes WebUI on Railway

This Docker setup runs both services in one Railway container:

- `hermes-agent` gateway on internal port `8642`
- `hermes-webui` on Railway's public `$PORT`

Railway should detect `railway.toml` and build with `Dockerfile`.

## Required Railway variables

Set at least one model provider key supported by Hermes, for example:

```env
OPENAI_API_KEY=...
```

Recommended:

```env
HERMES_WEBUI_PASSWORD=change-me
API_SERVER_KEY=change-me-too
```

Railway sets `PORT` automatically. The WebUI service maps that value to `HERMES_WEBUI_PORT`.

## Persistent data

Attach a Railway volume at:

```text
/opt/data
```

That keeps Hermes config, sessions, memory, skills, and WebUI state across deploys.

## Local test

```bash
docker build -t hermes-railway .
docker run --rm -p 8787:8787 -e PORT=8787 -e OPENAI_API_KEY="$OPENAI_API_KEY" hermes-railway
```

Open:

```text
http://localhost:8787
```
