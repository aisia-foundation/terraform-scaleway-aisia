###############################################################################
# AISIA Terraform Scaleway — variables
#
# Contrat NORMALISÉ v6.13.18 : les 13 variables communes ci-dessous sont
# identiques (noms + types + defaults cloud-agnostiques) à tous les clouds ×
# substrats (référence : infra/terraform/gcp/{k8s,swarm}). Les defaults
# spécifiques au cloud (region, instance_flavor, substrate) sont adaptés à Scaleway.
###############################################################################

# ── Contrat normalisé (commun à tous les clouds) ───────────────────────────
variable "org_id" {
  description = "Identifiant de l'organisation AISIA (tenant)."
  type        = string
}

variable "service_key" {
  description = "Brique déployée (C1..C11, cf. aisia_deployable_services)."
  type        = string
}

variable "runtime_kind" {
  description = "edge|compute|compute-gpu|data|ops|security."
  type        = string
  default     = "compute"
}

variable "substrate" {
  description = "Substrat cible (k8s|swarm). Ici : swarm."
  type        = string
  default     = "swarm"
}

variable "profile" {
  description = "Profil de dimensionnement (S|M|L|XL)."
  type        = string
  default     = "S"
}

variable "region" {
  description = "Région Scaleway (fr-par, nl-ams, pl-waw)."
  type        = string
  default     = "fr-par"
}

variable "node_count" {
  description = "Nombre de nœuds workers (le manager est en plus)."
  type        = number
  default     = 1
}

variable "instance_flavor" {
  description = "Type d'Instance Scaleway des nœuds (DEV1-M = 3 vCPU / 4 GB RAM)."
  type        = string
  default     = "DEV1-M"
}

variable "image_registry" {
  description = "Registry des images AISIA."
  type        = string
  default     = "registry.aisia.fr"
}

variable "image_tag" {
  description = "Tag d'image AISIA à déployer."
  type        = string
  default     = "v6.13.18"
}

variable "domain" {
  description = "Domaine custom de l'org (vide = *.aisia.fr)."
  type        = string
  default     = ""
}

variable "tier" {
  description = "Offre (saas|baas|paas)."
  type        = string
  default     = "saas"
}

variable "gpu_enabled" {
  description = "Provisionner un pool GPU (runtime compute-gpu / inférence C4)."
  type        = bool
  default     = false
}

# ── Spécifiques Scaleway ───────────────────────────────────────────────────
variable "access_key" {
  description = "SCW_ACCESS_KEY."
  type        = string
}

variable "secret_key" {
  description = "SCW_SECRET_KEY (sensible)."
  type        = string
  sensitive   = true
}

variable "organization_id" {
  description = "Scaleway Organization ID."
  type        = string
}

variable "project_id" {
  description = "Scaleway Project ID."
  type        = string
}

variable "zone" {
  description = "Zone Scaleway (fr-par-1, fr-par-2, fr-par-3, nl-ams-1)."
  type        = string
  default     = "fr-par-1"
}

variable "cluster_name" {
  description = "Nom logique du cluster (préfixe des ressources)."
  type        = string
  default     = "aisia-scaleway"
}

variable "image" {
  description = "Image Scaleway (ubuntu_jammy = Ubuntu 22.04 LTS)."
  type        = string
  default     = "ubuntu_jammy"
}

variable "ssh_allowed_cidr" {
  description = "CIDR optionnel autorisé pour SSH. Null désactive l'exposition SSH."
  type        = string
  default     = null
  nullable    = true
  validation {
    condition = var.ssh_allowed_cidr == null || (
      trimspace(var.ssh_allowed_cidr) != "" &&
      var.ssh_allowed_cidr != "0.0.0.0/0" &&
      can(cidrhost(var.ssh_allowed_cidr, 0))
    )
    error_message = "ssh_allowed_cidr doit être un CIDR valide et ne peut jamais être 0.0.0.0/0. Omettez-le pour désactiver SSH."
  }
}
