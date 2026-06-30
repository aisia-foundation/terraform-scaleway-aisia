# Changelog — terraform-scaleway-aisia

Format : [Keep a Changelog](https://keepachangelog.com/) · Versioning : SemVer.

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
