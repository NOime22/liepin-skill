---
name: liepin-skill
description: Use when the user wants to search Liepin, review Chinese job listings, inspect recruiter or job data in a real logged-in browser session, or interact with Liepin pages such as opening jobs, greeting recruiters, or checking application flows.
---

# Liepin Skill (猎聘小助手)

Use this skill for Liepin work that depends on a real browser session, current site state, or the user's logged-in account.

## When To Use

- Search Liepin jobs, review listings, or summarize recruiter/job details.
- Open jobs, click page controls, or help with greet/apply flows in the browser.
- Inspect network responses that the live Liepin page already loads.
- Prefer the site's current ordering unless the user explicitly asks for another sort.

## Tooling Preflight

Before browser work begins, confirm the current agent environment has Chrome DevTools MCP or equivalent Chrome DevTools browser tools available.

1. If those tools are already installed and callable, continue.
2. If they are missing, help the environment install and configure Chrome DevTools MCP from `https://github.com/ChromeDevTools/chrome-devtools-mcp` before attempting Liepin work.
3. Do not continue with Liepin browser automation until Chrome DevTools control is available in some form.

## Preflight

Before doing any Liepin extraction or page interaction, follow this order exactly:

1. Resolve `<skill-dir>` as the installed `liepin-skill` directory (the directory containing this `SKILL.md`), then launch the isolated Chrome instance with `<skill-dir>/scripts/launch_liepin_chrome.sh` if it is not already running.
2. Treat that dedicated profile browser as the only valid Liepin session for this skill.
3. Read `<skill-dir>/session.json` if it exists. Use it to discover the current debug port, debug URL, and profile path instead of assuming one fixed port.
   - If needed, print the recommended connection target with `python3 <skill-dir>/scripts/print_browser_url.py`.
4. Verify the remote debugging endpoint from that session metadata is reachable. If the state file is missing, fall back to `LIEPIN_DEBUG_PORT`, then to the default `9222`.
5. Configure Chrome DevTools MCP or equivalent browser tools to connect to that dedicated browser endpoint, preferably through a `browser-url` style connection such as `http://127.0.0.1:<port>`.
6. Confirm the dedicated browser really contains the logged-in Liepin tab you intend to operate on.
7. If your harness also exposes its own blank browser context, do not use that browser as the Liepin target session and do not summarize its state as if it were the dedicated browser.
8. If the dedicated browser is not logged in yet, navigate it to Liepin, detect the logged-out state, and stop so the user can complete login manually.
9. Once the user has logged in, continue in that same dedicated profile browser so the session persists for later runs.

The skill-created dedicated profile browser is the intended long-lived browser. Its login state should survive across runs because the profile directory is reused, and `session.json` should tell you which debugger endpoint belongs to it.

## Job Search Workflow

1. Start from the requested Liepin page or search URL.
2. Let the page load in the live browser session.
3. Inspect recent XHR/fetch traffic from the active Liepin tab in the dedicated profile browser.
4. Ignore CORS preflight records (`type=Preflight` or `OPTIONS`) for job APIs. Only treat `type=XHR` or `type=Fetch` responses as data-bearing candidates.
5. If the same API URL appears as both preflight and XHR/fetch, select the XHR/fetch request ID when reading response body.
6. Look for the request that returns the job list data currently shown in the page.
7. Read that request/response payload and summarize the relevant fields for the user.
8. If the user asks for a different sort or filter, change it in the page first, then inspect the updated request/response.

## DOM Interaction Workflow

When the user asks to click, greet, open, or apply:

1. Take a fresh accessibility or DOM snapshot from the active Liepin tab.
2. Identify the exact element for the requested action.
3. Click only the requested control.
4. Re-check the page state and, when useful, confirm the corresponding network activity.
5. Avoid repeated rapid-fire actions; keep the workflow deliberate and user-directed.
6. If the action is happening in any browser other than the dedicated Liepin profile browser, stop and correct the session first.

## Browser Control Strategy

Prefer this order:

1. Use Chrome DevTools MCP or harness browser tools if they are confirmed to be attached to the dedicated profile browser described by `session.json`.
2. If those tools are attached to a blank harness browser or a different browser context, do not use that browser for Liepin.
3. In that mismatch case, fall back to direct CDP control against the dedicated browser's debugger endpoint from `session.json`.

The rule is not "always use one tool prefix." The rule is "always operate on the dedicated Liepin browser session."

