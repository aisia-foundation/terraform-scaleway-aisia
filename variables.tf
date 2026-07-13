###############################################################################
# terraform-scaleway-aisia — variables d'entrée.
# Substrat Kubernetes Scaleway Kapsule. Contrat normalisé v6.9.61.
#
# Auth Scaleway : le consumer configure `provider "scaleway" { ... }` dans son
# root module avec access_key, secret_key, organization_id, project_id (ou
# SCW_* env vars). Ces credentials ne transitent pas par les variables du module.
###############################################################################

# ── Contrat normalisé (commun à tous les clouds × substrats) ───────────────
variable "org_id" {
  description = "Identifiant de l'organisation AISIA (tenant)."
  type        = string
}

variable "service_key" {
  description = "Brique déployée (C1..C11)."
  type        = string
}

variable "runtime_kind" {
  description = "edge | compute | compute-gpu | data | ops | security."
  type        = string
  default     = "compute"
}

variable "substrate" {
  description = "Substrat cible. Ce module provisionne le substrat 'k8s' (Kapsule)."
  type        = string
  default     = "k8s"
}

variable "profile" {
  description = "Profil de dimensionnement (S | M | L | XL)."
  type        = string
  default     = "S"
}

variable "node_count" {
  description = "Nombre de nœuds du pool Kapsule principal."
  type        = number
  default     = 1
}

variable "image_registry" {
  description = "Registry des images AISIA (utilisé pour les tags Kapsule ; app via terraform-aisia-cluster)."
  type        = string
  default     = "registry.aisia.fr"
}

variable "image_tag" {
  description = "Tag d'image AISIA à déployer (ex. v6.12.27)."
  type        = string
  default     = "v6.12.27"
}

variable "domain" {
  description = "Domaine custom de l'org (vide = *.aisia.fr)."
  type        = string
  default     = ""
}

variable "tier" {
  description = "Offre tarifaire AISIA (saas | baas | paas)."
  type        = string
  default     = "saas"
  validation {
    condition     = contains(["saas", "baas", "paas"], var.tier)
    error_message = "tier doit etre 'saas', 'baas' ou 'paas'."
  }
}

variable "gpu_enabled" {
  description = "Provisionner un pool GPU Kapsule (type gpu_node_type par défaut)."
  type        = bool
  default     = false
}

# ── Spécifiques Scaleway Kapsule ──────────────────────────────────────────
variable "region" {
  description = "Région Scaleway Kapsule (fr-par par défaut pour conformité RGPD)."
  type        = string
  default     = "fr-par"
}

variable "cluster_name" {
  description = "Nom logique du cluster Kapsule (préfixe des ressources)."
  type        = string
  default     = "aisia-scaleway-k8s"
}

variable "node_type" {
  description = "Type d'Instance des nœuds du pool principal (DEV1-M = 3 vCPU / 4 GB ; prod : PRO2-S)."
  type        = string
  default     = "DEV1-M"
}

variable "k8s_version" {
  description = "Version Kubernetes Kapsule (ex : 1.30)."
  type        = string
  default     = "1.30"
}

variable "cni" {
  description = "CNI du cluster Kapsule (cilium | calico | flannel | kilo)."
  type        = string
  default     = "cilium"
}

variable "gpu_node_type" {
  description = "Type d'Instance GPU du pool optionnel (L4-1-24G, RENDER-S, ...)."
  type        = string
  default     = "L4-1-24G"
}
