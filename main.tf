###############################################################################
# terraform-scaleway-aisia — substrat Kubernetes Scaleway Kapsule.
#
#   ┌──────────────────────────────────────────────────────────────────────┐
#   │ scaleway_k8s_cluster (Kapsule, control plane managé)                │
#   │   - autoscaler : balance + scale-down 5m                            │
#   │   - delete_additional_resources=true (LB, PV purgés au destroy)     │
#   │ scaleway_k8s_pool (pool principal, wait_for_pool_ready=true)         │
#   │ scaleway_k8s_pool (pool GPU optionnel, autoscale 0→4)               │
#   └──────────────────────────────────────────────────────────────────────┘
#
# Usage : chaîner avec terraform-aisia-cluster pour déployer la stack AISIA.
# Le consumer configure `provider "scaleway" { ... }` dans son root module.
# Output `kubeconfig` (sensitive) alimente les providers kubernetes/helm du root module.
###############################################################################

locals {
  name = "aisia-${var.org_id}-${var.service_key}"
  tags = ["aisia", "kapsule", "k8s", var.image_tag]

  labels = {
    "aisia.fr/org"                 = var.org_id
    "aisia.fr/service"             = var.service_key
    "aisia.fr/tier"                = var.tier
    "app.kubernetes.io/managed-by" = "aisia-terraform"
  }
}

###############################################################################
# Cluster Kapsule (control plane managé)
###############################################################################
resource "scaleway_k8s_cluster" "aisia" {
  name    = local.name
  type    = "kapsule"
  version = var.k8s_version
  cni     = var.cni
  region  = var.region
  tags    = local.tags

  delete_additional_resources = true

  autoscaler_config {
    balance_similar_node_groups = true
    scale_down_unneeded_time    = "5m"
  }
}

###############################################################################
# Pool de nœuds principal
###############################################################################
resource "scaleway_k8s_pool" "primary" {
  cluster_id  = scaleway_k8s_cluster.aisia.id
  name        = "${local.name}-primary"
  node_type   = var.node_type
  size        = var.node_count
  region      = var.region
  autohealing = true
  autoscaling = false
  tags        = local.tags

  wait_for_pool_ready = true
}

###############################################################################
# Pool GPU optionnel (inférence C4)
###############################################################################
resource "scaleway_k8s_pool" "gpu" {
  count       = var.gpu_enabled ? 1 : 0
  cluster_id  = scaleway_k8s_cluster.aisia.id
  name        = "${local.name}-gpu"
  node_type   = var.gpu_node_type
  size        = 1
  min_size    = 0
  max_size    = 4
  region      = var.region
  autohealing = true
  autoscaling = true
  tags        = concat(local.tags, ["gpu"])

  wait_for_pool_ready = true
}
