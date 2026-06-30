###############################################################################
# terraform-scaleway-aisia — outputs (contrat normalisé substrat Kapsule).
# Utiliser cluster_endpoint + kubeconfig pour configurer les providers
# kubernetes/helm dans le root module, puis appeler terraform-aisia-cluster.
###############################################################################

output "cluster_id" {
  description = "ID du cluster Kapsule."
  value       = scaleway_k8s_cluster.aisia.id
}

output "cluster_name" {
  description = "Nom du cluster Kapsule."
  value       = scaleway_k8s_cluster.aisia.name
}

output "cluster_endpoint" {
  description = "Endpoint (apiserver_url) du control plane Kapsule."
  value       = scaleway_k8s_cluster.aisia.apiserver_url
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubeconfig complet du cluster Kapsule (sensible — stocker dans un secret)."
  value       = scaleway_k8s_cluster.aisia.kubeconfig[0].config_file
  sensitive   = true
}

output "cluster_token" {
  description = "Token d'authentification Kapsule (sensible)."
  value       = scaleway_k8s_cluster.aisia.kubeconfig[0].token
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "CA certificate Kapsule (base64)."
  value       = scaleway_k8s_cluster.aisia.kubeconfig[0].cluster_ca_certificate
  sensitive   = true
}

output "region" {
  description = "Région Scaleway du déploiement."
  value       = var.region
}

output "node_count" {
  description = "Taille du pool de nœuds principal."
  value       = scaleway_k8s_pool.primary.size
}

output "gpu_pool_enabled" {
  description = "Un pool GPU a-t-il été provisionné ?"
  value       = var.gpu_enabled
}
