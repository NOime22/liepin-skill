# Liepin Skill (猎聘小助手)

`liepin-skill` is a reusable skill package for AI agents that need to work with Liepin through a real Chrome browser session. It is designed for browser-assisted job search, listing review, and user-directed page interaction rather than direct scraping shortcuts.

## What It Covers

- Search Liepin and summarize job listings from the live site.
- Inspect page-driven network responses from the active browser session when available.
- Help with user-directed actions such as opening jobs, greeting recruiters, and checking apply flows.
- Pause for manual login when the site requires authentication.

## Install And Run

1. Place this directory in your local skills folder and set its absolute path as `LIEPIN_SKILL_DIR` (do not assume a fixed root directory), for example:

```bash
export LIEPIN_SKILL_DIR="/absolute/path/to/liepin-skill"
```
2. Keep `profile/` on disk for local runtime use only. It stores the isolated Chrome session for this machine.
3. Make sure your agent environment has Chrome DevTools MCP or equivalent Chrome DevTools browser tools installed. If not, install/configure it first using the upstream project: `https://github.com/ChromeDevTools/chrome-devtools-mcp`.
4. Start the dedicated browser with:

```bash
bash "$LIEPIN_SKILL_DIR/scripts/launch_liepin_chrome.sh"
```

5. If needed, override the default debugger port for your own machine before launch, for example `LIEPIN_DEBUG_PORT=9333 bash "$LIEPIN_SKILL_DIR/scripts/launch_liepin_chrome.sh"`.
6. The launcher writes `session.json` with the actual debugger port and URL for that dedicated browser session.
7. Point Chrome DevTools MCP at that dedicated browser endpoint instead of letting it control an unrelated blank browser session.
   - You can print the recommended connection target with:

```bash
python3 "$LIEPIN_SKILL_DIR/scripts/print_browser_url.py"
```

8. On first use, open Liepin in that isolated browser, check the login state, and if you are logged out, log in manually in that same window.
9. If Chrome DevTools MCP still cannot control the dedicated browser, open `chrome://inspect/#remote-debugging` in that same dedicated browser, enable remote debugging, close the tab, and then let the agent continue.
10. Later runs should reuse that same `profile/` directory so the login session remains available in the dedicated browser.
11. If your harness browser tools open a separate blank browser, do not treat that blank browser as the Liepin session. The dedicated profile browser created by the launcher is the one this skill is meant to operate on.

## Local Runtime State

- `profile/` is runtime-only local state.
- `profile/` may contain login state, cookies, cache, and other machine-local browser data.
- `profile/` is the persisted login/session store for later runs of this skill on the same machine.
- `session.json` stores the latest debugger endpoint metadata for the dedicated browser session.
- Do not include `profile/` in commits, exports, release bundles, or shared archives.
- Do not treat `profile/` as part of the shareable skill package.

## Package Layout

- `SKILL.md`: instructions for the agent.
- `README.md`: human-facing usage notes.
- `scripts/`: local helper scripts such as the Chrome launcher.
- `evals/`: evaluation cases for the skill package.
- `profile/`: local browser runtime state, not for distribution.

## Usage Notes

- The default result ordering follows Liepin's current page ordering unless the user asks for a different sort.
- If login expires, the agent should stop, surface the login state, and wait for manual login in the isolated Chrome window.
- If the expected network request changes, the agent should inspect the live page flow and use the request that matches the current interaction and response shape.

## Safety

Use this skill in line with Liepin's terms, normal user intent, and the user's explicit instructions. Avoid high-volume or abusive automation, and keep the browser workflow transparent to the user.
