###############################################################################
# AISIA — Multi-cloud Phase 4 partie 2 (sprint v6.13.16)
#
# Module Terraform Scaleway : déploie un cluster Docker Swarm AISIA minimal
# sur Scaleway Instances (DEV1-M manager + workers).
#
#   ┌──────────────────────────────────────────────────────────────────┐
#   │ Private Network + IPs publiques + Security Group                 │
#   │ 1 manager Instance (DEV1-M) + N workers (DEV1-M)                  │
#   │ cloud-init installe Docker + initialise Swarm                     │
#   │ Worker join token via Scaleway Secret Manager (TODO v5.5.67)      │
#   └──────────────────────────────────────────────────────────────────┘
#
# Statut : SKELETON DOCUMENTÉ — pas exécuté en CI. Provisioning manuel.
#
# Usage :
#   cd infra/terraform/scaleway
#   export SCW_ACCESS_KEY=...
#   export SCW_SECRET_KEY=...
#   export SCW_DEFAULT_ORGANIZATION_ID=...
#   export SCW_DEFAULT_PROJECT_ID=...
#   terraform init
#   terraform plan -var="image_tag=v6.13.11"
#   terraform apply
#
# Dépendances : Terraform >= 1.5, Scaleway provider >= 2.40
###############################################################################

###############################################################################
# Private Network + Public Gateway IP
###############################################################################
resource "scaleway_vpc_private_network" "aisia" {
  name = "${var.cluster_name}-pn"
  tags = ["aisia", "swarm", "v6.13.16"]
}

###############################################################################
# Security Group — Swarm + HTTP/HTTPS + SSH
###############################################################################
resource "scaleway_instance_security_group" "swarm" {
  name                    = "${var.cluster_name}-sg"
  description             = "AISIA Swarm cluster (sprint v6.13.16)"
  inbound_default_policy  = "drop"
  outbound_default_policy = "accept"

  inbound_rule {
    action   = "accept"
    port     = 22
    protocol = "TCP"
    ip_range = var.ssh_allowed_cidr
  }

  inbound_rule {
    action   = "accept"
    port     = 80
    protocol = "TCP"
    ip_range = "0.0.0.0/0"
  }

  inbound_rule {
    action   = "accept"
    port     = 443
    protocol = "TCP"
    ip_range = "0.0.0.0/0"
  }

  inbound_rule {
    action     = "accept"
    port_range = "2377-2377"
    protocol   = "TCP"
    ip_range   = "172.16.0.0/12"
  }

  inbound_rule {
    action     = "accept"
    port_range = "7946-7946"
    protocol   = "TCP"
    ip_range   = "172.16.0.0/12"
  }

  inbound_rule {
    action     = "accept"
    port_range = "4789-4789"
    protocol   = "UDP"
    ip_range   = "172.16.0.0/12"
  }
}

###############################################################################
# IPs publiques
###############################################################################
resource "scaleway_instance_ip" "manager" {
  type = "routed_ipv4"
}

resource "scaleway_instance_ip" "worker" {
  count = var.node_count
  type  = "routed_ipv4"
}

###############################################################################
# cloud-init scripts
###############################################################################
locals {
  cloud_init_manager = <<-EOT
    #cloud-config
    package_update: true
    packages:
      - docker.io
    runcmd:
      - systemctl enable --now docker
      - usermod -aG docker root
      - PRIV_IP=$(hostname -I | awk '{print $1}') && docker swarm init --advertise-addr "$PRIV_IP"
      - docker swarm join-token -q worker > /tmp/worker-token
      # AISIA image tag : ${var.image_tag}
      # TODO v5.5.67 : publier worker-token dans Scaleway Secret Manager
  EOT

  cloud_init_worker = <<-EOT
    #cloud-config
    package_update: true
    packages:
      - docker.io
    runcmd:
      - systemctl enable --now docker
      - usermod -aG docker root
      # TODO v5.5.67 : fetch worker-token depuis Scaleway Secret Manager puis
      # docker swarm join --token <TOKEN> <manager-private-ip>:2377
  EOT
}

###############################################################################
# Manager Instance
###############################################################################
resource "scaleway_instance_server" "manager" {
  name              = "${var.cluster_name}-manager"
  type              = var.instance_flavor
  image             = var.image
  ip_id             = scaleway_instance_ip.manager.id
  security_group_id = scaleway_instance_security_group.swarm.id
  user_data = {
    cloud-init = local.cloud_init_manager
  }

  private_network {
    pn_id = scaleway_vpc_private_network.aisia.id
  }

  root_volume {
    size_in_gb = 40
  }

  tags = ["aisia", "swarm-manager", "v6.13.16"]
}

###############################################################################
# Workers Instances
###############################################################################
resource "scaleway_instance_server" "worker" {
  count             = var.node_count
  name              = "${var.cluster_name}-worker-${count.index + 1}"
  type              = var.instance_flavor
  image             = var.image
  ip_id             = scaleway_instance_ip.worker[count.index].id
  security_group_id = scaleway_instance_security_group.swarm.id
  user_data = {
    cloud-init = local.cloud_init_worker
  }

  depends_on = [scaleway_instance_server.manager]

  private_network {
    pn_id = scaleway_vpc_private_network.aisia.id
  }

  root_volume {
    size_in_gb = 60
  }

  tags = ["aisia", "swarm-worker", "v6.13.16"]
}
