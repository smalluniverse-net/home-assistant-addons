# Changelog

## 13.0.1 (2026-04-24)

- Initial release under `smalluniverse-net/home-assistant-addons`.
- Ports the mxssmu/addon-grafana fork of `hassio-addons/addon-grafana`
  wholesale (Dockerfile, s6-overlay init, nginx ingress, grafana.ini, memcached,
  optional image renderer).
- Bundles Grafana `13.0.1` (upstream stable, published 2026-04-17) in place of
  the `12.1.0` wrapper / Grafana `12.3.0` binary shipped by the community
  addon release from 2025-11-22.
- Replaces the long-stale `a0d7b954_grafana` install on HAOS. Datasources
  (Loki local, VictoriaMetrics) and dashboards (12 Scenes-based) are migrated
  via the separate cutover task.
