---
name: liepin-assistant
description: Use when the user wants to search Liepin, review Chinese job listings, inspect recruiter or job data in a real logged-in browser session, or interact with Liepin pages such as opening jobs, greeting recruiters, or checking application flows.
---

# Liepin Assistant (猎聘小助手)

Use this skill for Liepin work that depends on a real browser session, current site state, or the user's logged-in account.

## When To Use

- Search Liepin jobs, review listings, or summarize recruiter/job details.
- Open jobs, click page controls, or help with greet/apply flows in the browser.
- Inspect network responses that the live Liepin page already loads.
- Prefer the site's current ordering unless the user explicitly asks for another sort.

## Preflight

Before doing any Liepin extraction or page interaction, follow this order exactly:

1. Launch the isolated Chrome instance with `~/.agents/skills/liepin-assistant/scripts/launch_liepin_chrome.sh` if it is not already running.
2. Verify the remote debugging endpoint is reachable for that isolated browser session.
3. Attach the available Chrome DevTools browser tools to that intended session.
4. List open pages/tabs and confirm you are attached to the isolated Liepin browser, not the user's normal browser.
5. If no suitable Liepin tab is already open, navigate to `https://www.liepin.com/` or the requested search URL.

If the browser tools expose concrete commands such as page listing, page selection, navigation, network inspection, snapshots, and clicks, use the current harness names for those actions instead of assuming one fixed prefix.

## Job Search Workflow

1. Start from the requested Liepin page or search URL.
2. Let the page load in the live browser session.
3. Inspect recent XHR/fetch traffic from the active Liepin tab.
4. Look for the request that returns the job list data currently shown in the page.
5. Read that request/response payload and summarize the relevant fields for the user.
6. If the user asks for a different sort or filter, change it in the page first, then inspect the updated request/response.

## DOM Interaction Workflow

When the user asks to click, greet, open, or apply:

1. Take a fresh accessibility or DOM snapshot from the active Liepin tab.
2. Identify the exact element for the requested action.
3. Click only the requested control.
4. Re-check the page state and, when useful, confirm the corresponding network activity.
5. Avoid repeated rapid-fire actions; keep the workflow deliberate and user-directed.

## Fallbacks

- Login expired or missing: Stop automated progress, navigate to the relevant Liepin login-capable page if needed, confirm the login prompt or logged-out state in the browser, and tell the user to complete login manually in the isolated Chrome window. Resume only after the session is authenticated. Never guess credentials or attempt to bypass login.
- No matching request found: Refresh the page state by reloading, changing the search, or re-triggering the user-requested action in the browser, then inspect network traffic again. If the page still does not expose a clear request, fall back to reading the visible page content and tell the user that network extraction was not available.
- Endpoint renamed or changed: Do not rely on one historical request name. Match requests by page action, payload shape, response structure, and returned job or recruiter fields. If the old endpoint is gone, inspect adjacent XHR/fetch requests from the same interaction and continue with the one that carries the needed data.
- Wrong browser session attachment or no attachment: If the browser tools show the wrong tabs, cannot see the isolated session, or appear disconnected, stop and re-run the preflight flow. Verify the isolated Chrome was launched, verify the debug endpoint again, re-attach the browser tools, then confirm the correct Liepin tab before continuing.

## Safety Notes

- Use a real browser workflow with the user's awareness and current session state.
- Treat `profile/` as local runtime state only; do not describe it as shareable package content.
- If the user asks for bulk or risky actions, stay within the exact scope they requested and confirm results from the page before claiming success.