When the user asks to deliver resumes or apply to jobs:

1. Open the specific job detail page instead of relying only on search-card state.
2. Check whether the page exposes `投简历`. If it does not, do not count the listing as a delivered application yet.
3. If `投简历` opens a resume-selection modal, complete the second confirmation step such as `立即投递`.
4. Count the attempt as successful only if the page shows `投递成功` or navigates to an apply-success URL under `c.liepin.com/job/apply/success`.
5. If a listing only allows `聊一聊` or `继续聊`, treat it as a chat-only path rather than a successful resume delivery.

When verifying chat success or summarizing conversation records:

1. The Liepin page often persists historical chat context from other recruiters in the side panel or background DOM.
2. Do not blindly extract `document.body.innerText` to prove a greeting succeeded, as you may summarize irrelevant history.
3. Instead, rely on the `Network` panel to confirm the sent-message payload, or use precise DOM selectors targeting the active chat modal overlay to verify the intended message appears as sent/unread.

## Fallbacks

- Login expired or missing: Stop automated progress, navigate to the relevant Liepin login-capable page if needed, confirm the login prompt or logged-out state in the browser, and tell the user to complete login manually in the isolated Chrome window. Resume only after the session is authenticated. Never guess credentials or attempt to bypass login.
- No matching request found: Refresh the page state by reloading, changing the search, or re-triggering the user-requested action in the browser, then inspect network traffic again. If the page still does not expose a clear request, say explicitly that the job-list request could not be confirmed from current network activity. At that point, either fall back to reading the visible page content or ask the user whether an on-page-only summary is acceptable.
- Preflight-only match: If the only matched request is a preflight/`OPTIONS` entry, do not treat it as a job-data response. Keep searching for the corresponding XHR/fetch request with the same API URL and a retrievable response body.
- Endpoint renamed or changed: Do not rely on one historical request name. Match requests by page action, payload shape, response structure, and returned job or recruiter fields. If the old endpoint is gone, inspect adjacent XHR/fetch requests from the same interaction and continue with the one that carries the needed data.
- Wrong browser session attachment or no attachment: If the browser tools show the wrong tabs, cannot see the isolated session, or appear disconnected, stop and say explicitly that you are not attached to the intended dedicated Liepin browser yet. Do not pretend attachment succeeded. Re-run the preflight flow, verify the isolated Chrome was launched, verify the debug endpoint again, and continue only after page listing confirms the correct dedicated Liepin tab.
- Harness browser mismatch: If the harness-provided browser tools stay attached to a blank `about:blank` page while the dedicated Liepin browser is logged in elsewhere, do not treat the blank harness browser as the target session. Read `session.json`, verify the dedicated debugger endpoint, and either re-attach correctly with a `browser-url` style connection or fall back to direct CDP against that endpoint.
- Missing or stale session metadata: If `session.json` is missing, stale, or points to an unreachable endpoint, relaunch the dedicated browser so the launcher can write fresh session metadata before continuing.
- Launcher port conflict: If the launcher reports that the configured remote debugging port is already in use, treat that as a hard failure for the dedicated Liepin session. Do not silently switch to another port inside the skill. Tell the user to close the conflicting process or relaunch with a different `LIEPIN_DEBUG_PORT`, then reconnect to that dedicated browser.
- Launcher early exit or endpoint timeout: If the launcher reports that Chrome exited before DevTools became ready, or that the DevTools endpoint never became reachable, treat that as launcher failure. Tell the user to relaunch only after confirming the isolated Chrome window can stay open and the configured debug endpoint becomes reachable again.
- Chrome DevTools MCP cannot control the dedicated browser yet: Ask the user to open `chrome://inspect/#remote-debugging` in the dedicated profile browser, enable remote debugging there, close that tab, and then tell the agent it may continue. After that, retry the connection to the same dedicated browser rather than opening a fresh one.

## Safety Notes

- Use a real browser workflow with the user's awareness and current session state.
- Treat `profile/` as local runtime state only; do not describe it as shareable package content.
- Never act as if browser attachment succeeded when it has not been confirmed by the browser tools.
- Treat launcher errors as blockers, not as invitations to improvise around the isolated browser session.
- Do not count chat-only flows as resume delivery; count only verified apply-success states.
- The dedicated profile browser is the persisted session store for this skill; later runs should reuse it rather than creating a fresh login state.
- If the user asks for bulk or risky actions, stay within the exact scope they requested and confirm results from the page before claiming success.
