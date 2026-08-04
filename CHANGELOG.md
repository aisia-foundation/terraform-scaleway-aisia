# Changelog — terraform-scaleway-aisia

Format : [Keep a Changelog](https://keepachangelog.com/) · Versioning : SemVer.

## [6.12.78] — 2026-08-04

### Changed
- Sync `image_tag` default -> `v6.12.78` (release AISIA v6.12.78 LIVE). Rattrape aussi le
  saut `v6.12.77` (VERSION + image_tag bumpés en v6.12.77 par le commit `ad31e4ac8` sans
  entrée CHANGELOG, jamais publié au registry). Aucun changement fonctionnel des
  resources/variables/outputs (patch de synchronisation de version).

## [6.12.76] — 2026-08-02

### Changed
- Sync `image_tag` default -> `v6.12.76` (release AISIA v6.12.76 LIVE). Aucun changement
  fonctionnel des resources/variables/outputs (patch de synchronisation de version).

## [1.0.0] — 2026-06-29

### Added
- Module initial publiable (HCP private registry) : substrat Kubernetes Scaleway Kapsule.
- **Cluster** : `scaleway_k8s_cluster` (type=kapsule, autoscaler balance + scale-down 5m,
  delete_additional_resources=true).
- **Node pools** : pool principal (`DEV1-M` par défaut, `wait_for_pool_ready=true`) + pool GPU
  optionnel (`L4-1-24G`, autoscale 0→4).
- **RGPD** : défaut `region=fr-par`.
- **Parité dual-substrate** : pendant K8s du module Scaleway/Swarm interne. Contrat normalisé v6.9.61.
- Outputs normalisés : `cluster_id`, `cluster_name`, `cluster_endpoint` (sensitive), `kubeconfig`
  (sensitive — `config_file`), `region`, `node_count`.
- Chaîner avec `terraform-aisia-cluster` pour déployer la stack AISIA sur le substrat Kapsule.
- Auth Scaleway : `provider "scaleway"` configuré dans le root module du consumer.
- README (Inputs/Outputs/Usage), LICENSE MPL-2.0, `versions.tf` (TF >= 1.5, scaleway ~> 2.40).
- `examples/basic` : usage minimal validable (`tofu validate`).
