# ----------------------------------------------------------------------
# File: terraform/vms.tf
#
# Dokumentasi:
#   File ini mendefinisikan resource VM "k3s" pada Proxmox, dikelola dengan Terraform.
#   VM akan dibuat berdasarkan daftar konfigurasi pada variable "nodes" (peta VM).
#   Setiap VM yang dibuat:
#     - Menggunakan template sebagai dasar (cloning)
#     - Diberi spesifikasi CPU, RAM, Disk sesuai kebutuhan
#     - Diberi tag sesuai role (server/agent) untuk identifikasi
#     - Diberikan IP statis, gateway, dan nameserver secara otomatis lewat cloud-init
#     - Dilengkapi SSH public key untuk akses otomatis oleh user "ubuntu"
#     - Lifecycle diatur agar perubahan pada "clone" dan "initialization" diabaikan setelah provisioning awal
#   Konfigurasi komponen (CPU, RAM, disk, jaringan) dan parameter lain diambil dari variable pada file variable.tf
# ----------------------------------------------------------------------

resource "proxmox_virtual_environment_vm" "k3s" {
    # Mengiterasi setiap entri pada var.nodes, setiap VM didefinisikan oleh key serta value (objek konfigurasi)
    for_each = var.nodes

    # Nama VM sesuai key pada var.nodes
    name = each.key

    # Node Proxmox tujuan pembuatan VM
    node_name = each.value.target_node

    # VMID unik untuk VM di Proxmox (wajib unik per node)
    vm_id = each.value.vmid

    # Tag tambahan untuk memudahkan pencarian dan otomasi
    tags = ["k3s", each.value.role, "terraform"]

    # Clone dari template image VM (ID dan node sumber template dikonfigurasi via variable)
    clone {
        vm_id    = var.template_id
        node_name = var.template_node
        full      = true # Full copy, bukan linked clone
    }

    # Mengaktifkan QEMU Guest Agent untuk VM - diperlukan untuk fitur integrasi cloud-init dan monitoring
    agent {
        enabled = true
    }

    # Konfigurasi CPU: jumlah core dan tipe CPU mengikuti host (maksimal kompatibilitas)
    cpu {
        cores = each.value.cores
        type  = "host"
    }

    # Konfigurasi RAM: alokasi memory (dalam MB)
    memory {
        dedicated = each.value.memory
    }

    # Konfigurasi disk utama: ukuran (GB), interface tipe SCSI, enable trim/discard, aktivasi SSD flag
    disk {
        datastore_id = "local-lvm"
        interface    = "scsi0"
        size         = each.value.disk_gb
        discard      = "on"
        ssd          = true
    }

    # Konfigurasi jaringan: bridge Proxmox utama (vmbr0) dan model Virtio (kinerja tinggi)
    network_device {
        bridge = "vmbr0"
        model  = "virtio"
    }

    # Konfigurasi cloud-init/initialization: penetapan IP static, gateway, DNS, dan SSH key
    initialization {
        datastore_id = "local-lvm"
        ip_config {
            ipv4 {
                address = "${each.value.ip}/24" # subnet /24
                gateway = var.gateway
            }
        }
        dns {
            servers = [var.nameserver]
        }
        user_account {
            username = "ubuntu"
            keys     = [var.ssh_public_key]
        }
    }

    # Lifecycle: mengabaikan perubahan pada section clone dan initialization setelah provisioning awal
    lifecycle {
        ignore_changes = [ clone, initialization ]
    }
}