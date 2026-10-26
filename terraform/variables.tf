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
