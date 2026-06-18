# ----------------------------------------------------------------------
# File: terraform/outputs.tf
#
# Dokumentasi:
#   File ini mendefinisikan resources dan output yang digunakan untuk 
#   otomasi pembuatan inventory Ansible serta output penting untuk 
#   konsumsi eksternal, seperti daftar IP VM hasil provision.
#
#   - local_file "ansible_inventory":
#       - Membuat file inventory hosts.ini untuk Ansible secara otomatis berdasarkan 
#         VM yang didefinisikan pada variable "nodes".
#       - Menyaring dan mengelompokkan VM dengan role "server" dan "agent" untuk 
#         template inventory menggunakan templatefile.
#       - Output file akan dihasilkan di direktori ansible/inventory.
#
#   - output "vm_ips":
#       - Mengeluarkan peta nama VM ke alamat IP (berasal dari variable "nodes")
#         sehingga dapat digunakan untuk automasi atau debugging lebih lanjut.
# ----------------------------------------------------------------------

resource "local_file" "ansible_inventory" {
    filename = "${path.module}/../ansible/inventory/hosts.ini"
    content = templatefile("${path.module}/templates/inventory.tftpl", {
        servers = { for k, v in var.nodes : k => v if v.role == "server" }
        agents = { for k, v in var.nodes : k => v if v.role == "agent" }
    })
}

output "vm_ips" {
  value = { for k, v in var.nodes : k => v.ip }
}
