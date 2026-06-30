# terraform-scaleway-aisia

[![Terraform Registry](https://img.shields.io/badge/Terraform%20Registry-terraform-scaleway-aisia-7B42BC?logo=terraform)](https://registry.terraform.io/modules/aisia-foundation/aisia/scaleway/latest) [![License: MPL-2.0](https://img.shields.io/badge/License-MPL--2.0-brightgreen.svg)](LICENSE)

Module Terraform publié sur le registry HCP privé AISIA + public `aisia-foundation` sur registry.terraform.io.

Provisionne un substrat **Scaleway Kapsule** (managed Kubernetes) (L1) pour héberger la
plateforme AISIA. L'application AISIA est ensuite déployée via le module
[terraform-aisia-cluster](../terraform-aisia-cluster/) qui consomme les outputs de ce module.

**Version** : 1.0.0 — Voir [CHANGELOG](CHANGELOG.md)

## Architecture

```
Scaleway Project
  └─ Kapsule Cluster (type=kapsule, autoscaler balance + scale-down 5m)
       ├─ Node pool "primary" (DEV1-M × node_count, wait_for_pool_ready=true)
       └─ Node pool "gpu"    (L4-1-24G, autoscale 0→4, optionnel — gpu_enabled=true)
```

Région par défaut : `fr-par` (conformité RGPD).

## Usage

```hcl
provider "scaleway" {
  region = "fr-par"
  zone   = "fr-par-1"
  # Credentials via SCW_ACCESS_KEY / SCW_SECRET_KEY / SCW_DEFAULT_PROJECT_ID
}

provider "kubernetes" {
  host  = module.aisia_scw.cluster_endpoint
  token = module.aisia_scw.cluster_token
  cluster_ca_certificate = base64decode(module.aisia_scw.cluster_ca_certificate)
}

# L1 — substrat Kapsule
module "aisia_scw" {
  source  = "app.terraform.io/AISIA/aisia/scaleway"
  version = "~> 1.0"

  org_id      = "acme"
  service_key = "C1"
  image_tag   = "v6.9.61"
  tier        = "saas"

  region      = "fr-par"
  node_count  = 2
  node_type   = "PRO2-S"
}

# L2 — déploiement AISIA
module "aisia_app" {
  source  = "app.terraform.io/AISIA/aisia-cluster/kubernetes"
  version = "~> 1.0"

  image_tag = "v6.9.61"
  tier      = "saas"
  domain    = "acme.aisia.fr"
}
```

## Inputs

| Nom | Description | Type | Défaut | Requis |
|-----|-------------|------|--------|--------|
| `org_id` | Identifiant de l'organisation AISIA (tenant) | `string` | — | oui |
| `service_key` | Brique déployée (C1..C11) | `string` | — | oui |
| `runtime_kind` | edge \| compute \| compute-gpu \| data \| ops \| security | `string` | `"compute"` | non |
| `substrate` | Substrat cible (ce module = k8s) | `string` | `"k8s"` | non |
| `profile` | Profil de dimensionnement (S \| M \| L \| XL) | `string` | `"S"` | non |
| `node_count` | Nombre de nœuds du pool principal Kapsule | `number` | `1` | non |
| `image_registry` | Registry des images AISIA | `string` | `"registry.aisia.fr"` | non |
| `image_tag` | Tag d'image AISIA à déployer | `string` | `"v6.9.61"` | non |
| `domain` | Domaine custom (vide = *.aisia.fr) | `string` | `""` | non |
| `tier` | Offre tarifaire (saas \| baas \| paas) | `string` | `"saas"` | non |
| `gpu_enabled` | Provisionner un pool GPU Kapsule | `bool` | `false` | non |
| `region` | Région Scaleway (fr-par = RGPD) | `string` | `"fr-par"` | non |
| `cluster_name` | Préfixe du cluster Kapsule | `string` | `"aisia-scaleway-k8s"` | non |
| `node_type` | Type d'Instance pool principal (DEV1-M = 3 vCPU / 4 GB ; prod : PRO2-S) | `string` | `"DEV1-M"` | non |
| `k8s_version` | Version Kubernetes Kapsule (ex : 1.30) | `string` | `"1.30"` | non |
| `cni` | CNI Kapsule (cilium \| calico \| flannel \| kilo) | `string` | `"cilium"` | non |
| `gpu_node_type` | Type Instance GPU optionnel (L4-1-24G, RENDER-S) | `string` | `"L4-1-24G"` | non |

## Outputs

| Nom | Description | Sensible |
|-----|-------------|----------|
| `cluster_id` | ID du cluster Kapsule | non |
| `cluster_name` | Nom du cluster Kapsule | non |
| `cluster_endpoint` | Endpoint API server Kapsule (apiserver_url) | oui |
| `kubeconfig` | Kubeconfig complet (config_file) | oui |
| `cluster_token` | Token d'authentification Kapsule | oui |
| `cluster_ca_certificate` | CA certificate Kapsule (base64) | oui |
| `region` | Région Scaleway du déploiement | non |
| `node_count` | Taille du pool principal | non |
| `gpu_pool_enabled` | Pool GPU provisionné ? | non |

## Prérequis

- OpenTofu >= 1.5 ou Terraform >= 1.5
- Provider `scaleway/scaleway ~> 2.40`
- Credentials Scaleway via env vars `SCW_ACCESS_KEY` / `SCW_SECRET_KEY` /
  `SCW_DEFAULT_ORGANIZATION_ID` / `SCW_DEFAULT_PROJECT_ID`
- Module `terraform-aisia-cluster ~> 1.0` pour déployer l'application

## Licence

[Mozilla Public License 2.0](LICENSE) — Copyright (c) 2026 AISIA (Sébastien Lambert).
