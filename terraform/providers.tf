# ----------------------------------------------------------------------
# File: terraform/providers.tf
#
# Dokumentasi:
#   File ini mendefinisikan provider dan konfigurasi dasar untuk Terraform
#   yang digunakan untuk berinteraksi dengan Proxmox melalui provider 
#   bpg/proxmox. Pastikan variabel pve_endpoint dan pve_api_token sudah 
#   didefinisikan pada file variable atau environment sesuai kebutuhan Anda.
#
#   - terraform block: Menentukan versi Terraform minimum dan provider required.
#   - provider "proxmox": Konfigurasi endpoint Proxmox, API token, dan SSH key.
#     Perhatian: File private key harus tersedia di path yang tercantum.
# ----------------------------------------------------------------------

terraform {
  required_version = ">= 1.6"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.66"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

provider "proxmox" {
    # Endpoint Proxmox, gunakan variable atau isi dengan URL endpoint Proxmox Anda
    endpoint = var.pve_endpoint
    # API Token untuk autentikasi ke Proxmox, pastikan sudah sesuai
    api_token = var.pve_api_token
    # Jangan gunakan pada production jika tidak yakin, true untuk sertifikat self-signed
    insecure = true

    ssh {
        agent = false
        # Username SSH untuk mengakses Proxmox node, defaultnya "root"
        username = "root"
        # Path ke file private key SSH, pastikan file ini tersedia dan memiliki permission yang benar
        private_key = file("~/.ssh/homelab")
    }
}

provider "cloudflare" {
  api_token = var.cf_api_token
}