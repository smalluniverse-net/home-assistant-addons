# CLAUDE.md -- haos-addons-work

> Full project rules: /Users/michal/GitHub/project/CLAUDE.md (authoritative).
> This repo contains HAOS addon work. See AGENTS.md for agent routing.

---

## 1. Local Workspace Architecture

This repository holds configurations, packaging resources, and custom build scripts for Home Assistant OS (HAOS) addons managed by the *SmallUniverse* home automation stack:
*   **`/grafana/`**: Scaffolding and local configurations for the self-hosted HAOS Grafana addon.
*   **`/grafana_cloud/`**: Configurations and filters for the HAOS Grafana Cloud Alloy bridge.
*   **`/op_metrics/`**: Custom Prometheus metrics collectors for local services.

---

## 2. Dev Commands & Execution
All execution and packaging checks must run cleanly before deployment or commits:
*   **Linting/Formatting**: Verify YAML syntax in `repository.yaml` and addon configs.
*   **Validation**: Standard repo safety checks and identity checks apply (enforced by project hooks).
