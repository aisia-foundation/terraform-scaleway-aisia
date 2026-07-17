###############################################################################
# Exemple minimal — terraform-scaleway-aisia (substrat Kapsule)
#
# Prérequis : credentials Scaleway via env vars.
#   export SCW_ACCESS_KEY=...
#   export SCW_SECRET_KEY=...
#   export SCW_DEFAULT_ORGANIZATION_ID=...
#   export SCW_DEFAULT_PROJECT_ID=...
###############################################################################

terraform {
  required_version = ">= 1.5"

  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.40"
    }
  }
}

provider "scaleway" {
  region = "fr-par"
  zone   = "fr-par-1"
  # access_key      = "..."  # ou SCW_ACCESS_KEY
  # secret_key      = "..."  # ou SCW_SECRET_KEY
  # organization_id = "..."  # ou SCW_DEFAULT_ORGANIZATION_ID
  # project_id      = "..."  # ou SCW_DEFAULT_PROJECT_ID
}

###############################################################################
# L1 — substrat Kapsule (1 nœud DEV1-M, profil S)
###############################################################################
module "aisia_scaleway_k8s" {
  # Registre HCP privé (nécessite credentials) :
  #   source  = "app.terraform.io/AISIA/aisia/scaleway"
  #   version = "~> 1.0"
  source = "../../"

  org_id      = "acme"
  service_key = "C1"
  image_tag   = "v6.12.65"
  tier        = "saas"

  region       = "fr-par"
  cluster_name = "aisia-acme"
  node_count   = 1
  node_type    = "DEV1-M"
  k8s_version  = "1.30"
  cni          = "cilium"
}

###############################################################################
# L2 — déploiement AISIA (dans votre root module après cet example) :
#
# provider "kubernetes" {
#   host  = module.aisia_scaleway_k8s.cluster_endpoint
#   token = module.aisia_scaleway_k8s.cluster_token
#   cluster_ca_certificate = base64decode(module.aisia_scaleway_k8s.cluster_ca_certificate)
# }
#
# module "aisia_app" {
#   source  = "app.terraform.io/AISIA/aisia-cluster/kubernetes"
#   version = "~> 1.0"
#   image_tag = "v6.12.65"
#   tier      = "saas"
#   domain    = "acme.aisia.fr"
# }
###############################################################################

output "cluster_id" {
  value = module.aisia_scaleway_k8s.cluster_id
}

output "cluster_name" {
  value = module.aisia_scaleway_k8s.cluster_name
}
