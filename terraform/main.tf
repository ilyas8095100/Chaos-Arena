# Une VM par entrée de var.nodes (for_each)
resource "proxmox_virtual_environment_vm" "k3s" {
  for_each = var.nodes

  name      = each.key
  node_name = var.proxmox_node
  vm_id     = each.value.vm_id
  tags      = ["chaos-arena", "k3s", each.value.role]

  # Copie complète du modèle cloud-init
  clone {
    vm_id = var.template_id
    full  = true
  }

  # L'agent QEMU permet à Terraform de lire l'IP de la VM
  agent {
    enabled = true
  }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 20
  }

  # Branchée dans le VLAN 30 (K8S)
  network_device {
    bridge  = "vmbr1"
    vlan_id = 30
  }

  # Configuration injectée par cloud-init au premier démarrage
  initialization {
    datastore_id = "local-lvm"

    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = var.gateway
      }
    }

    dns {
      servers = [var.gateway]
      domain  = "home.arpa"
    }

    user_account {
      username = "ilyas"
      keys     = [trimspace(file(pathexpand(var.ssh_public_key_path)))]
    }
  }

  # Éteint la VM avant de la supprimer
  stop_on_destroy = true
}
