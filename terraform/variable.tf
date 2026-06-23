# ----------------------------------------------------------------------
# File: terraform/variable.tf
#
# Dokumentasi:
#   File ini berisi definisi variabel yang digunakan untuk konfigurasi 
#   deployment infrastruktur Proxmox menggunakan Terraform.
#   Setiap variabel mempunyai peran penting sesuai dengan kebutuhan VM
#   dan infrastruktur yang dideploy.
#
#   Variabel:
#   - pve_endpoint: URL endpoint atau IP Proxmox VE API.
#   - pve_api_token: API token untuk autentikasi ke Proxmox VE (sensitive).
#   - ssh_public_key: Public SSH key yang akan digunakan pada VM.
#   - template_id: ID template VM dasar pada Proxmox, default 9000.
#   - template_node: Node tempat template VM berada, default "pve".
#   - gateway: Default gateway untuk VM, default "192.168.1.1".
#   - nameserver: DNS nameserver untuk VM, default "1.1.1.1".
#   - nodes: Peta konfigurasi VM yang akan dideploy, berisi spesifikasi
#            tiap VM berupa target_node, vmid, role, core, memory, disk, dan ip.
# ----------------------------------------------------------------------

variable "pve_endpoint" { 
    type = string 
    description = "Endpoint (URL/IP) dari Proxmox VE API yang akan digunakan."
}

variable "pve_api_token" {
    type      = string
    sensitive = true
    description = "API Token untuk autentikasi ke Proxmox VE."
}

variable "ssh_public_key" { 
    type = string 
    description = "SSH public key yang akan dipasang di VM baru."
}

variable "template_id" { 
    type    = number 
    default = 9000 
    description = "ID dari template VM yang ada di Proxmox untuk cloning VM baru."
}

variable "template_node" { 
    type    = string 
    default = "pve" 
    description = "Nama node pada Proxmox yang menyimpan template VM."
}

variable "gateway" { 
    type    = string 
    default = "192.168.1.1"
    description = "Alamat IP gateway default untuk VM."
}

variable "nameserver" { 
    type    = string 
    default = "1.1.1.1"
    description = "Alamat IP nameserver/DNS yang digunakan VM."
}

variable "nodes" {
    type = map(object({
        target_node = string # Nama node Proxmox tempat VM ditempatkan
        vmid        = number # VM ID unik pada Proxmox
        role        = string # Peran/role VM (misal: server/agent)
        cores       = number # Jumlah CPU core
        memory      = number # Besaran memory (MB)
        disk_gb     = number # Besaran disk (GB)
        ip          = string # Alamat IP statis VM
    }))
    description = "Daftar konfigurasi VM yang akan dibuat di Proxmox. Key adalah nama VM yang diinginkan."

    default = {
        "k3s-server-1" = {target_node = "pve-opti-01", vmid = 121, role = "server", cores = 4, memory = 12288, disk_gb = 40, ip = "192.168.1.21"}
        "k3s-server-2" = {target_node = "pve",         vmid = 122, role = "server", cores = 6, memory = 12288, disk_gb = 300, ip = "192.168.1.22"}
        "k3s-server-3" = {target_node = "think-01",    vmid = 123, role = "server", cores = 4, memory = 12288, disk_gb = 40, ip = "192.168.1.23"}
        "k3s-agent-1"  = {target_node = "think-02",    vmid = 124, role = "agent",  cores = 4, memory = 12288, disk_gb = 60, ip = "192.168.1.24"}
        "k3s-agent-2"  = {target_node = "elitdesk",    vmid = 125, role = "agent",  cores = 4, memory = 12288, disk_gb = 40, ip = "192.168.1.25"}
    }
}

# ---- Cloudflare DNS (Fase 13, optional) ----

variable "enable_cloudflare_dns" {
  type        = bool
  default     = false
  description = "Set true to manage public app DNS via Cloudflare (wildcard CNAME to tunnel)."
}

variable "cf_api_token" {
  type        = string
  sensitive   = true
  default     = ""
  description = "Cloudflare API token (Zone DNS Edit + Account Cloudflare Tunnel Read)."
}

variable "cf_zone_id" {
  type        = string
  default     = ""
  description = "Cloudflare zone ID for the public domain."
}

variable "domain" {
  type        = string
  default     = ""
  description = "Public domain, e.g. lab.example.com."
}

variable "cloudflare_tunnel_cname" {
  type        = string
  default     = ""
  description = "Tunnel CNAME target, e.g. <tunnel-id>.cfargotunnel.com (from Zero Trust after creating tunnel)."
}