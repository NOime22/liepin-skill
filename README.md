# Liepin Assistant (猎聘小助手)

`liepin-assistant` is a reusable skill package for AI agents that need to work with Liepin through a real Chrome browser session. It is designed for browser-assisted job search, listing review, and user-directed page interaction rather than direct scraping shortcuts.

## What It Covers

- Search Liepin and summarize job listings from the live site.
- Inspect page-driven network responses from the active browser session when available.
- Help with user-directed actions such as opening jobs, greeting recruiters, and checking apply flows.
- Pause for manual login when the site requires authentication.

## Install And Run

1. Place this directory in your local skills folder, for example `~/.agents/skills/liepin-assistant`.
2. Keep `profile/` on disk for local runtime use only. It stores the isolated Chrome session for this machine.
3. Start the dedicated browser with:

```bash
bash ~/.agents/skills/liepin-assistant/scripts/launch_liepin_chrome.sh
```

4. If your Chrome build asks for it on first use, enable remote debugging for that isolated browser instance.
5. Let your agent attach its available Chrome DevTools browser tools to that isolated session before starting Liepin work.

## Local Runtime State

- `profile/` is runtime-only local state.
- `profile/` may contain login state, cookies, cache, and other machine-local browser data.
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
