# Chaos Arena — « Venez casser mon infrastructure »

Un site public où les visiteurs déclenchent des pannes de plus en plus graves
sur mon infrastructure, et la regardent se réparer seule, en direct.
Niveau ultime : tout le datacenter « brûle », et l'infrastructure renaît sur Azure
en moins de 15 minutes.

## Les 5 niveaux
| Niveau | Panne | Réparation |
|---|---|---|
| 1 | Tuer une application | Kubernetes la relance |
| 2 | Éteindre un serveur | Terraform et Ansible recréent la VM |
| 3 | Couper le réseau | Détection et réparation automatiques |
| 4 | Supprimer la base | Restauration depuis Azure |
| 5 | Datacenter en feu | Bascule et reconstruction complète sur Azure |

## Architecture
- **Maison** : Proxmox, pfSense (4 VLAN isolés), cluster k3s
- **Azure** : sauvegardes, secrets, site de secours
- **Outils** : Terraform, Ansible, Docker, Kubernetes, GitHub Actions, Argo CD,
  Prometheus, Grafana, Loki, Chaos Mesh, Cloudflare

## Avancement
- [x] Phase 0 · Préparation
- [x] Phase 1 · Fondations
- [ ] Phase 2 · Les VM en code
- [ ] Phase 3 · L'application vitrine
- [ ] Phase 4 · Kubernetes
- [ ] Phase 5 · CI/CD et GitOps
- [ ] Phase 6 · Supervision
- [ ] Phase 7 · Azure et lien hybride
- [ ] Phase 8 · Sauvegardes
- [ ] Phase 9 · Niveaux 1 à 4
- [ ] Phase 10 · Niveau 5
- [ ] Phase 11 · Le site
- [ ] Phase 12 · Sécurité
- [ ] Phase 13 · Lancement

## Documentation
Voir le dossier [`docs/`](docs/).
