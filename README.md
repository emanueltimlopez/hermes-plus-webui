# Hermes Agent + Hermes WebUI on Railway

This Docker setup runs both services in one Railway container:

- `hermes-agent` gateway on internal port `8642`
- `hermes-webui` on Railway's public `$PORT`

Railway should detect `railway.toml` and build with `Dockerfile`.

## Required Railway variables

Set at least one model provider key supported by Hermes, for example:

```env
OPENAI_API_KEY=...
OPENAI_BASE_URL=https://api.openai.com/v1
HERMES_MODEL=gpt-4o
```

For any OpenAI-compatible LLM API, replace `OPENAI_BASE_URL` with that provider's
base URL and set `HERMES_MODEL` to the model name exposed by that endpoint.

Recommended:

```env
HERMES_WEBUI_PASSWORD=change-me
API_SERVER_KEY=change-me-too
```

Railway sets `PORT` automatically. The WebUI service maps that value to `HERMES_WEBUI_PORT`.

## Persistent data / volumes

Railway volumes are not declared in `railway.toml`; that file only controls
build and deploy settings for each deployment. Create and attach the persistent
volume as a Railway service resource instead:

```bash
railway volume add --mount-path /opt/data
```

Attach the volume at:

```text
/opt/data
```

That single mount replaces the shared `hermes-home` volume used by the official compose files. It keeps:

- Hermes Agent config, sessions, memory, skills, profiles, and gateway state
- Hermes WebUI state under `/opt/data/webui`
- WebUI `~/.hermes`, symlinked to `/opt/data`

Railway mounts volumes as `root`, so the container entrypoint fixes ownership
and group write permissions for the Hermes runtime users before starting the
WebUI.

Optional: attach another Railway volume at:

```text
/workspace
```

Use this only if you want files created or edited through the WebUI workspace browser to persist across deploys. The agent source volume from the official two-container compose is not needed here because this image bakes `hermes-agent` into `/opt/hermes`.

## Local test

```bash
docker build -t hermes-railway .
docker run --rm -p 8787:8787 \
  -e PORT=8787 \
  -e OPENAI_API_KEY="$OPENAI_API_KEY" \
  -e OPENAI_BASE_URL="${OPENAI_BASE_URL:-https://api.openai.com/v1}" \
  -e HERMES_MODEL="${HERMES_MODEL:-gpt-4o}" \
  hermes-railway
```

Open:

```text
http://localhost:8787
```
