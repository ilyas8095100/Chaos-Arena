variable "proxmox_endpoint" {
  description = "Adresse de l'API Proxmox"
  type        = string
  default     = "https://192.168.1.50:8006/"
}

variable "proxmox_api_token" {
  description = "Jeton API (fourni par la variable d'environnement TF_VAR_proxmox_api_token)"
  type        = string
  sensitive   = true
}


variable "proxmox_node" {
  description = "Nom du nœud Proxmox"
  type        = string
  default     = "pve"
}

variable "template_id" {
  description = "ID du modèle cloud-init à cloner"
  type        = number
  default     = 9000
}

variable "gateway" {
  description = "Passerelle et DNS du VLAN 30 (pfSense)"
  type        = string
  default     = "10.10.30.1"
}

variable "ssh_public_key_path" {
  description = "Clé publique SSH injectée dans les VM"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "nodes" {
  description = "Les VM du cluster k3s"
  type = map(object({
    vm_id  = number
    ip     = string
    role   = string
    cores  = number
    memory = number
  }))
  default = {
    "k3s-cp" = { vm_id = 301, ip = "10.10.30.10", role = "control-plane", cores = 2, memory = 3072 }
    "k3s-w1" = { vm_id = 302, ip = "10.10.30.11", role = "worker", cores = 2, memory = 3072 }
    "k3s-w2" = { vm_id = 303, ip = "10.10.30.12", role = "worker", cores = 2, memory = 3072 }
  }
}
