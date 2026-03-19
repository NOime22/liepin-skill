#!/usr/bin/env python3

from __future__ import annotations

import json
import sys
from pathlib import Path


def main() -> int:
    skill_dir = Path(__file__).resolve().parent.parent
    session_file = skill_dir / "session.json"

    if not session_file.exists():
        print(
            "Error: session.json not found. Launch the dedicated Liepin browser first.",
            file=sys.stderr,
        )
        return 1

    try:
        session = json.loads(session_file.read_text())
    except json.JSONDecodeError as exc:
        print(f"Error: failed to parse session.json: {exc}", file=sys.stderr)
        return 1

    debug_port = session.get("debug_port")
    debug_url = session.get("debug_url")

    if not isinstance(debug_port, int) or not isinstance(debug_url, str):
        print(
            "Error: session.json is missing debug_port or debug_url.", file=sys.stderr
        )
        return 1

    print(f"browser-url=http://127.0.0.1:{debug_port}")
    print(f"debug-url={debug_url}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
