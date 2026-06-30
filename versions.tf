###############################################################################
# terraform-scaleway-aisia — contraintes providers (module publiable, sans bloc provider).
# Le consumer configure `provider "scaleway" { ... }` dans son root module.
###############################################################################
terraform {
  required_version = ">= 1.5"

  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.40"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
