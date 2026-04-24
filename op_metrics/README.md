# Home Assistant Add-on: 1Password Metrics

Prometheus exporter for 1Password vault metrics. Calls `op item list` every 5 minutes
and exposes `onepassword_*` metrics on `:9101/metrics`.

## Configuration

- `op_service_account_token` (required): 1Password service account token. Must have
  read access to the vaults whose items should be counted.

## Metrics

| Metric | Description |
|---|---|
| `onepassword_items_total{vault="..."}` | Total items per vault |
| `onepassword_items_updated_30d{vault="..."}` | Items updated in the last 30 days per vault |
| `onepassword_items_stale_1y` | Items not updated in over 1 year (all vaults) |
| `onepassword_items_stale_2y` | Items not updated in over 2 years (all vaults) |
| `onepassword_passwords_changed_total` | Login items updated in the last 30 days |
| `onepassword_weak_passwords` | Always 0 (Watchtower not available via service account) |

## Scraping

Scrape from Grafana Alloy (also a HAOS add-on) using the internal addon hostname:

```alloy
prometheus.scrape "op_metrics" {
  targets = [{
    "__address__" = "71dadad1-op-metrics:9101",
    "job"         = "op_metrics",
  }]
  scrape_interval = "300s"
  forward_to      = [grafana_cloud.stack.receivers.metrics]
}
```
