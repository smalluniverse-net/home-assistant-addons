# haos-addons-work

Promoted from `~/GitHub/project/OpenAI/Drafts/Repo Manifests/haos-addons-work.REPO.md` on 2026-05-09 PT.

## Repo Role

- Owner: `smalluniverse-net`
- Repo path: `/Users/michal/GitHub/haos-addons-work`
- Remote: `git@github.com:smalluniverse-net/home-assistant-addons.git`
- Role: `infrastructure`
- Canonical for: SmallUniverse Home Assistant add-on fork/work repository, including Grafana-related add-ons and local fork modifications.
- Reads allowed by default: yes.
- Writes allowed by default: no for deployment-affecting code or config without explicit Claude/user approval. Mechanical hygiene (e.g. `.gitignore` `.DS_Store`) is permitted on a feature branch with no direct push to `main`.
- Deployment surface: Home Assistant add-ons, Dockerfiles, add-on `config.yaml` schemas, add-on rootfs, exposed ports, AppArmor settings, GitHub workflows, container images.
- Secret surfaces: add-on options and schemas such as `access_token`, Home Assistant API access, addon config mappings, and any runtime files under rootfs that consume token values.
- Required validation: read project `CLAUDE.md`, `Memory/MEMORY.md`, `Memory/decisions_log.md`, `Memory/reference_cross_agent_staging.md`, the active `OpenAI/Approved/` contract, and relevant project HAOS/observability canonical sources before proposing changes. Live HAOS changes are off-limits to non-Claude agents.
- Status pointer: project canonical HAOS, observability, and automation state lives in `~/GitHub/project/Inventory.md`, `~/GitHub/project/Status/Observability Status.md`, `~/GitHub/project/Memory/reference_observability_config_change_rule.md`, and related canonical files.

## Instruction Surface

- Project-level `CLAUDE.md` and `AGENTS.md` govern agent behavior in this repo.
- This `REPO.md` is a tracked manifest; updates flow through staged-then-promoted in the project repo.

## Write Policy

Default lanes for non-Claude agents:

- Read this repo for staged review.
- Write `grafana_cloud/` security audit findings to `~/GitHub/project/OpenAI/Audits/`.
- Write patch proposals to `~/GitHub/project/OpenAI/Drafts/`.

Off-limits without explicit Claude/user approval:

- Editing add-on code, `config.yaml`, Dockerfiles, rootfs files, workflows, or deployed configuration directly.
- Pushing `main` directly. Use a feature branch and surface for review.
- Deploying to HAOS or modifying add-on runtime state.

## Audit Focus (Active)

- Token schema and whether token fields are typed and handled safely (P3 finding open: `access_token` is a plain string field).
- Exposed ports and whether descriptions match actual purpose (P1 finding closed: ports relabeled as override-only on 2026-05-09 PT to match the bundled `config.alloy` reality).
- `apparmor: false` plus `addon_config:rw` blast-radius (P2 user decision pending).
- Dockerfile download and installation behavior.
- Rootfs/run script behavior, including the `LOG_LEVEL` wiring (P1 deferred: pending Alloy `env()` syntax verification).
- Secret handling in generated config and logs.

## Cross-References

- Audit: `~/GitHub/project/Reports/Security/Grafana Cloud Addon Security Review 2026-05-07.md`
- Patch proposal: `~/GitHub/project/Cursor/Promote/Patch Diffs - grafana cloud addon - 2026-05-08.md`
