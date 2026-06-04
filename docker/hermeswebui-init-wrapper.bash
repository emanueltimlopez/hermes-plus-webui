#!/usr/bin/env bash
set -euo pipefail

shim_dir=/tmp/hermes-webui-shims
mkdir -p "$shim_dir"

cat > "$shim_dir/chown" <<'SH'
#!/usr/bin/env bash
/usr/bin/chown "$@" || true
SH
chmod 0755 "$shim_dir/chown"

PATH="$shim_dir:$PATH" exec /hermeswebui_init_original.bash
