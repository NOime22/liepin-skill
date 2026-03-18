# Liepin Assistant Repair Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Repair the `liepin-assistant` skill package so it is safer, more portable, and better evaluated without shipping runtime browser state.

**Architecture:** Keep the package structure intact while tightening three layers: package hygiene, instruction quality, and validation coverage. Treat `profile/` as local runtime state inside the skill directory, enforce that through ignore rules and docs, then update the skill, launcher, and eval files to match the safer distribution model.

**Tech Stack:** Markdown, JSON, Bash, Chrome DevTools-based browser workflows

---

## Chunk 1: Package Hygiene And Safety

### Task 1: Ignore local runtime artifacts

**Files:**
- Create: `/Users/ysy/.agents/skills/liepin-assistant/.gitignore`
- Modify: `/Users/ysy/.agents/skills/liepin-assistant/README.md`

- [ ] **Step 1: Add ignore rules for `profile/`, `.DS_Store`, and other local runtime artifacts**
- [ ] **Step 2: Verify the rules cover `profile/`, `.DS_Store`, and local runtime byproducts**
- [ ] **Step 3: Document that `profile/` is runtime-only local state**

### Task 2: Remove local junk files from the shareable set

**Files:**
- Delete: `/Users/ysy/.agents/skills/liepin-assistant/.DS_Store`

- [ ] **Step 1: Remove `.DS_Store`**
- [ ] **Step 2: Verify it no longer appears in the package listing**

## Chunk 2: Skill And README Repair

### Task 3: Rewrite the skill entrypoint for safer triggers and portable tool guidance

**Files:**
- Modify: `/Users/ysy/.agents/skills/liepin-assistant/SKILL.md`

- [ ] **Step 1: Rewrite frontmatter so description is trigger-based**
- [ ] **Step 2: Replace environment-specific tool names with portable Chrome DevTools guidance**
- [ ] **Step 3: Add the exact preflight flow: launch isolated Chrome, verify the debug endpoint, attach browser tools to the intended session, then navigate if needed**
- [ ] **Step 4: Add an explicit fallback for login expired or missing**
- [ ] **Step 5: Add an explicit fallback for no matching network request found**
- [ ] **Step 6: Add an explicit fallback for endpoint names changing or being renamed**
- [ ] **Step 7: Add an explicit fallback for browser tools attaching to the wrong browser session or not attaching at all**
- [ ] **Step 8: State that result ordering defaults to the site's current ordering unless the user requests another sort**
- [ ] **Step 9: Remove anti-bot bypass framing while preserving the real-browser workflow**

### Task 4: Rewrite the human-facing README to match the repaired model

**Files:**
- Modify: `/Users/ysy/.agents/skills/liepin-assistant/README.md`

- [ ] **Step 1: Reframe the skill description in neutral terms**
- [ ] **Step 2: Clarify installation and local profile behavior**
- [ ] **Step 3: Add explicit guidance that `profile/` must not be included in commits, exports, release bundles, or shared archives**

## Chunk 3: Script And Eval Hardening

### Task 5: Tighten the launcher script defaults

**Files:**
- Modify: `/Users/ysy/.agents/skills/liepin-assistant/scripts/launch_liepin_chrome.sh`

- [ ] **Step 1: Keep the isolated profile behavior, exact profile path, and remote debugging port behavior**
- [ ] **Step 2: Preserve creation of `/Users/ysy/.agents/skills/liepin-assistant/profile` on demand when missing**
- [ ] **Step 3: Remove broad flags unless required**
- [ ] **Step 4: Improve recovery messaging for missing Chrome or debugging issues**
- [ ] **Step 5: Run `bash -n /Users/ysy/.agents/skills/liepin-assistant/scripts/launch_liepin_chrome.sh`**

### Task 6: Replace fragile evals with workflow and failure-path coverage

**Files:**
- Modify: `/Users/ysy/.agents/skills/liepin-assistant/evals/evals.json`

- [ ] **Step 1: Rewrite the happy-path eval to cover a standard Liepin job search workflow and correct tool/process selection**
- [ ] **Step 2: Add login interruption coverage**
- [ ] **Step 3: Add missing-request or renamed-endpoint coverage**
- [ ] **Step 4: Add connection-failure coverage**

## Chunk 4: Verification

### Task 7: Verify the repaired package state

**Files:**
- Verify: `/Users/ysy/.agents/skills/liepin-assistant/SKILL.md`
- Verify: `/Users/ysy/.agents/skills/liepin-assistant/README.md`
- Verify: `/Users/ysy/.agents/skills/liepin-assistant/.gitignore`
- Verify: `/Users/ysy/.agents/skills/liepin-assistant/evals/evals.json`
- Verify: `/Users/ysy/.agents/skills/liepin-assistant/scripts/launch_liepin_chrome.sh`

- [ ] **Step 1: Read the repaired files and confirm they match the design**
- [ ] **Step 2: Run `bash -n /Users/ysy/.agents/skills/liepin-assistant/scripts/launch_liepin_chrome.sh` and confirm syntax is valid**
- [ ] **Step 3: Read `SKILL.md` and confirm the renamed-endpoint fallback and default-ordering guidance are present**
- [ ] **Step 4: Read `README.md` and confirm it forbids including `profile/` in commits, exports, release bundles, and shared archives**
- [ ] **Step 5: Run an explicit shareable-package inventory check and confirm `profile/` runtime data is absent from the shareable set before any completion claim**
- [ ] **Step 6: Confirm `profile/` remains local but excluded from the shareable set**
- [ ] **Step 7: Summarize the resulting package changes and any remaining manual follow-up**
