# Cloudflare DNS for public apps (Fase 13)
# Admin endpoints (Proxmox, k8s API, Grafana, ArgoCD) are NOT created here — Tailscale only.

resource "cloudflare_record" "wildcard_apps" {
  count   = var.enable_cloudflare_dns ? 1 : 0
  zone_id = var.cf_zone_id
  name    = "*"
  type    = "CNAME"
  content = var.cloudflare_tunnel_cname
  proxied = true
  comment = "homelab public apps via cloudflare tunnel"
}

resource "cloudflare_record" "root_app" {
  count   = var.enable_cloudflare_dns ? 1 : 0
  zone_id = var.cf_zone_id
  name    = "@"
  type    = "CNAME"
  content = var.cloudflare_tunnel_cname
  proxied = true
  comment = "homelab root via cloudflare tunnel"
}
