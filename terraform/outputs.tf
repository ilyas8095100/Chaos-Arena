output "k3s_nodes" {
  description = "Nom et IP de chaque nœud"
  value       = { for name, n in var.nodes : name => n.ip }
}
