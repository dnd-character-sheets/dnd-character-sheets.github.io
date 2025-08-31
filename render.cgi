#!/usr/bin/env bash
set -euo pipefail

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

INPUT="$TMPDIR/input.yaml"
OUTPUT="$TMPDIR/output.pdf"
STDERR="$TMPDIR/stderr.txt"
STDOUT="$TMPDIR/stdout.txt"

MAX_YAML_BYTES="${MAX_YAML_BYTES:-2097152}"   # 2 MiB default
RENDER_TIMEOUT_SECS="${RENDER_TIMEOUT_SECS:-30}"
CHARSHEET_CMD="${CHARSHEET_CMD:-charsheet}"   # override with absolute path

# Validate & read request body (CGI provides Content-Length)
CL="${CONTENT_LENGTH:-}"
if [[ -z "$CL" || ! "$CL" =~ ^[0-9]+$ ]]; then
  echo -e "Status: 411 Length Required\r"
  echo -e "Content-Type: text/plain; charset=utf-8\r"
  echo -e "\r"
  echo "Missing or invalid Content-Length."
  exit 0
fi

if (( CL > MAX_YAML_BYTES )); then
  echo -e "Status: 413 Payload Too Large\r"
  echo -e "Content-Type: text/plain; charset=utf-8\r"
  echo -e "\r"
  echo "YAML too large (> $MAX_YAML_BYTES bytes)."
  exit 0
fi

# Read exactly Content-Length bytes from stdin
head -c "$CL" > "$INPUT" || true
ACTUAL="$(wc -c < "$INPUT")"
if (( ACTUAL != CL )); then
  echo -e "Status: 400 Bad Request\r"
  echo -e "Content-Type: text/plain; charset=utf-8\r"
  echo -e "\r"
  echo "Failed to read request body."
  exit 0
fi

if false; then
  echo -e "Status: 200 OK\r"
  echo -e "Content-Type: text/plain; charset=utf-8\r"
  echo -e "\r"
  cat "$INPUT"
  exit 0
fi

# Optional: export runtime env for charsheet here
# export TEMPLATES_DIR="/srv/charsheet/templates"
# export FONTS_DIR="/srv/charsheet/fonts"
/bin/cp "$INPUT" /tmp/last-charsheet.yaml
chmod 644 /tmp/last-charsheet.yaml

set +e
timeout "${RENDER_TIMEOUT_SECS}s" "$CHARSHEET_CMD" -q -o "$OUTPUT" "$INPUT" 2> "$STDERR" > "$STDOUT"
rc=$?
set -e

if (( rc != 0 )) || [[ ! -s "$OUTPUT" ]]; then
  echo -e "Status: 400 Bad Request\r"
  echo -e "Content-Type: text/plain; charset=utf-8\r"
  echo -e "X-Charsheet-Exit: $rc\r"
  echo -e "\r"
  echo "PDF rendering failed (rc==$rc)."
  echo
  echo "=== stderr (first 400 lines) ==="
  sed -n '1,400p' "$STDERR"
  echo "=== stdout (first 400 lines) ==="
  sed -n '1,400p' "$STDOUT"
  if [[ -r "$OUTPUT" ]]; then
    echo "=== output (first 2 lines) ==="
    sed -n '1,2p' "$OUTPUT"
  else
    echo "=== no file $OUTPUT ==="
  fi
  echo "=== input (first 400 lines of $CL bytes) ==="
  sed -n '1,400p' "$INPUT"
  exit 0
fi

echo -e "Status: 200 OK\r"
echo -e "Content-Type: application/pdf\r"
echo -e 'Content-Disposition: inline; filename="output.pdf"\r'
echo -e "\r"
cat "$OUTPUT"
