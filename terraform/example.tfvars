# Copy to terraform.tfvars and fill in your values (terraform.tfvars is gitignored).
pve_endpoint   = "https://192.168.1.11:8006/"
pve_api_token  = "root@pam!tf=YOUR-TOKEN-UUID-HERE"
ssh_public_key = "ssh-ed25519 AAAA...your-public-key... homelab"

# Optional — Fase 13 Cloudflare DNS (after tunnel created in Zero Trust)
# enable_cloudflare_dns   = true
# cf_api_token            = "your-cloudflare-api-token"
# cf_zone_id              = "your-zone-id"
# domain                  = "lab.example.com"
# cloudflare_tunnel_cname = "<tunnel-uuid>.cfargotunnel.com"
