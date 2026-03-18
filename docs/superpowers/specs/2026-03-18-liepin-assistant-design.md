---
name: liepin-assistant-repair-design
description: Approved repair design for improving the liepin-assistant skill package without shipping runtime browser state.
---

# Liepin Assistant Repair Design

## Goal

Improve `liepin-assistant` so it is safer to share, clearer to trigger, more portable across agent environments, and easier to evaluate, while keeping a local `profile/` directory inside the skill folder for runtime browser state.

## Constraints

- Keep `profile/` at `/Users/ysy/.agents/skills/liepin-assistant/profile`
- Do not ship or publish `profile/` contents
- Preserve the core workflow of using a real browser session to inspect job listings
- Avoid framing the skill as bypassing anti-bot protections

## Proposed Changes

### 1. Package Hygiene

- Add a `.gitignore` that excludes `profile/`, `.DS_Store`, and other local runtime artifacts
- Remove the checked-in `.DS_Store`
- Keep `profile/` on disk as a local runtime directory, but treat it as non-versioned state
- The launcher creates `profile/` on demand if it does not exist; no placeholder files inside `profile/` are tracked

### 1a. Distribution Safety

- Document that `profile/` is local runtime state and must not be included in commits, exports, release bundles, or shared archives
- Use ignore rules as the default guardrail for version control and local packaging workflows
- Verify that the repaired package contents do not include `profile/` runtime data before calling the work complete

### 2. Skill Positioning

- Rewrite `SKILL.md` frontmatter so the description is trigger-based rather than process-based
- Replace environment-specific `mcp_chrome-devtools_*` wording with portable guidance centered on Chrome DevTools tools available in the current agent harness
- Reframe the skill as browser-assisted interaction with user consent rather than WAF bypass or anti-detection behavior

### 3. Workflow Hardening

- Clarify the preflight flow: launch isolated Chrome, verify the debug endpoint, connect to the browser tools, navigate if needed
- Add explicit fallback behavior for:
  - login expired or missing
  - no matching network request found
  - endpoint names changing
  - DevTools connection not attaching to the intended browser session
- Clarify that result ordering defaults to the site's current ordering unless the user requests another sort

### 4. Launcher Script Safety

- Keep the isolated profile and debug port behavior
- Remove `--remote-allow-origins="*"` unless validation proves it is required for the intended local workflow
- Improve error messaging so the user can recover if Chrome is not found or remote debugging is unavailable
- Keep the launcher pointed at `/Users/ysy/.agents/skills/liepin-assistant/profile` exactly

### 5. Evaluation Coverage

- Rewrite `evals/evals.json` so it checks for correct workflow selection and failure-path handling
- Cover at least these scenarios:
  - standard job search on Liepin
  - login-required interruption
  - network request name changed or not found
  - DevTools/browser connection issue

### 6. README Scope

- Update `README.md` so its installation, safety, and usage language matches the repaired skill behavior and distribution model
- State clearly that the local `profile/` directory is runtime-only state and should not be shared

## Non-Goals

- Expanding the skill to other job platforms
- Adding live scraping automation beyond browser-assisted interaction
- Shipping cached browser data or credentials

## Acceptance Criteria

- `SKILL.md` has trigger-focused frontmatter and clear, portable steps
- `README.md` uses neutral, safety-conscious wording
- `.gitignore` prevents local browser state from being published
- `profile/` remains usable locally but is clearly documented as runtime-only
- No completion claim is made until the resulting package contents are checked and `profile/` runtime data is absent from the shareable set
- `launch_liepin_chrome.sh` passes shell syntax validation
- `launch_liepin_chrome.sh` still targets `/Users/ysy/.agents/skills/liepin-assistant/profile`
- `evals/evals.json` covers happy path and core failure paths
