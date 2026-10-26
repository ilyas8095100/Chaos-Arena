# Chaos Arena — « Venez casser mon infrastructure »

Un site public où les visiteurs déclenchent des pannes de plus en plus graves
sur mon infrastructure, et la regardent se réparer seule, en direct.
Niveau ultime : tout le datacenter « brûle », et l'infrastructure renaît sur Azure
en moins de 15 minutes.

## Les 5 niveaux

| Niveau | Panne | Réparation | Objectif |
|---|---|---|---|
| 1 | Tuer une application | Kubernetes la relance | Quelques secondes |
| 2 | Éteindre un serveur | Terraform et Ansible recréent la VM | Quelques minutes |
| 3 | Couper le réseau | Détection et réparation automatiques | Quelques minutes |
| 4 | Supprimer la base | Restauration depuis Azure | Moins de 10 min |
| 5 | Datacenter en feu | Bascule et reconstruction sur Azure | Moins de 15 min |

## Architecture

**Maison · serveur HP Z240 (i7-7700, 16 Go, SSD 512 Go)**
- **Proxmox VE** : l'hyperviseur
- **pfSense** : firewall, DHCP, DNS, accès distant Tailscale
- **4 VLAN isolés** :

| VLAN | Réseau | Rôle |
|---|---|---|
| 10 · ADMIN | `10.10.10.0/24` | Poste de contrôle, seul réseau qui accède à tout |
| 20 · SERVEURS | `10.10.20.0/24` | Outils qui doivent survivre aux pannes (runner CI, sonde) |
| 30 · K8S | `10.10.30.0/24` | Le cluster k3s : l'arène que les visiteurs cassent |
| 40 · DMZ | `10.10.40.0/24` | Point d'entrée public (tunnel Cloudflare) |

- Aucun port ouvert sur la box : accès admin par Tailscale, accès public par tunnel Cloudflare.

**Azure** : sauvegardes, secrets, site de secours.

**Outils** : Terraform, Ansible, Docker, Kubernetes (k3s), GitHub Actions, Argo CD,
Prometheus, Grafana, Loki, Chaos Mesh, Cloudflare.

## Avancement

- [x] Phase 0 · Préparation
- [x] Phase 1 · Fondations
- [ ] Phase 2 · Les VM en code
- [ ] Phase 3 · L'application vitrine
- [ ] Phase 4 · Déploiement sur Kubernetes
- [ ] Phase 5 · CI/CD et GitOps
- [ ] Phase 6 · Supervision
- [ ] Phase 7 · Azure et lien hybride
- [ ] Phase 8 · Sauvegardes et restauration
- [ ] Phase 9 · Les niveaux 1 à 4
- [ ] Phase 10 · Niveau 5 : le datacenter en feu
- [ ] Phase 11 · Le site Chaos Arena
- [ ] Phase 12 · Sécurité et ouverture au public
- [ ] Phase 13 · Lancement et valorisation

## Aide-mémoire des commandes

> 📍 indique la machine où la commande se tape. Clique sur une phase pour l'ouvrir.

<details>
<summary><b>Socle · Sécurisation et accès SSH</b></summary>

