# AGENTS -- haos-addons-work

> Canonical project agents registry: /Users/michal/GitHub/project/AGENTS.md (authoritative).
> Operational policies and boundaries established in CLAUDE.md are binding across all agents.

---

## 1. Agent Coordination Lanes

All active coding agents (Claude, Codex, Cursor, and Antigravity) must operate strictly within their designated lanes for this repository:

*   **Codex / OpenAI**: Scopes to programmatic schema upgrades, automated refactoring, and static security reviews. Staging targets: `/Users/michal/GitHub/project/OpenAI/`.
*   **Cursor / Anysphere**: Scopes to IDE-interactive workspace edits, visual dashboard tweaks, and package-level debugging. Staging targets: `/Users/michal/GitHub/project/Cursor/`.
*   **Antigravity / Google**: Scopes to dashboard refresh, local telemetry collection, and local workspace safety audits. Staging targets: `/Users/michal/GitHub/project/Google/`.
*   **Claude / Anthropic**: Authoritative coordinator. Owns canonical plans, code promotion from agent staging areas, key rotation, and production deployments.

---

## 2. Path & Handoff Conventions

*   **Handoff Channel**: All cross-agent communication (all directions) must reside in `/Users/michal/GitHub/project/Automation/Handoffs/`. Do NOT write handoffs to local subfolders.
*   **Promotion Gate**: No agent-written code in this repository becomes canonical without explicit human review (Michal) or a Claude-orchestrated promotion gate recorded in `Memory/decisions_log.md`.
