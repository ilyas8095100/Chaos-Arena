# Phase 0 : Fondations

## Objectif
Préparer Proxmox, créer un poste de contrôle (CT admin), sécuriser le VPS.
Contrainte : rien ne reste sur le PC personnel.

## Point de départ
- Proxmox 9.2 déjà installé (192.168.1.50)
- CT 100 WireGuard conservé (accès distant), anciens CT supprimés

## Ce qui a été fait
### Serveur maison
- Réservations DHCP (Proxmox, WireGuard)
- Dépôts No-Subscription, système à jour (reboot en attente)
- CT 101 admin Debian 13 (2 vCPU, 2 Go, 16 Go), IP fixe, démarrage auto

### VPS
- Debian 13, à jour, fuseau, hostname
- SSH : clés uniquement, root interdit (00-hardening.conf)
- UFW : tout bloqué en entrée sauf SSH
- Fail2ban : 5 échecs / 10 min = ban 1h
- Mises à jour automatiques + reboot à 4h si nécessaire

## Choix et justifications
- Conteneur LXC plutôt que VM pour l'admin : …
- Clé ed25519 : …
- Fichier 00-hardening.conf : …

## Problèmes rencontrés et solutions
- …

## À faire au retour à la maison
- [ ] Reboot de Proxmox (nouveau noyau)
- [ ] Vérifier la virtualisation dans le BIOS si besoin
