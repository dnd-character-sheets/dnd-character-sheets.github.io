#!/usr/bin/env bash
set -euo pipefail

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

INPUT="$TMPDIR/input.yaml"
OUTPUT="$TMPDIR/output.pdf"
STDERR="$TMPDIR/stderr.txt"
STDOUT="$TMPDIR/stdout.txt"
DROPDIR=${DROPDIR:-/tmp}

# ORIGIN is normally computed by a deployment prefix like halligan-prefix.sh.
# If not set it falls back to `*`, which means no Origin header
# (i.e. not a browser request).  If ORIGIN is set but empty, the prefix
# denies an origin.

ORIGIN="${ORIGIN-*}"

cors_header() {
  [[ -n "$ORIGIN" ]] && echo -e "Access-Control-Allow-Origin: $ORIGIN\r"
  return 0
}

MAX_YAML_BYTES="${MAX_YAML_BYTES:-2097152}"   # 2 MiB default
RENDER_TIMEOUT_SECS="${RENDER_TIMEOUT_SECS:-30}"
CHARSHEET_CMD="${CHARSHEET_CMD:-charsheet}"   # override with absolute path

#if [[ "$REQUEST_METHOD" = OPTIONS ]]; then
#  echo -e "Status: 200 OK\r"
#  echo -e "Allow: POST, OPTIONS\r"
#  echo -e "Content-Type: text/plain\r"
#  cors_header
#  echo -e "Access-Control-Allow-Methods: POST, OPTIONS\r"
#  echo -e "Access-Control-Allow-Headers: Content-Type\r"
#  echo -e "X-Request-Origin: ${HTTP_ORIGIN:-(unset)}\r"
#  echo -e "\r"
#  echo -e "Origin is '$HTTP_ORIGIN'"
#  exit 0
#fi



# Validate & read request body (CGI provides Content-Length)
CL="${CONTENT_LENGTH:-}"
if [[ -z "$CL" || ! "$CL" =~ ^[0-9]+$ ]]; then
  echo -e "Status: 411 Length Required\r"
  echo -e "Content-Type: text/plain; charset=utf-8\r"
  cors_header
  echo -e "\r"
  echo "Missing or invalid Content-Length."
  exit 0
fi

if (( CL > MAX_YAML_BYTES )); then
  echo -e "Status: 413 Payload Too Large\r"
  echo -e "Content-Type: text/plain; charset=utf-8\r"
  cors_header
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
  cors_header
  echo -e "\r"
  echo "Failed to read request body."
  exit 0
fi

# Optional: export runtime env for charsheet here
# export TEMPLATES_DIR="/srv/charsheet/templates"
# export FONTS_DIR="/srv/charsheet/fonts"

# Best-effort: write $1 (a source file) through a mktemp'd file and mv
# (an atomic rename) into place at $2, rather than cp'ing straight over
# it: cp follows a symlink at the destination, so a symlink planted at
# a well-known debug path could redirect the write to an
# attacker-chosen target; rename() replaces the symlink itself instead
# of the file it points to. Never blocks the response.
capture_debug() {
  local src="$1" dst="$2" tmp
  tmp="$(mktemp "$dst.XXXXXX")" || return 0
  cp "$src" "$tmp" && chmod 644 "$tmp" && mv -f "$tmp" "$dst"
}

# Keep the last submitted sheet around for local inspection.
capture_debug "$INPUT" $DROPDIR/last-charsheet.yaml || true

# run_with_timeout SECS TIMED_OUT_VAR CMD [ARGS...]
# Runs CMD as the leader of its own process group, so a single signal
# reaches everything it spawns, typesetting run included. Sets the
# variable named by TIMED_OUT_VAR to 1 if CMD was still running after
# SECS (in which case it is stopped: SIGTERM, then SIGKILL after a 2s
# grace period) or 0 if it finished on its own. Returns CMD's own exit
# status.
run_with_timeout() {
  local secs="$1" timed_out_var="$2"
  shift 2
  local flag
  flag="$(mktemp)"

  setsid "$@" &
  local child=$!
  (
    sleep "$secs"
    kill -TERM -- "-$child" 2>/dev/null && echo timed_out > "$flag"
    sleep 2
    kill -KILL -- "-$child" 2>/dev/null
  ) &
  local watchdog=$!

  wait "$child"
  local rc=$?
  kill "$watchdog" 2>/dev/null
  wait "$watchdog" 2>/dev/null

  [[ -s "$flag" ]] && printf -v "$timed_out_var" 1 || printf -v "$timed_out_var" 0
  rm -f "$flag"
  return "$rc"
}

set +e
run_with_timeout "$RENDER_TIMEOUT_SECS" timed_out \
  "$CHARSHEET_CMD" -q -o "$OUTPUT" "$INPUT" 2> "$STDERR" > "$STDOUT"
rc=$?
set -e

if (( timed_out )); then
  echo -e "Status: 504 Gateway Timeout\r"
  echo -e "Content-Type: text/plain; charset=utf-8\r"
  cors_header
  echo -e "\r"
  echo "PDF rendering exceeded the ${RENDER_TIMEOUT_SECS}s limit and was stopped."
  exit 0
fi

# tagged_messages FILE TAG
# Extracts the text bin/charsheet wrote through its own eprintf, which
# tags every line with "TAG: ". A message whose format starts with a
# newline puts the tag alone on its own line, with the content on the
# next line, so a tag-only line also pulls in the line right after it.
tagged_messages() {
  local file="$1" tag="$2: "
  awk -v tag="$tag" '
    $0 == tag            { want_next = 1; next }
    want_next            { print; want_next = 0; next }
    index($0, tag) == 1  { print substr($0, length(tag) + 1) }
  ' "$file"
}

if (( rc != 0 )) || [[ ! -s "$OUTPUT" ]]; then
  # Error messages should not be allowed to leak server paths or
  # software versions.  So stderr is filtered aggressively to allow
  # only known messages back to the client.  The full, unfiltered
  # stderr/stdout are saved where only local inspection can see them.

  capture_debug "$STDERR" $DROPDIR/last-charsheet.stderr.txt || true
  capture_debug "$STDOUT" $DROPDIR/last-charsheet.stdout.txt || true

  safe_stderr="$(tagged_messages "$STDERR" "$(basename "$CHARSHEET_CMD")")"

  echo -e "Status: 400 Bad Request\r"
  echo -e "Content-Type: text/plain; charset=utf-8\r"
  cors_header
  echo -e "X-Charsheet-Exit: $rc\r"
  echo -e "\r"
  echo "PDF rendering failed."
  echo
  if [[ -n "$safe_stderr" ]]; then
    echo "$safe_stderr"
  else
    echo "An internal error occurred while rendering. This has been logged for review."
  fi
  echo "==== $STDERR ===" 
  cat $STDERR
  echo "==== $STDOUT ===" 
  cat $STDOUT
  exit 0
fi

echo -e "Status: 200 OK\r"
echo -e "Content-Type: application/pdf\r"
echo -e 'Content-Disposition: inline; filename="output.pdf"\r'
cors_header
echo -e "\r"
cat "$OUTPUT"