| Commande | 📍 | À quoi elle sert |
|---|---|---|
| `ssh-keygen -t ed25519 -C "admin-homecloud"` | CT admin | Crée la paire de clés SSH (privée + publique) |
| `ssh-copy-id debian@IP_DU_VPS` | CT admin | Installe la clé publique sur un serveur pour s'y connecter sans mot de passe |
| `scp ~/.ssh/id_ed25519.pub pve:/root/admin.pub` | CT admin | Copie un fichier vers une autre machine via SSH |
| `sudo sshd -t && sudo systemctl restart ssh` | VPS | Vérifie la syntaxe de la config SSH, puis l'applique seulement si elle est valide |
| `sudo sshd -T \| grep -E "permitrootlogin\|passwordauthentication"` | VPS | Affiche la config SSH réellement appliquée |
| `sudo ufw default deny incoming` | VPS | Firewall : bloque tout ce qui entre par défaut |
| `sudo ufw allow OpenSSH` | VPS | Autorise SSH (à faire **avant** d'activer UFW) |
| `sudo ufw enable` / `sudo ufw status verbose` | VPS | Active le firewall / affiche ses règles |
| `sudo fail2ban-client status sshd` | VPS | Liste les IP bannies après trop d'échecs SSH |
| `sudo unattended-upgrade --dry-run --debug` | VPS | Simule les mises à jour automatiques pour vérifier qu'elles fonctionnent |
| `sudo setcap cap_net_raw+p /usr/bin/ping` | CT admin | Autorise `ping` pour un utilisateur normal dans un conteneur non privilégié |

</details>

<details>
<summary><b>Socle · Proxmox, réseau et pfSense</b></summary>

| Commande | 📍 | À quoi elle sert |
|---|---|---|
| `echo "cp /root/interfaces.bak /etc/network/interfaces && ifreload -a" \| at now + 10 minutes` | Proxmox | **Filet de sécurité** : restaure le réseau dans 10 min si une modif coupe l'accès |
| `atq` / `atrm N` | Proxmox | Liste les tâches programmées / annule la tâche n°N |
| `ip -br link show vmbr1` | Proxmox | Vérifie qu'une interface (ici le bridge du lab) existe |
| `pct config 100` | Proxmox | Affiche la configuration d'un conteneur |
| `pct exec 100 -- ip -4 addr` | Proxmox | Exécute une commande à l'intérieur d'un conteneur |
| `vzdump 101 --storage local --mode snapshot` | Proxmox | Sauvegarde un conteneur ou une VM sans l'arrêter |
| `aria2c -c -x 8 -s 8 URL` | Proxmox | Télécharge avec 8 connexions en parallèle ; `-c` reprend un téléchargement coupé |
| `gunzip fichier.iso.gz` | Proxmox | Décompresse une archive `.gz` |
| `certctl rehash` | pfSense (shell) | Reconstruit la liste des certificats de confiance |
| `pfSense-repoc` | pfSense (shell) | Récupère la configuration du dépôt de mises à jour |
| `pkg-static update -f` | pfSense (shell) | Force le téléchargement du catalogue de paquets |
| `netstat -rn \| grep default` | pfSense (shell) | Vérifie la passerelle par défaut (sans elle, pas d'Internet) |
| `dig @10.10.10.1 pve.home.arpa +short` | CT admin | Teste le DNS interne de pfSense |
| `ssh -L 8443:10.10.10.1:443 ilyas@10.10.10.10` | PC | Tunnel SSH : ouvre l'interface pfSense sur `https://localhost:8443` |

</details>

<details>
<summary><b>Phase 0 · Préparation</b></summary>

Aucune commande : création des comptes (GitHub Student Pack, Azure for Students, Cloudflare),
achat du domaine, double authentification, budget Azure et tableau de suivi se font dans le navigateur.

</details>

<details>
<summary><b>Phase 1 · Fondations</b></summary>

**Modèle de VM cloud-init**

| Commande | 📍 | À quoi elle sert |
|---|---|---|
| `wget https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2` | Proxmox | Télécharge l'image cloud officielle de Debian 13 |
| `virt-customize -a image.qcow2 --install qemu-guest-agent` | Proxmox | Installe un paquet **dans l'image** avant même de créer la VM |
| `qm create 9000 --name debian13-cloudinit --memory 2048 --cores 2 --cpu host --net0 virtio,bridge=vmbr1,tag=30 --scsihw virtio-scsi-pci --agent enabled=1` | Proxmox | Crée la VM modèle, branchée dans le VLAN 30 |
| `qm set 9000 --scsi0 local-lvm:0,import-from=image.qcow2` | Proxmox | Utilise l'image Debian comme disque de la VM |
| `qm resize 9000 scsi0 +8G` | Proxmox | Agrandit le disque de 8 Go |
| `qm set 9000 --ide2 local-lvm:cloudinit` | Proxmox | Ajoute le lecteur cloud-init (config au premier démarrage) |
| `qm set 9000 --serial0 socket --vga serial0` | Proxmox | Console sur port série (nécessaire pour les images cloud) |
| `qm set 9000 --ciuser ilyas --sshkeys /root/admin.pub --ipconfig0 ip=dhcp` | Proxmox | Utilisateur, clé SSH et réseau injectés par cloud-init |
| `qm template 9000` | Proxmox | Transforme la VM en modèle (non démarrable, clonable) |

**Clonage et test**

| Commande | 📍 | À quoi elle sert |
|---|---|---|
| `time qm clone 9000 301 --name test-clone` | Proxmox | Crée une VM à partir du modèle et mesure la durée |
| `qm start 301` / `qm stop 301` | Proxmox | Démarre / arrête une VM |
| `qm guest cmd 301 network-get-interfaces` | Proxmox | Demande l'adresse IP à l'agent dans la VM |
| `qm destroy 301` | Proxmox | Supprime définitivement une VM |
| `ssh ilyas@10.10.30.1XX` | CT admin | Connexion à la VM clonée avec la clé SSH |

**Git : une tâche = une branche = une pull request**

| Commande | 📍 | À quoi elle sert |
|---|---|---|
| `git switch main && git pull` | CT admin | Revient sur `main` et récupère la dernière version |
| `git switch -c tache-X.Y-nom` | CT admin | Crée une branche pour une tâche |
| `git add . && git commit -m "X.Y : description"` | CT admin | Enregistre les changements |
| `git push -u origin tache-X.Y-nom` | CT admin | Envoie la branche sur GitHub (puis pull request sur le site) |
| `git branch -d tache-X.Y-nom` | CT admin | Supprime la branche locale après le merge |

</details>

<details><summary><b>Phase 2 · Les VM en code</b></summary>Complété à la fin de la phase.</details>
<details><summary><b>Phase 3 · L'application vitrine</b></summary>Complété à la fin de la phase.</details>
<details><summary><b>Phase 4 · Déploiement sur Kubernetes</b></summary>Complété à la fin de la phase.</details>
<details><summary><b>Phase 5 · CI/CD et GitOps</b></summary>Complété à la fin de la phase.</details>
<details><summary><b>Phase 6 · Supervision</b></summary>Complété à la fin de la phase.</details>
<details><summary><b>Phase 7 · Azure et lien hybride</b></summary>Complété à la fin de la phase.</details>
<details><summary><b>Phase 8 · Sauvegardes et restauration</b></summary>Complété à la fin de la phase.</details>
<details><summary><b>Phase 9 · Les niveaux 1 à 4</b></summary>Complété à la fin de la phase.</details>
<details><summary><b>Phase 10 · Niveau 5 : le datacenter en feu</b></summary>Complété à la fin de la phase.</details>
<details><summary><b>Phase 11 · Le site Chaos Arena</b></summary>Complété à la fin de la phase.</details>
<details><summary><b>Phase 12 · Sécurité et ouverture au public</b></summary>Complété à la fin de la phase.</details>
<details><summary><b>Phase 13 · Lancement et valorisation</b></summary>Complété à la fin de la phase.</details>

## Documentation

Voir le dossier [`docs/`](docs/) : inventaire, plan réseau, journal de bord.
