# Inventaire

| Nom | Rôle | Emplacement | IP | OS | Accès |
|---|---|---|---|---|---|
| pve | Hyperviseur | Maison | 192.168.1.50 | Proxmox VE 9.2 | ssh pve / https://192.168.1.50:8006 |
| wireguard (CT 100) | Accès distant (ancien, remplacé en phase 1) | Maison (LXC) | IP_WIREGUARD (réservation DHCP) | ? | VPN UDP XXXXX |
| admin (CT 101) | Poste de contrôle | Maison (LXC) | IP_ADMIN | Debian 13 | ssh depuis LAN/VPN |
| vps-edge | Point d'entrée public | OVH | IP_DU_VPS | Debian 13 | ssh vps (depuis admin) |

## Réseau maison
- Réseau : 192.168.1.0/24
- Passerelle (box) : 192.168.1.1
- Plage DHCP de la box : …
- Réservations : .50 (pve), IP_WIREGUARD (CT 100)

## Matériel serveur maison
- CPU :
- RAM :
- Disques :
