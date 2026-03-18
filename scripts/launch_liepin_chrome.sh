#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROFILE_DIR="${SKILL_DIR}/profile"
DEBUG_PORT=9222
DEBUG_URL="http://127.0.0.1:${DEBUG_PORT}/json/version"
MAX_POLL_ATTEMPTS=8
POLL_INTERVAL_SECONDS=1

port_in_use_message() {
  printf 'Error: remote debugging port %s is already in use.\n' "$DEBUG_PORT" >&2
  printf 'Close the process using that port or change the existing Chrome/debugger session before retrying this launcher.\n' >&2
}

OS_NAME=$(uname -s)
if [[ "$OS_NAME" == "Darwin" ]]; then
  CHROME_APP="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
elif [[ "$OS_NAME" == *"MINGW"* ]] || [[ "$OS_NAME" == *"CYGWIN"* ]] || [[ "$OS_NAME" == *"MSYS"* ]]; then
  CHROME_APP="/c/Program Files/Google/Chrome/Application/chrome.exe"
  if [[ ! -f "$CHROME_APP" ]]; then
    CHROME_APP="/c/Program Files (x86)/Google/Chrome/Application/chrome.exe"
  fi
elif [[ "$OS_NAME" == "Linux" ]]; then
  if command -v google-chrome >/dev/null 2>&1; then
    CHROME_APP="google-chrome"
  else
    CHROME_APP="google-chrome-stable"
  fi
else
  printf 'Error: unsupported OS: %s\n' "$OS_NAME" >&2
  exit 1
fi

if [[ "$CHROME_APP" == */* ]]; then
  if [[ ! -x "$CHROME_APP" ]]; then
    printf 'Error: Google Chrome not found or not executable.\n' >&2
    printf 'Checked: %s\n' "$CHROME_APP" >&2
    printf 'Install Google Chrome or update this launcher to the correct executable path, then retry.\n' >&2
    exit 1
  fi
elif ! command -v "$CHROME_APP" >/dev/null 2>&1; then
  printf 'Error: Google Chrome not found.\n' >&2
  printf 'Checked command: %s\n' "$CHROME_APP" >&2
  printf 'Install Google Chrome or update this launcher to the correct executable path, then retry.\n' >&2
  exit 1
fi

if command -v lsof >/dev/null 2>&1; then
  if lsof -nP -iTCP:"$DEBUG_PORT" -sTCP:LISTEN >/dev/null 2>&1; then
    port_in_use_message
    exit 1
  fi
elif command -v curl >/dev/null 2>&1; then
  if curl --silent --fail "$DEBUG_URL" >/dev/null 2>&1; then
    port_in_use_message
    exit 1
  fi
fi

mkdir -p "$PROFILE_DIR"

printf 'Launching isolated Liepin Chrome...\n'
printf 'Profile directory: %s\n' "$PROFILE_DIR"
printf 'Remote debugging port: %s\n' "$DEBUG_PORT"

"$CHROME_APP" \
  --user-data-dir="$PROFILE_DIR" \
  --remote-debugging-port="$DEBUG_PORT" \
  --no-first-run \
  --no-default-browser-check \
  "https://www.liepin.com/" &
CHROME_PID=$!

if command -v curl >/dev/null 2>&1; then
  endpoint_ready=0
  for ((attempt = 1; attempt <= MAX_POLL_ATTEMPTS; attempt++)); do
    if ! kill -0 "$CHROME_PID" >/dev/null 2>&1; then
      printf 'Error: Chrome exited before the DevTools endpoint became ready.\n' >&2
      printf 'Re-run the launcher and confirm Chrome can stay open with port %s available.\n' "$DEBUG_PORT" >&2
      exit 1
    fi

    if curl --silent --fail "$DEBUG_URL" >/dev/null; then
      endpoint_ready=1
      break
    fi
    sleep "$POLL_INTERVAL_SECONDS"
  done

  if ! kill -0 "$CHROME_PID" >/dev/null 2>&1; then
    printf 'Error: Chrome exited during startup before DevTools attachment completed.\n' >&2
    printf 'Re-run the launcher and confirm Chrome can stay open with port %s available.\n' "$DEBUG_PORT" >&2
    exit 1
  fi

  if [[ "$endpoint_ready" -eq 1 ]]; then
    printf 'Chrome launched and DevTools is listening at %s\n' "$DEBUG_URL"
  else
    printf 'Error: Chrome launched, but the DevTools endpoint did not respond after %s seconds.\n' "$((MAX_POLL_ATTEMPTS * POLL_INTERVAL_SECONDS))" >&2
    printf 'If browser tools cannot attach, confirm Chrome stayed open and that port %s is not blocked or already in use.\n' "$DEBUG_PORT" >&2
    printf 'After that, retry this launcher and reconnect your browser tools to the same Chrome window.\n' >&2
    exit 1
  fi
else
  if ! kill -0 "$CHROME_PID" >/dev/null 2>&1; then
    printf 'Error: Chrome exited immediately after launch.\n' >&2
    printf 'Re-run the launcher and confirm Chrome can stay open with port %s available.\n' "$DEBUG_PORT" >&2
    exit 1
  fi

  printf 'Chrome launched. curl is unavailable, so the DevTools endpoint was not auto-checked.\n'
  printf 'If tools fail to attach, open %s to confirm the debugger is reachable.\n' "$DEBUG_URL"
fi

printf 'Use the opened Chrome window to sign in to Liepin if needed; the isolated profile keeps that session local to this skill.\n'
