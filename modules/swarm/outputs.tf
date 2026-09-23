###############################################################################
# AISIA Terraform Scaleway — outputs (sprint v6.13.18)
###############################################################################

# ── Contrat de sortie normalisé (commun substrat swarm) ────────────────────
output "region" {
  description = "Région Scaleway du déploiement."
  value       = var.region
}

output "node_count" {
  description = "Nombre de workers provisionnés (hors manager)."
  value       = var.node_count
}

output "manager_ip" {
  description = "IP publique du manager (entry point Traefik)"
  value       = scaleway_instance_ip.manager.address
}

output "manager_private_ip" {
  description = "IP privée du manager (advertise-addr Swarm)"
  value       = scaleway_instance_server.manager.private_ips[0].address
}

output "worker_ips" {
  description = "Liste des IPs publiques des workers"
  value       = [for ip in scaleway_instance_ip.worker : ip.address]
}

output "worker_private_ips" {
  description = "Liste des IPs privées des workers"
  value       = [for w in scaleway_instance_server.worker : w.private_ips[0].address]
}

output "private_network_id" {
  description = "ID du Private Network Scaleway"
  value       = scaleway_vpc_private_network.aisia.id
}

output "swarm_join_token_path" {
  description = <<-EOT
    Chemin du token worker dans le manager :
      ssh root@<manager_ip> 'cat /tmp/worker-token'
    NOTE : v5.5.67 publiera ce token dans Scaleway Secret Manager.
  EOT
  value       = "/tmp/worker-token"
}

output "next_steps" {
  description = "Étapes manuelles à exécuter après terraform apply"
  value       = <<-EOT
    1. Récupérer le worker token :
       ssh root@${scaleway_instance_ip.manager.address} 'cat /tmp/worker-token'

    2. Joindre chaque worker manuellement (auto-join arrive v5.5.67) :
       ssh root@<worker_ip> "docker swarm join --token <TOKEN> ${scaleway_instance_server.manager.private_ips[0].address}:2377"

    3. Déployer la stack AISIA :
       scp deploy/stack-aisia.yml root@${scaleway_instance_ip.manager.address}:/tmp/
       ssh root@${scaleway_instance_ip.manager.address} 'docker stack deploy -c /tmp/stack-aisia.yml aisia'
  EOT
}
